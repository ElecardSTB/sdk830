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
#include <linux/tm1668.h>
#include <linux/board_id.h>

/******************************************************************
* MODULE PARAMETERS                                               *
*******************************************************************/
int debug = 0;
module_param_named(debug, debug, int, 0644);
MODULE_PARM_DESC(debug, "enable verbose debug");

/******************************************************************
* MODULE DESCRIPTION                                              *
*******************************************************************/
MODULE_AUTHOR("Ruslan Baryshnikov");
MODULE_DESCRIPTION("ssd1307 LCD chip driver");
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
#define SSD1307FB_START_PAGE_ADDRESS	0xb0
#define T_WAIT 							(1)

#define DRIVER_NAME 					"ssd1307"

/******************************************************************
* STATIC DATA                                                     *
*******************************************************************/
struct ssd1307_par {
	struct fb_info *info;
	int reset;
	unsigned gpio_dio;
	unsigned gpio_sclk;
	unsigned gpio_stb;
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

static void ssd1307_update_display(struct ssd1307_par *par)
{
	u8 *vmem = par->info->screen_base;
	int i, j, k;
	ssd1307_write_cmd(par, SSD1307FB_DISPLAY_ON);
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
			ssd1307_write_data(par, buf);
		}
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

	ssd1307_update_display(par);

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


//static struct fb_deferred_io ssd1307_defio;
static struct fb_deferred_io ssd1307_defio = {
	.delay			= HZ,
	.deferred_io	= ssd1307_deferred_io,
};

static int __init ssd1307_probe(struct platform_device *pdev)
{
	struct fb_info *info;
	u32 vmem_size = SSD1307FB_WIDTH * SSD1307FB_HEIGHT / 8;
	struct ssd1307_par *par;
	//struct tm1668_platform_data *plat_data = pdev->dev.platform_data;
	u8 *vmem;
	int ret;

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

	ret = register_framebuffer(info);
	if (ret) {
		dev_err(&pdev->dev, "Couldn't register the framebuffer\n");
		goto fbreg_error;
	}

	par->gpio_dio = stm_gpio(11, 2);
	// ret = gpio_request(par->gpio_dio, dev_name(&pdev->dev));
	// if (ret != 0)
		// goto error_request_gpio_dio;
	// gpio_direction_output(par->gpio_dio, 1);

	par->gpio_sclk = stm_gpio(11, 3);
	// ret = gpio_request(par->gpio_sclk, dev_name(&pdev->dev));
	// if (ret != 0)
		// goto error_request_gpio_sclk;
	// gpio_direction_output(par->gpio_sclk, 1);

	par->gpio_stb = stm_gpio(11, 4);
	// ret = gpio_request(par->gpio_stb, dev_name(&pdev->dev));
	// if (ret != 0)
		// goto error_request_gpio_stb;
	// gpio_direction_output(par->gpio_stb, 1);

	//================
	// Initialization
	//================

	// Выключение дисплея
	ssd1307_write_cmd(par, SSD1307FB_DISPLAY_OFF);

	// Стартовая строчка. Сдвиг памяти относительно строк.
	// 0x40 + x. Где x - количество сдвигаемых строк.
	ssd1307_write_cmd(par, 0x40);

	// Установка MUX (количество отображаемых строк)
	// 0x23 = 35d. 35 - 4 = 31
	ssd1307_write_cmd(par, 0xA8);
	ssd1307_write_cmd(par, 0x20);

	// Сдвиг дисплея на x строк.
	ssd1307_write_cmd(par, 0xD3);
	ssd1307_write_cmd(par, 35);

	// Contrast
	ssd1307_write_cmd(par, SSD1307FB_CONTRAST);
	ssd1307_write_cmd(par, 0x40);

	// Normal display
	ssd1307_write_cmd(par, 0xA6);

	//	Remap
	ssd1307_write_cmd(par, 0xA1);

	// Включение дисплея
	//ssd1307_write_cmd(par, SSD1307FB_DISPLAY_ON);

	//================
	// Initialization
	//================

	dev_info(&pdev->dev, "fb%d: %s framebuffer device registered, using %d bytes of video memory\n", info->node, info->fix.id, vmem_size);

	platform_set_drvdata(pdev, info);

	return 0;

error_request_gpio_stb:
	gpio_free(par->gpio_sclk);
error_request_gpio_sclk:
	gpio_free(par->gpio_dio);
error_request_gpio_dio:
	unregister_framebuffer(info);
fbreg_error:
	fb_deferred_io_cleanup(info);
fb_alloc_error:
	framebuffer_release(info);
	return ret;
}

static int ssd1307_remove(struct platform_device *pdev)
{
	struct fb_info *info = platform_get_drvdata(pdev);
	struct ssd1307_par *par;

	par = info->par;
	//#warning "Вернуть обратно"
	//ssd1307_write_cmd(par, SSD1307FB_DISPLAY_ON);

	// gpio_free(par->gpio_dio);
	// gpio_free(par->gpio_sclk);
	// gpio_free(par->gpio_stb);

	unregister_framebuffer(info);
	fb_deferred_io_cleanup(info);
	framebuffer_release(info);

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
}
module_exit(ssd1307_exit);