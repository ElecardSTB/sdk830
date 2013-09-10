/*
 * Copyright (C) 2013 by Elecard-STB.
 * Written by Ruslan Baryshnikov <Ruslan.Baryshnikov@elecard.ru>
 *
 * Driver for the SSD1307 OLED controler
 */

 /******************************************************************
* INCLUDE FILES                                                   *
*******************************************************************/
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/fb.h>
#include <linux/uaccess.h>
#include <linux/delay.h>
#include <linux/init.h>
#include <linux/platform_device.h>
#include <linux/ctype.h>
#include <linux/input.h>
#include <linux/gpio.h>
//#include <linux/tm1668.h>
#include <linux/board_id.h>
#include <linux/ssd1307.h>
#include <linux/mutex.h>

/******************************************************************
* MODULE PARAMETERS                                               *
*******************************************************************/
int debug = 0;
module_param_named(debug, debug, int, 0644);
MODULE_PARM_DESC(debug, "enable verbose debug");

/******************************************************************
* MODULE DESCRIPTION                                              *
*******************************************************************/
MODULE_AUTHOR("Maxime Ripard <maxime.ripard@free-electrons.com>");
MODULE_DESCRIPTION("FB driver for the Solomon SSD1307 OLED controler");
MODULE_LICENSE("GPL");

 /******************************************************************
* DEFINITIONS	                                                   *
*******************************************************************/
#define dprintk(format, args...) if (debug) { printk("%s[%d]: " format, __FILE__, __LINE__, ##args); }

#define SSD1307FB_WIDTH					128
#define SSD1307FB_HEIGHT				32

#define SSD1307FB_DATA					0x01
#define SSD1307FB_COMMAND				0x00

#define SSD1307FB_CONTRAST				0x81
#define SSD1307FB_SEG_REMAP_ON			0xa1
#define SSD1307FB_DISPLAY_OFF			0xae
#define SSD1307FB_DISPLAY_ON			0xaf
#define SSD1307FB_DISPLAY_NORMAL		0xA6
#define SSD1307FB_DISPLAY_INVERSE		0xA7
#define SSD1307FB_START_PAGE_ADDRESS	0xb0

#define T_WAIT 							(1)

#define DRIVER_NAME 					"ssd1307"


/******************************************************************
* STATIC DATA                                                     *
*******************************************************************/
struct ssd1307_par {
	struct fb_info *info;
	u8 brightness;
	uint32_t GPIOlock;
	unsigned gpio_dio;
	unsigned gpio_sclk;
	unsigned gpio_stb;
	unsigned gpio_12power;
	struct mutex *spi_lock_mutex;
};

static struct fb_fix_screeninfo ssd1307_fix = {
	.id		= "Solomon SSD1307",
	.type		= FB_TYPE_PACKED_PIXELS,
	.visual		= FB_VISUAL_MONO10,
	.xpanstep	= 0,
	.ypanstep	= 0,
	.ywrapstep	= 0,
	.line_length	= SSD1307FB_WIDTH / 8,
	.accel		= FB_ACCEL_NONE,
};

static struct fb_var_screeninfo ssd1307_var = {
	.xres		= SSD1307FB_WIDTH,
	.yres		= SSD1307FB_HEIGHT,
	.xres_virtual	= SSD1307FB_WIDTH,
	.yres_virtual	= SSD1307FB_HEIGHT,
	.bits_per_pixel	= 1,
};

/******************************************************************
* FUNCTION IMPLEMENTATION                                         *
*******************************************************************/
static void ssd1307_writeb(struct ssd1307_par *par, u8 type, u8 byte)
{
	int i;

	gpio_set_value(par->gpio_dio, type);
	gpio_set_value(par->gpio_sclk, 0);
	udelay(T_WAIT);
	gpio_set_value(par->gpio_sclk, 1);
	udelay(T_WAIT);

	for (i = 0; i < 8; i++) {
		gpio_set_value(par->gpio_dio, (byte & 0x80) >> 7);
		gpio_set_value(par->gpio_sclk, 0);
		udelay(T_WAIT);
		gpio_set_value(par->gpio_sclk, 1);
		udelay(T_WAIT);

		byte <<= 1;
	}
}

static int ssd1307_write_array(struct ssd1307_par *par, u8 type, u8 *cmd, u32 len)
{
	int ret = 0;
	int i;

	gpio_set_value(par->gpio_stb, 1);
	udelay(T_WAIT);
	for (i = 0; i < len; i++, cmd++) 
	{
		ssd1307_writeb(par, type, *cmd);

	}
	udelay(T_WAIT);
	gpio_set_value(par->gpio_stb, 0);
	udelay(2*T_WAIT);

	return ret;
}

