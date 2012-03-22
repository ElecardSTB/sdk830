
/***********************************************
* INCLUDE FILES                                *
************************************************/

#include <linux/version.h>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/init.h>
#include <linux/device.h>
#include <linux/interrupt.h>
#include <linux/proc_fs.h>
#include <linux/stm/pio.h>
#include <linux/stm/sysconf.h>
#if LINUX_VERSION_CODE > KERNEL_VERSION(2,6,23)
#include <linux/stm/stx7105.h>
#endif
#include <linux/time.h>

#include <asm/system.h>
#include <asm/io.h>
#include <asm/uaccess.h>

#include "keyscanner.h"



/***********************************************
* DEFINES                                      *
************************************************/

#define ST_KEYSCAN_BASE		0xFE020000

#define DIM_OUT	3
#define DIM_IN	3

#define KEYSCAN_IRQ 252

#define ST_KEYSCAN_CONFIG	(ST_KEYSCAN_BASE + 0x00)
#define ST_KEYSCAN_DEBOUNCE	(ST_KEYSCAN_BASE + 0x04)
#define ST_KEYSCAN_STATE	(ST_KEYSCAN_BASE + 0x08)
#define ST_KEYSCAN_X_Y_DIM	(ST_KEYSCAN_BASE + 0x0c)

#define SUCCESS 0

#define MAJOR_NUM		99
#define LOGGER_LENGHT	16

#define DEVICE_NAME		"keypad"


/***********************************************
* STATIC VARS                                  *
************************************************/
static int elc_print_on = 0;

static struct keyStatus keyLogger[LOGGER_LENGHT];
static int loggerTop = 0;
static int loggerBottom = 0;



/***********************************************
* DECLARATIONS                                 *
************************************************/
static int device_open(struct inode *, struct file *);
static int device_release(struct inode *, struct file *);
static ssize_t device_read(struct file *, char *, size_t, loff_t *);




/***********************************************
* FUNCTIONS                                    *
************************************************/
static void incrIndex(int *index)
{
	int i = *index;
	i++;
	if(i >= LOGGER_LENGHT)
		i = 0;
	*index = i;
}

static void loggerPut(int state)
{
	struct timeval now;


	do_gettimeofday(&now);
	keyLogger[loggerTop].valid = 1;
	keyLogger[loggerTop].time = now;
	keyLogger[loggerTop].status = state;

	incrIndex(&loggerTop);
	if(loggerBottom == loggerTop)
		incrIndex(&loggerBottom);
//	printk("put b=%d, t=%d\n", loggerBottom, loggerTop);

}

static struct keyStatus *loggerGet(void)
{
	struct keyStatus *retPointer;

	if(loggerBottom == loggerTop)
		return NULL;

//	keyLogger[loggerBottom].valid = 0;
	retPointer = keyLogger + loggerBottom;

	incrIndex(&loggerBottom);
//	printk("get b=%d, t=%d\n", loggerBottom, loggerTop);

	return retPointer;
}

static int
proc_keyscanner_read(char *page, char **start, off_t off, int count, int *eof,
		    void *data)
{
	char *p = page;
	int len;

	p += sprintf(p, "Key scanner:\n");
	p += sprintf(p, "\tST_KEYSCAN_CONFIG   =0x%08x\n", readl(ST_KEYSCAN_CONFIG));
	p += sprintf(p, "\tST_KEYSCAN_DEBOUNCE =0x%08x\n", readl(ST_KEYSCAN_DEBOUNCE));
	p += sprintf(p, "\tST_KEYSCAN_STATE    =0x%08x\n", readl(ST_KEYSCAN_STATE));
	p += sprintf(p, "\tST_KEYSCAN_X_Y_DIM  =0x%08x\n", readl(ST_KEYSCAN_X_Y_DIM));
	p += sprintf(p, "print stats %s\n", elc_print_on ? "on" : "off");

	len = (p - page) - off;
	if (len < 0)
		len = 0;

	*eof = (len <= count) ? 1 : 0;
	*start = page + off;

	return len;
}

static int proc_keyscanner_write(struct file *file, const char __user *buffer,
				     unsigned long count, void *data)
{
	char mode;

	if (count > 0) {
		if (get_user(mode, buffer))
			return -EFAULT;
		if (mode >= '0' && mode <= '1')
		{
			elc_print_on = mode - '0';
#define SystemConfigBaseAddress 0xFE001000
#define SYSTEM_CONFIG33 (SystemConfigBaseAddress + 0x0184)

/*			struct sysconf_field 	*sys_cfg33_3_3 = NULL;
			int state;
			int val;
			state = readl( SYSTEM_CONFIG33 );
			printk("state=0x%08x\n", state);
			
			sys_cfg33_3_3 = sysconf_claim(SYS_CFG, 33, 3, 3, "usb test");
			if(sys_cfg33_3_3)
			{
				sysconf_write(sys_cfg33_3_3, mode-'0');
				
				state = readl( SYSTEM_CONFIG33 );
				printk("state=0x%08x\n", state);

				sysconf_release(sys_cfg33_3_3);
			} else
				printk("Cant sysconf_claim\n");
				*/
		}
	}
	return count;
}

#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,19)
irqreturn_t elc_keyscanner_interrupt(int a, void *b, struct pt_regs *c)
#else
irqreturn_t elc_keyscanner_interrupt(int a, void *b)
#endif
{
	unsigned int state;
	state = readl( ST_KEYSCAN_STATE );

	if(elc_print_on)
		printk("elcKeyScanner: receive 0x%04x\n", (state & 0x0000ffff));

	loggerPut(state);
	return 0;
}

static struct file_operations fops = {
	.read = device_read,
	.open = device_open,
	.release = device_release
};

static int devOpen = 0;

static int device_open(struct inode *inode, struct file *file)
{

	if (devOpen)
	  return -EBUSY;
	devOpen++;
	try_module_get(THIS_MODULE);
  
	return SUCCESS;
}
 
static int device_release(struct inode *inode, struct file *file)
{
	devOpen--;
	module_put(THIS_MODULE);
  
	return SUCCESS;
}
 
static ssize_t device_read(struct file *filp,
			char *buffer,
			size_t length,
			loff_t * offset)
{
	int bytes_read = 0;
	struct keyStatus *key;
//	char tmpBuf[64];
	char *userBuf = buffer;
  
	key = loggerGet();
	while (key && length) {
		int minLen;
//		sprintf(tmpBuf, "t=0x%08xs,0x%08xus:k=0x%04x\n", (unsigned int)key->time.tv_sec, (unsigned int)key->time.tv_usec, key->status);
		key->valid = 0;

//		minLen = strlen(tmpBuf);//it can be calculate
		minLen = sizeof(struct keyStatus);
		if(minLen > length)
			minLen = length;
//		copy_to_user(userBuf, tmpBuf, minLen);
		copy_to_user(userBuf, key, sizeof(struct keyStatus));
		userBuf += minLen;
		length -= minLen;
		bytes_read += minLen;
		key = loggerGet();
	}

	*offset += bytes_read;
	return bytes_read;
}


static int __init
elc_keyscanner_init(void)
{
	int ret = 0;
	unsigned int matrix_dim = 0;
	unsigned int status = 0;
	struct sysconf_field 	*sys_cfg35_8_11 = NULL,
							*sys_cfg15_0_3 = NULL,
							*sys_cfg32_3 = NULL;

	//config output pins on pio5[0-3]
	sys_cfg35_8_11 = sysconf_claim(SYS_CFG, 35, 8, 11, "ks");

	//config input pins for keyscanner
	sys_cfg15_0_3 = sysconf_claim(SYS_CFG, 15, 0, 3, "ks");

	//enable power for keyscanner module
	sys_cfg32_3 = sysconf_claim(SYS_CFG, 32, 3, 3, "ks");

	if(!sys_cfg35_8_11 || !sys_cfg15_0_3 || !sys_cfg32_3)
	{
		pr_err("ERROR: Request sysconf sys_cfg35_8_11=%p, sys_cfg15_0_3=%p, sys_cfg32_3=%p\n", sys_cfg35_8_11, sys_cfg15_0_3, sys_cfg32_3);
		return -ENODEV;
	}

	sysconf_write(sys_cfg35_8_11, ((1<<DIM_OUT)-1) );
	sysconf_write(sys_cfg15_0_3, ((1<<DIM_IN)-1) );
	sysconf_write(sys_cfg32_3, 0);

	sysconf_release(sys_cfg35_8_11);
	sysconf_release(sys_cfg15_0_3);
	sysconf_release(sys_cfg32_3);


	printk("SuperH keyScanner driver\n");
	/*Scanner Disable*/
	writel(0x00, ST_KEYSCAN_CONFIG);

	/* Set matrix_x_y_dim*/
	matrix_dim |= DIM_IN - 1;
	matrix_dim |= ((DIM_OUT - 1)<<2);
	writel(matrix_dim, ST_KEYSCAN_X_Y_DIM);

	 /* De_bounce timer: 1 --> 10ns*/
	writel(0xFFFFF, ST_KEYSCAN_DEBOUNCE);/*0x18=24 --> 240ns*/

	/*Matrix state*/
	writel(0x0, ST_KEYSCAN_STATE);

	/*Scanner Enable*/
	writel(0x01, ST_KEYSCAN_CONFIG);

	if(status)
		return status;

	ret = request_irq(KEYSCAN_IRQ, elc_keyscanner_interrupt, 0, "elc-keyscanner", NULL);
	
	printk("\tret=%d\n", ret);
	if(ret == 0)
	{
		struct proc_dir_entry *res;

		res = create_proc_entry("keyscanner", S_IWUSR | S_IRUGO, NULL);
		if (!res)
				return -ENOMEM;

		res->read_proc = proc_keyscanner_read;
		res->write_proc = proc_keyscanner_write;
	}

//	printk("%s[%d]: sizeof(keyLogger)=%d sizeof(keyStatus)=%d\n", __FILE__, __LINE__, sizeof(keyLogger), sizeof(struct keyStatus));
	memset(&keyLogger, 0, sizeof(keyLogger));
	loggerTop = 0;
	loggerBottom = 0;
	{//register char device
		int major;
		major = register_chrdev(MAJOR_NUM, DEVICE_NAME, &fops);
		if (major < 0) {    
			printk("Registering the character device failed with %d\n",
					major);
		}

	}


	return ret;
}

static void __exit
elc_keyscanner_exit(void)
{
	/*Scanner Disable*/
	writel(0x00, ST_KEYSCAN_CONFIG);

	unregister_chrdev(MAJOR_NUM, DEVICE_NAME);
	remove_proc_entry("keyscanner", NULL);

	free_irq(KEYSCAN_IRQ, NULL);
}


module_init(elc_keyscanner_init);
module_exit(elc_keyscanner_exit);

MODULE_AUTHOR("Anton Sergeev");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("SuperH key scanner driver");
MODULE_VERSION("0.1");