static inline int ssd1307_write_cmd_array(struct ssd1307_par *par, u8 *cmd, u32 len)
{
	return ssd1307_write_array(par, SSD1307FB_COMMAND, cmd, len);
}

static inline int ssd1307_write_cmd(struct ssd1307_par *par, u8 cmd)
{
	return ssd1307_write_cmd_array(par, &cmd, 1);
}

static inline int ssd1307_write_data_array(struct ssd1307_par *par, u8 *cmd, u32 len)
{
	return ssd1307_write_array(par, SSD1307FB_DATA, cmd, len);
}

static inline int ssd1307_write_data(struct ssd1307_par *par, u8 data)
{
	return ssd1307_write_data_array(par, &data, 1);
}


static void ssd1307_clear_GDDRAM(struct ssd1307_par *par)
{
	u8 buffer[SSD1307FB_WIDTH];
	int i;

	memset(buffer, 0, sizeof(buffer));
	for (i = 0; i < (SSD1307FB_HEIGHT / 8); i++) {
		ssd1307_write_cmd(par, SSD1307FB_START_PAGE_ADDRESS + (i));
		ssd1307_write_cmd(par, 0x00);
		ssd1307_write_cmd(par, 0x10);
		ssd1307_write_data_array(par, buffer, sizeof(buffer));
	}
}

static void ssd1307_update_display(struct ssd1307_par *par)
{
	u8 *vmem = par->info->screen_base;
	u8 buffer[SSD1307FB_WIDTH];
	int i, j, k;

	for (i = 0; i < (SSD1307FB_HEIGHT / 8); i++) {
		ssd1307_write_cmd(par, SSD1307FB_START_PAGE_ADDRESS + (i));
		ssd1307_write_cmd(par, 0x00);
		ssd1307_write_cmd(par, 0x10);

		for (j = 0; j < SSD1307FB_WIDTH; j++) {
			u8 buf = 0;
			for (k = 0; k < 8; k++) {
				u32 page_length = SSD1307FB_WIDTH * i;
				u32 index = page_length + (SSD1307FB_WIDTH * k + j) / 8;
				u8 byte = *(vmem + index);
				u8 bit = byte & (1 << (j % 8));
				bit = bit >> (j % 8);
				buf |= bit << k;
			}
			buffer[j] = buf;
		}
		ssd1307_write_data_array(par, buffer, sizeof(buffer));
	}
}

static ssize_t ssd1307_write(struct fb_info *info, const char __user *buf,
		size_t count, loff_t *ppos)
{
	struct ssd1307_par *par = info->par;
	unsigned long total_size;
	unsigned long p = *ppos;
	u8 __iomem *dst;

	total_size = info->fix.smem_len;

	if (p > total_size)
		return -EINVAL;

	if (count + p > total_size)
		count = total_size - p;

	if (!count)
		return -EINVAL;

	dst = (void __force *) (info->screen_base + p);

	if (copy_from_user(dst, buf, count))
		return -EFAULT;

	if(par->spi_lock_mutex) mutex_lock(par->spi_lock_mutex);
	ssd1307_update_display(par);
	if(par->spi_lock_mutex) mutex_unlock(par->spi_lock_mutex);

	*ppos += count;

	return count;
}


static struct fb_ops ssd1307_ops = {
	.owner		= THIS_MODULE,
	.fb_write	= ssd1307_write,
};

static void ssd1307_deferred_io(struct fb_info *info,
				struct list_head *pagelist)
{
	ssd1307_update_display(info->par);
}


static struct fb_deferred_io ssd1307_defio = {
	.delay			= HZ,
	.deferred_io	= ssd1307_deferred_io,
};

static int32_t ssd1307_brightness_set(struct ssd1307_par *par, u8 brightness)
{
	u8 tmp_buffer[2];
	par->brightness = brightness;

	// Contrast  (select 1 out of 256 contrast steps)
	tmp_buffer[0] = SSD1307FB_CONTRAST;
	tmp_buffer[1] = brightness;
	ssd1307_write_cmd_array(par,tmp_buffer,2);
	return 0;
}

static ssize_t ssd1307_brightness_show(struct device *dev,
		struct device_attribute *attr, char *buf)
{
	int result = 0;
	struct fb_info *info = dev_get_drvdata(dev);
	struct ssd1307_par *par = info->par;

	result = sprintf(buf, "%d\n", par->brightness);

	return result;
	
}

static ssize_t ssd1307_brightness_store(struct device *dev,
		struct device_attribute *attr,
		const char *buf, size_t size)
{
	ssize_t result = 0;
	struct fb_info *info = dev_get_drvdata(dev);
	struct ssd1307_par *par = info->par;
	long unsigned int value;


	result = strict_strtoul(buf, 10, &value);

	if (result == 0) {
		if(value > 0xff) {
			value = 0xff;
		} else if(value < 0) {
			value = 0;
		}

		if(par->spi_lock_mutex) mutex_lock(par->spi_lock_mutex);
		ssd1307_brightness_set(par, (u8)value);
		if(par->spi_lock_mutex) mutex_unlock(par->spi_lock_mutex);
		result = size;
	}
	
	return result;
}

static DEVICE_ATTR(brightness, S_IRUSR | S_IWUSR, ssd1307_brightness_show,
		ssd1307_brightness_store);

static inline void ssd1307_controller_init(struct ssd1307_par *par)
{
	u8 tmp_buffer[2];

	// Display off
	ssd1307_write_cmd(par, SSD1307FB_DISPLAY_OFF);

	// The starting line. Shift relative to the memory strings.
	// 0x40 + x. Where x - number of lines shifted.
	ssd1307_write_cmd(par, 0x40);

	// Setting the MUX (number of rows displayed)
	// 0x23 = 35d. 35 - 4 = 31
	tmp_buffer[0] = 0xA8;
	tmp_buffer[1] = 0x20;
	ssd1307_write_cmd_array(par,tmp_buffer,2);


	// Shift the display to the x lines.
	tmp_buffer[0] = 0xD3;
	tmp_buffer[1] = 35;
	ssd1307_write_cmd_array(par,tmp_buffer,2);

	// Contrast
	ssd1307_brightness_set(par, 0x7f);

	// Normal display (Set Normal/Inverse Display)
	ssd1307_write_cmd(par, 0xA6);

	//	Remap (column address 127 is mapped to SEG0 )
	ssd1307_write_cmd(par, 0xA1);

	//	Clear internal ssd1307 memory
	ssd1307_clear_GDDRAM(par);

	// Display on
	ssd1307_write_cmd(par, SSD1307FB_DISPLAY_ON);
}

static int __init ssd1307_probe(struct platform_device *pdev)
{
	struct fb_info *info;
	u32 vmem_size = SSD1307FB_WIDTH * SSD1307FB_HEIGHT / 8;
	struct ssd1307_par *par;
	struct ssd1307_platform_data *plat_data = pdev->dev.platform_data;
	u8 *vmem;
	int ret;
	int registered_fb_changed = 0;

	info = framebuffer_alloc(sizeof(struct ssd1307_par), &pdev->dev);
	if (!info) {
		dev_err(&pdev->dev, "Couldn't allocate framebuffer.\n");
		return -ENOMEM;
	}

	vmem = devm_kzalloc(&pdev->dev, vmem_size, GFP_KERNEL);
	if (!vmem) {
		dev_err(&pdev->dev, "Couldn't allocate graphical memory.\n");
		ret = -ENOMEM;
		goto fb_alloc_error;
	}

	info->fbops = &ssd1307_ops;
	info->fix = ssd1307_fix;
	info->fbdefio = &ssd1307_defio;

	info->var = ssd1307_var;
	info->var.red.length = 1;
	info->var.red.offset = 0;
	info->var.green.length = 1;
	info->var.green.offset = 0;
	info->var.blue.length = 1;
	info->var.blue.offset = 0;

	info->screen_base = (u8 __force __iomem *)vmem;
	info->fix.smem_start = (unsigned long)vmem;
	info->fix.smem_len = vmem_size;

	fb_deferred_io_init(info);

	par = info->par;
	par->info = info;

	//Trick    We have to reserve FB0 and FB2 node for "elcd"
	if(registered_fb[0] == NULL) {
		registered_fb[0] = (void *)info;
		registered_fb_changed |= 0x01;			//Insert dymmy FB0 info
	}
	if(registered_fb[1] == NULL) {
		registered_fb[1] = (void *)info;
		registered_fb_changed  |= 0x02;			//Insert dymmy FB1 info
	}

	ret = register_framebuffer(info);		//Register ssd1307 frame buffer

	if(0x01 & registered_fb_changed) 	registered_fb[0] = NULL;	// Remove dymmy FB0 info		
	if(0x02 & registered_fb_changed) 	registered_fb[1] = NULL;	// Remove dymmy FB1 info							
	//End of Trick

	if (ret) {
		dev_err(&pdev->dev, "Couldn't register the framebuffer\n");
		goto fbreg_error;
	}

	par->gpio_dio =  plat_data->gpio_dio;
	par->gpio_sclk = plat_data->gpio_sclk;
	par->gpio_stb =  plat_data->gpio_stb;
	par->gpio_12power =  plat_data->gpio_12power;  //this PIO controls 12V power for OLED display (0/1 - off/on state)
	par->GPIOlock =  plat_data->GPIOlock;
	par->spi_lock_mutex = plat_data->spi_lock_mutex;

	if (par->GPIOlock) {
		ret = gpio_request(par->gpio_dio, dev_name(&pdev->dev));
		if (ret != 0)
			goto error_request_gpio_dio;
		gpio_direction_output(par->gpio_dio, 1);
	
		ret = gpio_request(par->gpio_sclk, dev_name(&pdev->dev));
		if (ret != 0)
			goto error_request_gpio_sclk;
		gpio_direction_output(par->gpio_sclk, 1);
	
		ret = gpio_request(par->gpio_stb, dev_name(&pdev->dev));
		if (ret != 0)
			goto error_request_gpio_stb;
		gpio_direction_output(par->gpio_stb, 1);
	}

	ret = gpio_request(par->gpio_12power, dev_name(&pdev->dev));
	if (ret != 0)
		goto error_request_gpio_12power;
	gpio_direction_output(par->gpio_12power, 1);

	//Power ON OLED display
	gpio_set_value(par->gpio_12power, 1);

	//Controller init
	if(par->spi_lock_mutex) mutex_lock(par->spi_lock_mutex);
	ssd1307_controller_init(par);
	if(par->spi_lock_mutex) mutex_unlock(par->spi_lock_mutex);

	ret = device_create_file(&pdev->dev, &dev_attr_brightness);

	if (ret != 0)
		goto error_create_attr_brightness;

	dev_info(&pdev->dev, "fb%d: %s framebuffer device registered, using %d bytes of video memory\n", info->node, info->fix.id, vmem_size);

	platform_set_drvdata(pdev, info);

	return 0;

error_create_attr_brightness:
	unregister_framebuffer(info);
error_request_gpio_12power:
	if (par->GPIOlock) gpio_free(par->gpio_stb);
error_request_gpio_stb:
	if (par->GPIOlock) gpio_free(par->gpio_sclk);
error_request_gpio_sclk:
	if (par->GPIOlock) gpio_free(par->gpio_dio);
error_request_gpio_dio:
	unregister_framebuffer(info);
fbreg_error:
	fb_deferred_io_cleanup(info);
fb_alloc_error:
	framebuffer_release(info);
	return ret;
}

static int __exit ssd1307_remove(struct platform_device *pdev)
{
	struct fb_info *info = platform_get_drvdata(pdev);
	struct ssd1307_par *par;

	par = info->par;

	if(par->spi_lock_mutex) mutex_lock(par->spi_lock_mutex);
	ssd1307_write_cmd(par, SSD1307FB_DISPLAY_OFF);
	if(par->spi_lock_mutex) mutex_unlock(par->spi_lock_mutex);

	if (par->GPIOlock) {
		gpio_free(par->gpio_dio);
		gpio_free(par->gpio_sclk);
		gpio_free(par->gpio_stb);
	}
	
	gpio_free(par->gpio_12power);

	unregister_framebuffer(info);
	fb_deferred_io_cleanup(info);
	framebuffer_release(info);
	device_remove_file(&pdev->dev, &dev_attr_brightness);

	printk("ssd1307: Framebuffer device unregistered\n");
	return 0;
}

static struct platform_driver ssd1307_driver = {
	.driver		= {
		.name	= DRIVER_NAME,
		.owner	= THIS_MODULE,
	},
	.remove		= __exit_p(ssd1307_remove),
};

static int __init ssd1307_init(void)
{
	return platform_driver_probe(&ssd1307_driver, ssd1307_probe);
}

module_init(ssd1307_init);

static void __exit ssd1307_exit(void)
{
	platform_driver_unregister(&ssd1307_driver);
	printk("ssd1307: Goodbye!\n");
}
module_exit(ssd1307_exit);