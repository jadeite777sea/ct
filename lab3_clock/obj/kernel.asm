
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 40 12 00       	mov    $0x124000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
c0100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
c0100016:	8d 05 1e 00 10 c0    	lea    0xc010001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
c010001c:	ff e0                	jmp    *%eax

c010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 40 12 c0       	mov    %eax,0xc0124000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 30 12 c0       	mov    $0xc0123000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	55                   	push   %ebp
c0100037:	89 e5                	mov    %esp,%ebp
c0100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	b8 14 71 12 c0       	mov    $0xc0127114,%eax
c0100041:	2d 00 60 12 c0       	sub    $0xc0126000,%eax
c0100046:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100051:	00 
c0100052:	c7 04 24 00 60 12 c0 	movl   $0xc0126000,(%esp)
c0100059:	e8 87 8f 00 00       	call   c0108fe5 <memset>

    cons_init();                // init the console
c010005e:	e8 1d 16 00 00       	call   c0101680 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100063:	c7 45 f4 80 91 10 c0 	movl   $0xc0109180,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010006d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100071:	c7 04 24 9c 91 10 c0 	movl   $0xc010919c,(%esp)
c0100078:	e8 e8 02 00 00       	call   c0100365 <cprintf>

    print_kerninfo();
c010007d:	e8 06 08 00 00       	call   c0100888 <print_kerninfo>

    grade_backtrace();
c0100082:	e8 9f 00 00 00       	call   c0100126 <grade_backtrace>

    pmm_init();                 // init physical memory management
c0100087:	e8 82 4e 00 00       	call   c0104f0e <pmm_init>

    pic_init();                 // init interrupt controller
c010008c:	e8 cd 1f 00 00       	call   c010205e <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100091:	e8 31 21 00 00       	call   c01021c7 <idt_init>

    vmm_init();                 // init virtual memory management
c0100096:	e8 9a 79 00 00       	call   c0107a35 <vmm_init>

    ide_init();                 // init ide devices
c010009b:	e8 1a 17 00 00       	call   c01017ba <ide_init>
    swap_init();                // init swap
c01000a0:	e8 4c 62 00 00       	call   c01062f1 <swap_init>

    clock_init();               // init clock interrupt
c01000a5:	e8 35 0d 00 00       	call   c0100ddf <clock_init>
    intr_enable();              // enable irq interrupt
c01000aa:	e8 0d 1f 00 00       	call   c0101fbc <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c01000af:	eb fe                	jmp    c01000af <kern_init+0x79>

c01000b1 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000b1:	55                   	push   %ebp
c01000b2:	89 e5                	mov    %esp,%ebp
c01000b4:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000b7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000be:	00 
c01000bf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000c6:	00 
c01000c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000ce:	e8 27 0c 00 00       	call   c0100cfa <mon_backtrace>
}
c01000d3:	90                   	nop
c01000d4:	89 ec                	mov    %ebp,%esp
c01000d6:	5d                   	pop    %ebp
c01000d7:	c3                   	ret    

c01000d8 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000d8:	55                   	push   %ebp
c01000d9:	89 e5                	mov    %esp,%ebp
c01000db:	83 ec 18             	sub    $0x18,%esp
c01000de:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000e1:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000e4:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000e7:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01000ed:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01000f1:	89 54 24 08          	mov    %edx,0x8(%esp)
c01000f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01000f9:	89 04 24             	mov    %eax,(%esp)
c01000fc:	e8 b0 ff ff ff       	call   c01000b1 <grade_backtrace2>
}
c0100101:	90                   	nop
c0100102:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100105:	89 ec                	mov    %ebp,%esp
c0100107:	5d                   	pop    %ebp
c0100108:	c3                   	ret    

c0100109 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c0100109:	55                   	push   %ebp
c010010a:	89 e5                	mov    %esp,%ebp
c010010c:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c010010f:	8b 45 10             	mov    0x10(%ebp),%eax
c0100112:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100116:	8b 45 08             	mov    0x8(%ebp),%eax
c0100119:	89 04 24             	mov    %eax,(%esp)
c010011c:	e8 b7 ff ff ff       	call   c01000d8 <grade_backtrace1>
}
c0100121:	90                   	nop
c0100122:	89 ec                	mov    %ebp,%esp
c0100124:	5d                   	pop    %ebp
c0100125:	c3                   	ret    

c0100126 <grade_backtrace>:

void
grade_backtrace(void) {
c0100126:	55                   	push   %ebp
c0100127:	89 e5                	mov    %esp,%ebp
c0100129:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c010012c:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100131:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100138:	ff 
c0100139:	89 44 24 04          	mov    %eax,0x4(%esp)
c010013d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100144:	e8 c0 ff ff ff       	call   c0100109 <grade_backtrace0>
}
c0100149:	90                   	nop
c010014a:	89 ec                	mov    %ebp,%esp
c010014c:	5d                   	pop    %ebp
c010014d:	c3                   	ret    

c010014e <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c010014e:	55                   	push   %ebp
c010014f:	89 e5                	mov    %esp,%ebp
c0100151:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100154:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100157:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c010015a:	8c 45 f2             	mov    %es,-0xe(%ebp)
c010015d:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100160:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100164:	83 e0 03             	and    $0x3,%eax
c0100167:	89 c2                	mov    %eax,%edx
c0100169:	a1 00 60 12 c0       	mov    0xc0126000,%eax
c010016e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100172:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100176:	c7 04 24 a1 91 10 c0 	movl   $0xc01091a1,(%esp)
c010017d:	e8 e3 01 00 00       	call   c0100365 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100182:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100186:	89 c2                	mov    %eax,%edx
c0100188:	a1 00 60 12 c0       	mov    0xc0126000,%eax
c010018d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100191:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100195:	c7 04 24 af 91 10 c0 	movl   $0xc01091af,(%esp)
c010019c:	e8 c4 01 00 00       	call   c0100365 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c01001a1:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001a5:	89 c2                	mov    %eax,%edx
c01001a7:	a1 00 60 12 c0       	mov    0xc0126000,%eax
c01001ac:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001b0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001b4:	c7 04 24 bd 91 10 c0 	movl   $0xc01091bd,(%esp)
c01001bb:	e8 a5 01 00 00       	call   c0100365 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001c0:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001c4:	89 c2                	mov    %eax,%edx
c01001c6:	a1 00 60 12 c0       	mov    0xc0126000,%eax
c01001cb:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001cf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001d3:	c7 04 24 cb 91 10 c0 	movl   $0xc01091cb,(%esp)
c01001da:	e8 86 01 00 00       	call   c0100365 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001df:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001e3:	89 c2                	mov    %eax,%edx
c01001e5:	a1 00 60 12 c0       	mov    0xc0126000,%eax
c01001ea:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001ee:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001f2:	c7 04 24 d9 91 10 c0 	movl   $0xc01091d9,(%esp)
c01001f9:	e8 67 01 00 00       	call   c0100365 <cprintf>
    round ++;
c01001fe:	a1 00 60 12 c0       	mov    0xc0126000,%eax
c0100203:	40                   	inc    %eax
c0100204:	a3 00 60 12 c0       	mov    %eax,0xc0126000
}
c0100209:	90                   	nop
c010020a:	89 ec                	mov    %ebp,%esp
c010020c:	5d                   	pop    %ebp
c010020d:	c3                   	ret    

c010020e <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c010020e:	55                   	push   %ebp
c010020f:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c0100211:	90                   	nop
c0100212:	5d                   	pop    %ebp
c0100213:	c3                   	ret    

c0100214 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100214:	55                   	push   %ebp
c0100215:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c0100217:	90                   	nop
c0100218:	5d                   	pop    %ebp
c0100219:	c3                   	ret    

c010021a <lab1_switch_test>:

static void
lab1_switch_test(void) {
c010021a:	55                   	push   %ebp
c010021b:	89 e5                	mov    %esp,%ebp
c010021d:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100220:	e8 29 ff ff ff       	call   c010014e <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100225:	c7 04 24 e8 91 10 c0 	movl   $0xc01091e8,(%esp)
c010022c:	e8 34 01 00 00       	call   c0100365 <cprintf>
    lab1_switch_to_user();
c0100231:	e8 d8 ff ff ff       	call   c010020e <lab1_switch_to_user>
    lab1_print_cur_status();
c0100236:	e8 13 ff ff ff       	call   c010014e <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c010023b:	c7 04 24 08 92 10 c0 	movl   $0xc0109208,(%esp)
c0100242:	e8 1e 01 00 00       	call   c0100365 <cprintf>
    lab1_switch_to_kernel();
c0100247:	e8 c8 ff ff ff       	call   c0100214 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c010024c:	e8 fd fe ff ff       	call   c010014e <lab1_print_cur_status>
}
c0100251:	90                   	nop
c0100252:	89 ec                	mov    %ebp,%esp
c0100254:	5d                   	pop    %ebp
c0100255:	c3                   	ret    

c0100256 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0100256:	55                   	push   %ebp
c0100257:	89 e5                	mov    %esp,%ebp
c0100259:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c010025c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100260:	74 13                	je     c0100275 <readline+0x1f>
        cprintf("%s", prompt);
c0100262:	8b 45 08             	mov    0x8(%ebp),%eax
c0100265:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100269:	c7 04 24 27 92 10 c0 	movl   $0xc0109227,(%esp)
c0100270:	e8 f0 00 00 00       	call   c0100365 <cprintf>
    }
    int i = 0, c;
c0100275:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c010027c:	e8 73 01 00 00       	call   c01003f4 <getchar>
c0100281:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100284:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100288:	79 07                	jns    c0100291 <readline+0x3b>
            return NULL;
c010028a:	b8 00 00 00 00       	mov    $0x0,%eax
c010028f:	eb 78                	jmp    c0100309 <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0100291:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0100295:	7e 28                	jle    c01002bf <readline+0x69>
c0100297:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c010029e:	7f 1f                	jg     c01002bf <readline+0x69>
            cputchar(c);
c01002a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002a3:	89 04 24             	mov    %eax,(%esp)
c01002a6:	e8 e2 00 00 00       	call   c010038d <cputchar>
            buf[i ++] = c;
c01002ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002ae:	8d 50 01             	lea    0x1(%eax),%edx
c01002b1:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01002b4:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002b7:	88 90 20 60 12 c0    	mov    %dl,-0x3fed9fe0(%eax)
c01002bd:	eb 45                	jmp    c0100304 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
c01002bf:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01002c3:	75 16                	jne    c01002db <readline+0x85>
c01002c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002c9:	7e 10                	jle    c01002db <readline+0x85>
            cputchar(c);
c01002cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002ce:	89 04 24             	mov    %eax,(%esp)
c01002d1:	e8 b7 00 00 00       	call   c010038d <cputchar>
            i --;
c01002d6:	ff 4d f4             	decl   -0xc(%ebp)
c01002d9:	eb 29                	jmp    c0100304 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
c01002db:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01002df:	74 06                	je     c01002e7 <readline+0x91>
c01002e1:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01002e5:	75 95                	jne    c010027c <readline+0x26>
            cputchar(c);
c01002e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002ea:	89 04 24             	mov    %eax,(%esp)
c01002ed:	e8 9b 00 00 00       	call   c010038d <cputchar>
            buf[i] = '\0';
c01002f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002f5:	05 20 60 12 c0       	add    $0xc0126020,%eax
c01002fa:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01002fd:	b8 20 60 12 c0       	mov    $0xc0126020,%eax
c0100302:	eb 05                	jmp    c0100309 <readline+0xb3>
        c = getchar();
c0100304:	e9 73 ff ff ff       	jmp    c010027c <readline+0x26>
        }
    }
}
c0100309:	89 ec                	mov    %ebp,%esp
c010030b:	5d                   	pop    %ebp
c010030c:	c3                   	ret    

c010030d <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c010030d:	55                   	push   %ebp
c010030e:	89 e5                	mov    %esp,%ebp
c0100310:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100313:	8b 45 08             	mov    0x8(%ebp),%eax
c0100316:	89 04 24             	mov    %eax,(%esp)
c0100319:	e8 91 13 00 00       	call   c01016af <cons_putc>
    (*cnt) ++;
c010031e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100321:	8b 00                	mov    (%eax),%eax
c0100323:	8d 50 01             	lea    0x1(%eax),%edx
c0100326:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100329:	89 10                	mov    %edx,(%eax)
}
c010032b:	90                   	nop
c010032c:	89 ec                	mov    %ebp,%esp
c010032e:	5d                   	pop    %ebp
c010032f:	c3                   	ret    

c0100330 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100330:	55                   	push   %ebp
c0100331:	89 e5                	mov    %esp,%ebp
c0100333:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100336:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c010033d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100340:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100344:	8b 45 08             	mov    0x8(%ebp),%eax
c0100347:	89 44 24 08          	mov    %eax,0x8(%esp)
c010034b:	8d 45 f4             	lea    -0xc(%ebp),%eax
c010034e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100352:	c7 04 24 0d 03 10 c0 	movl   $0xc010030d,(%esp)
c0100359:	e8 da 83 00 00       	call   c0108738 <vprintfmt>
    return cnt;
c010035e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100361:	89 ec                	mov    %ebp,%esp
c0100363:	5d                   	pop    %ebp
c0100364:	c3                   	ret    

c0100365 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100365:	55                   	push   %ebp
c0100366:	89 e5                	mov    %esp,%ebp
c0100368:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010036b:	8d 45 0c             	lea    0xc(%ebp),%eax
c010036e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c0100371:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100374:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100378:	8b 45 08             	mov    0x8(%ebp),%eax
c010037b:	89 04 24             	mov    %eax,(%esp)
c010037e:	e8 ad ff ff ff       	call   c0100330 <vcprintf>
c0100383:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0100386:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100389:	89 ec                	mov    %ebp,%esp
c010038b:	5d                   	pop    %ebp
c010038c:	c3                   	ret    

c010038d <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c010038d:	55                   	push   %ebp
c010038e:	89 e5                	mov    %esp,%ebp
c0100390:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100393:	8b 45 08             	mov    0x8(%ebp),%eax
c0100396:	89 04 24             	mov    %eax,(%esp)
c0100399:	e8 11 13 00 00       	call   c01016af <cons_putc>
}
c010039e:	90                   	nop
c010039f:	89 ec                	mov    %ebp,%esp
c01003a1:	5d                   	pop    %ebp
c01003a2:	c3                   	ret    

c01003a3 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01003a3:	55                   	push   %ebp
c01003a4:	89 e5                	mov    %esp,%ebp
c01003a6:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c01003a9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01003b0:	eb 13                	jmp    c01003c5 <cputs+0x22>
        cputch(c, &cnt);
c01003b2:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01003b6:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01003b9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01003bd:	89 04 24             	mov    %eax,(%esp)
c01003c0:	e8 48 ff ff ff       	call   c010030d <cputch>
    while ((c = *str ++) != '\0') {
c01003c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01003c8:	8d 50 01             	lea    0x1(%eax),%edx
c01003cb:	89 55 08             	mov    %edx,0x8(%ebp)
c01003ce:	0f b6 00             	movzbl (%eax),%eax
c01003d1:	88 45 f7             	mov    %al,-0x9(%ebp)
c01003d4:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01003d8:	75 d8                	jne    c01003b2 <cputs+0xf>
    }
    cputch('\n', &cnt);
c01003da:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01003dd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01003e1:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c01003e8:	e8 20 ff ff ff       	call   c010030d <cputch>
    return cnt;
c01003ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01003f0:	89 ec                	mov    %ebp,%esp
c01003f2:	5d                   	pop    %ebp
c01003f3:	c3                   	ret    

c01003f4 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c01003f4:	55                   	push   %ebp
c01003f5:	89 e5                	mov    %esp,%ebp
c01003f7:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c01003fa:	90                   	nop
c01003fb:	e8 ee 12 00 00       	call   c01016ee <cons_getc>
c0100400:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100403:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100407:	74 f2                	je     c01003fb <getchar+0x7>
        /* do nothing */;
    return c;
c0100409:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010040c:	89 ec                	mov    %ebp,%esp
c010040e:	5d                   	pop    %ebp
c010040f:	c3                   	ret    

c0100410 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c0100410:	55                   	push   %ebp
c0100411:	89 e5                	mov    %esp,%ebp
c0100413:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c0100416:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100419:	8b 00                	mov    (%eax),%eax
c010041b:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010041e:	8b 45 10             	mov    0x10(%ebp),%eax
c0100421:	8b 00                	mov    (%eax),%eax
c0100423:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0100426:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c010042d:	e9 ca 00 00 00       	jmp    c01004fc <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
c0100432:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100435:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100438:	01 d0                	add    %edx,%eax
c010043a:	89 c2                	mov    %eax,%edx
c010043c:	c1 ea 1f             	shr    $0x1f,%edx
c010043f:	01 d0                	add    %edx,%eax
c0100441:	d1 f8                	sar    %eax
c0100443:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0100446:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100449:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c010044c:	eb 03                	jmp    c0100451 <stab_binsearch+0x41>
            m --;
c010044e:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
c0100451:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100454:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100457:	7c 1f                	jl     c0100478 <stab_binsearch+0x68>
c0100459:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010045c:	89 d0                	mov    %edx,%eax
c010045e:	01 c0                	add    %eax,%eax
c0100460:	01 d0                	add    %edx,%eax
c0100462:	c1 e0 02             	shl    $0x2,%eax
c0100465:	89 c2                	mov    %eax,%edx
c0100467:	8b 45 08             	mov    0x8(%ebp),%eax
c010046a:	01 d0                	add    %edx,%eax
c010046c:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100470:	0f b6 c0             	movzbl %al,%eax
c0100473:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100476:	75 d6                	jne    c010044e <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
c0100478:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010047b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010047e:	7d 09                	jge    c0100489 <stab_binsearch+0x79>
            l = true_m + 1;
c0100480:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100483:	40                   	inc    %eax
c0100484:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100487:	eb 73                	jmp    c01004fc <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
c0100489:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100490:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100493:	89 d0                	mov    %edx,%eax
c0100495:	01 c0                	add    %eax,%eax
c0100497:	01 d0                	add    %edx,%eax
c0100499:	c1 e0 02             	shl    $0x2,%eax
c010049c:	89 c2                	mov    %eax,%edx
c010049e:	8b 45 08             	mov    0x8(%ebp),%eax
c01004a1:	01 d0                	add    %edx,%eax
c01004a3:	8b 40 08             	mov    0x8(%eax),%eax
c01004a6:	39 45 18             	cmp    %eax,0x18(%ebp)
c01004a9:	76 11                	jbe    c01004bc <stab_binsearch+0xac>
            *region_left = m;
c01004ab:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004ae:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004b1:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c01004b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004b6:	40                   	inc    %eax
c01004b7:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004ba:	eb 40                	jmp    c01004fc <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
c01004bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004bf:	89 d0                	mov    %edx,%eax
c01004c1:	01 c0                	add    %eax,%eax
c01004c3:	01 d0                	add    %edx,%eax
c01004c5:	c1 e0 02             	shl    $0x2,%eax
c01004c8:	89 c2                	mov    %eax,%edx
c01004ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01004cd:	01 d0                	add    %edx,%eax
c01004cf:	8b 40 08             	mov    0x8(%eax),%eax
c01004d2:	39 45 18             	cmp    %eax,0x18(%ebp)
c01004d5:	73 14                	jae    c01004eb <stab_binsearch+0xdb>
            *region_right = m - 1;
c01004d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004da:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004dd:	8b 45 10             	mov    0x10(%ebp),%eax
c01004e0:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01004e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004e5:	48                   	dec    %eax
c01004e6:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004e9:	eb 11                	jmp    c01004fc <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01004eb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004ee:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004f1:	89 10                	mov    %edx,(%eax)
            l = m;
c01004f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01004f9:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
c01004fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01004ff:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0100502:	0f 8e 2a ff ff ff    	jle    c0100432 <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
c0100508:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010050c:	75 0f                	jne    c010051d <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
c010050e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100511:	8b 00                	mov    (%eax),%eax
c0100513:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100516:	8b 45 10             	mov    0x10(%ebp),%eax
c0100519:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c010051b:	eb 3e                	jmp    c010055b <stab_binsearch+0x14b>
        l = *region_right;
c010051d:	8b 45 10             	mov    0x10(%ebp),%eax
c0100520:	8b 00                	mov    (%eax),%eax
c0100522:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0100525:	eb 03                	jmp    c010052a <stab_binsearch+0x11a>
c0100527:	ff 4d fc             	decl   -0x4(%ebp)
c010052a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010052d:	8b 00                	mov    (%eax),%eax
c010052f:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c0100532:	7e 1f                	jle    c0100553 <stab_binsearch+0x143>
c0100534:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100537:	89 d0                	mov    %edx,%eax
c0100539:	01 c0                	add    %eax,%eax
c010053b:	01 d0                	add    %edx,%eax
c010053d:	c1 e0 02             	shl    $0x2,%eax
c0100540:	89 c2                	mov    %eax,%edx
c0100542:	8b 45 08             	mov    0x8(%ebp),%eax
c0100545:	01 d0                	add    %edx,%eax
c0100547:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010054b:	0f b6 c0             	movzbl %al,%eax
c010054e:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100551:	75 d4                	jne    c0100527 <stab_binsearch+0x117>
        *region_left = l;
c0100553:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100556:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100559:	89 10                	mov    %edx,(%eax)
}
c010055b:	90                   	nop
c010055c:	89 ec                	mov    %ebp,%esp
c010055e:	5d                   	pop    %ebp
c010055f:	c3                   	ret    

c0100560 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100560:	55                   	push   %ebp
c0100561:	89 e5                	mov    %esp,%ebp
c0100563:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100566:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100569:	c7 00 2c 92 10 c0    	movl   $0xc010922c,(%eax)
    info->eip_line = 0;
c010056f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100572:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100579:	8b 45 0c             	mov    0xc(%ebp),%eax
c010057c:	c7 40 08 2c 92 10 c0 	movl   $0xc010922c,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100583:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100586:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c010058d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100590:	8b 55 08             	mov    0x8(%ebp),%edx
c0100593:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100596:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100599:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c01005a0:	c7 45 f4 54 b2 10 c0 	movl   $0xc010b254,-0xc(%ebp)
    stab_end = __STAB_END__;
c01005a7:	c7 45 f0 3c ba 11 c0 	movl   $0xc011ba3c,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c01005ae:	c7 45 ec 3d ba 11 c0 	movl   $0xc011ba3d,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c01005b5:	c7 45 e8 1a 0a 12 c0 	movl   $0xc0120a1a,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c01005bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005bf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01005c2:	76 0b                	jbe    c01005cf <debuginfo_eip+0x6f>
c01005c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005c7:	48                   	dec    %eax
c01005c8:	0f b6 00             	movzbl (%eax),%eax
c01005cb:	84 c0                	test   %al,%al
c01005cd:	74 0a                	je     c01005d9 <debuginfo_eip+0x79>
        return -1;
c01005cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005d4:	e9 ab 02 00 00       	jmp    c0100884 <debuginfo_eip+0x324>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01005d9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01005e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005e3:	2b 45 f4             	sub    -0xc(%ebp),%eax
c01005e6:	c1 f8 02             	sar    $0x2,%eax
c01005e9:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01005ef:	48                   	dec    %eax
c01005f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01005f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01005f6:	89 44 24 10          	mov    %eax,0x10(%esp)
c01005fa:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c0100601:	00 
c0100602:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0100605:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100609:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c010060c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100610:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100613:	89 04 24             	mov    %eax,(%esp)
c0100616:	e8 f5 fd ff ff       	call   c0100410 <stab_binsearch>
    if (lfile == 0)
c010061b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010061e:	85 c0                	test   %eax,%eax
c0100620:	75 0a                	jne    c010062c <debuginfo_eip+0xcc>
        return -1;
c0100622:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100627:	e9 58 02 00 00       	jmp    c0100884 <debuginfo_eip+0x324>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c010062c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010062f:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100632:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100635:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c0100638:	8b 45 08             	mov    0x8(%ebp),%eax
c010063b:	89 44 24 10          	mov    %eax,0x10(%esp)
c010063f:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c0100646:	00 
c0100647:	8d 45 d8             	lea    -0x28(%ebp),%eax
c010064a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010064e:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100651:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100655:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100658:	89 04 24             	mov    %eax,(%esp)
c010065b:	e8 b0 fd ff ff       	call   c0100410 <stab_binsearch>

    if (lfun <= rfun) {
c0100660:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100663:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100666:	39 c2                	cmp    %eax,%edx
c0100668:	7f 78                	jg     c01006e2 <debuginfo_eip+0x182>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c010066a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010066d:	89 c2                	mov    %eax,%edx
c010066f:	89 d0                	mov    %edx,%eax
c0100671:	01 c0                	add    %eax,%eax
c0100673:	01 d0                	add    %edx,%eax
c0100675:	c1 e0 02             	shl    $0x2,%eax
c0100678:	89 c2                	mov    %eax,%edx
c010067a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010067d:	01 d0                	add    %edx,%eax
c010067f:	8b 10                	mov    (%eax),%edx
c0100681:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100684:	2b 45 ec             	sub    -0x14(%ebp),%eax
c0100687:	39 c2                	cmp    %eax,%edx
c0100689:	73 22                	jae    c01006ad <debuginfo_eip+0x14d>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c010068b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010068e:	89 c2                	mov    %eax,%edx
c0100690:	89 d0                	mov    %edx,%eax
c0100692:	01 c0                	add    %eax,%eax
c0100694:	01 d0                	add    %edx,%eax
c0100696:	c1 e0 02             	shl    $0x2,%eax
c0100699:	89 c2                	mov    %eax,%edx
c010069b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010069e:	01 d0                	add    %edx,%eax
c01006a0:	8b 10                	mov    (%eax),%edx
c01006a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01006a5:	01 c2                	add    %eax,%edx
c01006a7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006aa:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c01006ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006b0:	89 c2                	mov    %eax,%edx
c01006b2:	89 d0                	mov    %edx,%eax
c01006b4:	01 c0                	add    %eax,%eax
c01006b6:	01 d0                	add    %edx,%eax
c01006b8:	c1 e0 02             	shl    $0x2,%eax
c01006bb:	89 c2                	mov    %eax,%edx
c01006bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006c0:	01 d0                	add    %edx,%eax
c01006c2:	8b 50 08             	mov    0x8(%eax),%edx
c01006c5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006c8:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01006cb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006ce:	8b 40 10             	mov    0x10(%eax),%eax
c01006d1:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01006d4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006d7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c01006da:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01006dd:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01006e0:	eb 15                	jmp    c01006f7 <debuginfo_eip+0x197>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01006e2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006e5:	8b 55 08             	mov    0x8(%ebp),%edx
c01006e8:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01006eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006ee:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01006f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006f4:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01006f7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006fa:	8b 40 08             	mov    0x8(%eax),%eax
c01006fd:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c0100704:	00 
c0100705:	89 04 24             	mov    %eax,(%esp)
c0100708:	e8 50 87 00 00       	call   c0108e5d <strfind>
c010070d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100710:	8b 4a 08             	mov    0x8(%edx),%ecx
c0100713:	29 c8                	sub    %ecx,%eax
c0100715:	89 c2                	mov    %eax,%edx
c0100717:	8b 45 0c             	mov    0xc(%ebp),%eax
c010071a:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c010071d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100720:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100724:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c010072b:	00 
c010072c:	8d 45 d0             	lea    -0x30(%ebp),%eax
c010072f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100733:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0100736:	89 44 24 04          	mov    %eax,0x4(%esp)
c010073a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010073d:	89 04 24             	mov    %eax,(%esp)
c0100740:	e8 cb fc ff ff       	call   c0100410 <stab_binsearch>
    if (lline <= rline) {
c0100745:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100748:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010074b:	39 c2                	cmp    %eax,%edx
c010074d:	7f 23                	jg     c0100772 <debuginfo_eip+0x212>
        info->eip_line = stabs[rline].n_desc;
c010074f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100752:	89 c2                	mov    %eax,%edx
c0100754:	89 d0                	mov    %edx,%eax
c0100756:	01 c0                	add    %eax,%eax
c0100758:	01 d0                	add    %edx,%eax
c010075a:	c1 e0 02             	shl    $0x2,%eax
c010075d:	89 c2                	mov    %eax,%edx
c010075f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100762:	01 d0                	add    %edx,%eax
c0100764:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100768:	89 c2                	mov    %eax,%edx
c010076a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010076d:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100770:	eb 11                	jmp    c0100783 <debuginfo_eip+0x223>
        return -1;
c0100772:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100777:	e9 08 01 00 00       	jmp    c0100884 <debuginfo_eip+0x324>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c010077c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010077f:	48                   	dec    %eax
c0100780:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
c0100783:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100786:	8b 45 e4             	mov    -0x1c(%ebp),%eax
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0100789:	39 c2                	cmp    %eax,%edx
c010078b:	7c 56                	jl     c01007e3 <debuginfo_eip+0x283>
           && stabs[lline].n_type != N_SOL
c010078d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100790:	89 c2                	mov    %eax,%edx
c0100792:	89 d0                	mov    %edx,%eax
c0100794:	01 c0                	add    %eax,%eax
c0100796:	01 d0                	add    %edx,%eax
c0100798:	c1 e0 02             	shl    $0x2,%eax
c010079b:	89 c2                	mov    %eax,%edx
c010079d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007a0:	01 d0                	add    %edx,%eax
c01007a2:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007a6:	3c 84                	cmp    $0x84,%al
c01007a8:	74 39                	je     c01007e3 <debuginfo_eip+0x283>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c01007aa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007ad:	89 c2                	mov    %eax,%edx
c01007af:	89 d0                	mov    %edx,%eax
c01007b1:	01 c0                	add    %eax,%eax
c01007b3:	01 d0                	add    %edx,%eax
c01007b5:	c1 e0 02             	shl    $0x2,%eax
c01007b8:	89 c2                	mov    %eax,%edx
c01007ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007bd:	01 d0                	add    %edx,%eax
c01007bf:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007c3:	3c 64                	cmp    $0x64,%al
c01007c5:	75 b5                	jne    c010077c <debuginfo_eip+0x21c>
c01007c7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007ca:	89 c2                	mov    %eax,%edx
c01007cc:	89 d0                	mov    %edx,%eax
c01007ce:	01 c0                	add    %eax,%eax
c01007d0:	01 d0                	add    %edx,%eax
c01007d2:	c1 e0 02             	shl    $0x2,%eax
c01007d5:	89 c2                	mov    %eax,%edx
c01007d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007da:	01 d0                	add    %edx,%eax
c01007dc:	8b 40 08             	mov    0x8(%eax),%eax
c01007df:	85 c0                	test   %eax,%eax
c01007e1:	74 99                	je     c010077c <debuginfo_eip+0x21c>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01007e3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007e9:	39 c2                	cmp    %eax,%edx
c01007eb:	7c 42                	jl     c010082f <debuginfo_eip+0x2cf>
c01007ed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007f0:	89 c2                	mov    %eax,%edx
c01007f2:	89 d0                	mov    %edx,%eax
c01007f4:	01 c0                	add    %eax,%eax
c01007f6:	01 d0                	add    %edx,%eax
c01007f8:	c1 e0 02             	shl    $0x2,%eax
c01007fb:	89 c2                	mov    %eax,%edx
c01007fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100800:	01 d0                	add    %edx,%eax
c0100802:	8b 10                	mov    (%eax),%edx
c0100804:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100807:	2b 45 ec             	sub    -0x14(%ebp),%eax
c010080a:	39 c2                	cmp    %eax,%edx
c010080c:	73 21                	jae    c010082f <debuginfo_eip+0x2cf>
        info->eip_file = stabstr + stabs[lline].n_strx;
c010080e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100811:	89 c2                	mov    %eax,%edx
c0100813:	89 d0                	mov    %edx,%eax
c0100815:	01 c0                	add    %eax,%eax
c0100817:	01 d0                	add    %edx,%eax
c0100819:	c1 e0 02             	shl    $0x2,%eax
c010081c:	89 c2                	mov    %eax,%edx
c010081e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100821:	01 d0                	add    %edx,%eax
c0100823:	8b 10                	mov    (%eax),%edx
c0100825:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100828:	01 c2                	add    %eax,%edx
c010082a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010082d:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c010082f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100832:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100835:	39 c2                	cmp    %eax,%edx
c0100837:	7d 46                	jge    c010087f <debuginfo_eip+0x31f>
        for (lline = lfun + 1;
c0100839:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010083c:	40                   	inc    %eax
c010083d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100840:	eb 16                	jmp    c0100858 <debuginfo_eip+0x2f8>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100842:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100845:	8b 40 14             	mov    0x14(%eax),%eax
c0100848:	8d 50 01             	lea    0x1(%eax),%edx
c010084b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010084e:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c0100851:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100854:	40                   	inc    %eax
c0100855:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100858:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010085b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010085e:	39 c2                	cmp    %eax,%edx
c0100860:	7d 1d                	jge    c010087f <debuginfo_eip+0x31f>
c0100862:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100865:	89 c2                	mov    %eax,%edx
c0100867:	89 d0                	mov    %edx,%eax
c0100869:	01 c0                	add    %eax,%eax
c010086b:	01 d0                	add    %edx,%eax
c010086d:	c1 e0 02             	shl    $0x2,%eax
c0100870:	89 c2                	mov    %eax,%edx
c0100872:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100875:	01 d0                	add    %edx,%eax
c0100877:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010087b:	3c a0                	cmp    $0xa0,%al
c010087d:	74 c3                	je     c0100842 <debuginfo_eip+0x2e2>
        }
    }
    return 0;
c010087f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100884:	89 ec                	mov    %ebp,%esp
c0100886:	5d                   	pop    %ebp
c0100887:	c3                   	ret    

c0100888 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100888:	55                   	push   %ebp
c0100889:	89 e5                	mov    %esp,%ebp
c010088b:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c010088e:	c7 04 24 36 92 10 c0 	movl   $0xc0109236,(%esp)
c0100895:	e8 cb fa ff ff       	call   c0100365 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010089a:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c01008a1:	c0 
c01008a2:	c7 04 24 4f 92 10 c0 	movl   $0xc010924f,(%esp)
c01008a9:	e8 b7 fa ff ff       	call   c0100365 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01008ae:	c7 44 24 04 71 91 10 	movl   $0xc0109171,0x4(%esp)
c01008b5:	c0 
c01008b6:	c7 04 24 67 92 10 c0 	movl   $0xc0109267,(%esp)
c01008bd:	e8 a3 fa ff ff       	call   c0100365 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01008c2:	c7 44 24 04 00 60 12 	movl   $0xc0126000,0x4(%esp)
c01008c9:	c0 
c01008ca:	c7 04 24 7f 92 10 c0 	movl   $0xc010927f,(%esp)
c01008d1:	e8 8f fa ff ff       	call   c0100365 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01008d6:	c7 44 24 04 14 71 12 	movl   $0xc0127114,0x4(%esp)
c01008dd:	c0 
c01008de:	c7 04 24 97 92 10 c0 	movl   $0xc0109297,(%esp)
c01008e5:	e8 7b fa ff ff       	call   c0100365 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01008ea:	b8 14 71 12 c0       	mov    $0xc0127114,%eax
c01008ef:	2d 36 00 10 c0       	sub    $0xc0100036,%eax
c01008f4:	05 ff 03 00 00       	add    $0x3ff,%eax
c01008f9:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01008ff:	85 c0                	test   %eax,%eax
c0100901:	0f 48 c2             	cmovs  %edx,%eax
c0100904:	c1 f8 0a             	sar    $0xa,%eax
c0100907:	89 44 24 04          	mov    %eax,0x4(%esp)
c010090b:	c7 04 24 b0 92 10 c0 	movl   $0xc01092b0,(%esp)
c0100912:	e8 4e fa ff ff       	call   c0100365 <cprintf>
}
c0100917:	90                   	nop
c0100918:	89 ec                	mov    %ebp,%esp
c010091a:	5d                   	pop    %ebp
c010091b:	c3                   	ret    

c010091c <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c010091c:	55                   	push   %ebp
c010091d:	89 e5                	mov    %esp,%ebp
c010091f:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0100925:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100928:	89 44 24 04          	mov    %eax,0x4(%esp)
c010092c:	8b 45 08             	mov    0x8(%ebp),%eax
c010092f:	89 04 24             	mov    %eax,(%esp)
c0100932:	e8 29 fc ff ff       	call   c0100560 <debuginfo_eip>
c0100937:	85 c0                	test   %eax,%eax
c0100939:	74 15                	je     c0100950 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c010093b:	8b 45 08             	mov    0x8(%ebp),%eax
c010093e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100942:	c7 04 24 da 92 10 c0 	movl   $0xc01092da,(%esp)
c0100949:	e8 17 fa ff ff       	call   c0100365 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c010094e:	eb 6c                	jmp    c01009bc <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100950:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100957:	eb 1b                	jmp    c0100974 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
c0100959:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010095c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010095f:	01 d0                	add    %edx,%eax
c0100961:	0f b6 10             	movzbl (%eax),%edx
c0100964:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c010096a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010096d:	01 c8                	add    %ecx,%eax
c010096f:	88 10                	mov    %dl,(%eax)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100971:	ff 45 f4             	incl   -0xc(%ebp)
c0100974:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100977:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010097a:	7c dd                	jl     c0100959 <print_debuginfo+0x3d>
        fnname[j] = '\0';
c010097c:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100982:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100985:	01 d0                	add    %edx,%eax
c0100987:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
c010098a:	8b 55 ec             	mov    -0x14(%ebp),%edx
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c010098d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100990:	29 d0                	sub    %edx,%eax
c0100992:	89 c1                	mov    %eax,%ecx
c0100994:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100997:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010099a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c010099e:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c01009a4:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01009a8:	89 54 24 08          	mov    %edx,0x8(%esp)
c01009ac:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009b0:	c7 04 24 f6 92 10 c0 	movl   $0xc01092f6,(%esp)
c01009b7:	e8 a9 f9 ff ff       	call   c0100365 <cprintf>
}
c01009bc:	90                   	nop
c01009bd:	89 ec                	mov    %ebp,%esp
c01009bf:	5d                   	pop    %ebp
c01009c0:	c3                   	ret    

c01009c1 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c01009c1:	55                   	push   %ebp
c01009c2:	89 e5                	mov    %esp,%ebp
c01009c4:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c01009c7:	8b 45 04             	mov    0x4(%ebp),%eax
c01009ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c01009cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01009d0:	89 ec                	mov    %ebp,%esp
c01009d2:	5d                   	pop    %ebp
c01009d3:	c3                   	ret    

c01009d4 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c01009d4:	55                   	push   %ebp
c01009d5:	89 e5                	mov    %esp,%ebp
c01009d7:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c01009da:	89 e8                	mov    %ebp,%eax
c01009dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c01009df:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
      uint32_t ebp=read_ebp();
c01009e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
      uint32_t eip=read_eip();
c01009e5:	e8 d7 ff ff ff       	call   c01009c1 <read_eip>
c01009ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
      int i,j;
      for(i=0;ebp!=0 && i<STACKFRAME_DEPTH;i++)
c01009ed:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01009f4:	e9 a8 00 00 00       	jmp    c0100aa1 <print_stackframe+0xcd>
      {
        cprintf("%08x",ebp);
c01009f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009fc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a00:	c7 04 24 08 93 10 c0 	movl   $0xc0109308,(%esp)
c0100a07:	e8 59 f9 ff ff       	call   c0100365 <cprintf>
        cprintf(" ");
c0100a0c:	c7 04 24 0d 93 10 c0 	movl   $0xc010930d,(%esp)
c0100a13:	e8 4d f9 ff ff       	call   c0100365 <cprintf>
        cprintf("%08x",eip);
c0100a18:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a1b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a1f:	c7 04 24 08 93 10 c0 	movl   $0xc0109308,(%esp)
c0100a26:	e8 3a f9 ff ff       	call   c0100365 <cprintf>
        uint32_t* a=(uint32_t*)ebp+2;
c0100a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a2e:	83 c0 08             	add    $0x8,%eax
c0100a31:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for(j=0;j<4;j++)
c0100a34:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100a3b:	eb 30                	jmp    c0100a6d <print_stackframe+0x99>
        {
            cprintf(" ");
c0100a3d:	c7 04 24 0d 93 10 c0 	movl   $0xc010930d,(%esp)
c0100a44:	e8 1c f9 ff ff       	call   c0100365 <cprintf>
            cprintf("%08x",a[j]);
c0100a49:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a4c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100a53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100a56:	01 d0                	add    %edx,%eax
c0100a58:	8b 00                	mov    (%eax),%eax
c0100a5a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a5e:	c7 04 24 08 93 10 c0 	movl   $0xc0109308,(%esp)
c0100a65:	e8 fb f8 ff ff       	call   c0100365 <cprintf>
        for(j=0;j<4;j++)
c0100a6a:	ff 45 e8             	incl   -0x18(%ebp)
c0100a6d:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100a71:	7e ca                	jle    c0100a3d <print_stackframe+0x69>
        }
        cprintf("\n");
c0100a73:	c7 04 24 0f 93 10 c0 	movl   $0xc010930f,(%esp)
c0100a7a:	e8 e6 f8 ff ff       	call   c0100365 <cprintf>

        print_debuginfo(eip-1);
c0100a7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a82:	48                   	dec    %eax
c0100a83:	89 04 24             	mov    %eax,(%esp)
c0100a86:	e8 91 fe ff ff       	call   c010091c <print_debuginfo>

        eip=((uint32_t*)ebp)[1];
c0100a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a8e:	83 c0 04             	add    $0x4,%eax
c0100a91:	8b 00                	mov    (%eax),%eax
c0100a93:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp=((uint32_t*)ebp)[0];
c0100a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a99:	8b 00                	mov    (%eax),%eax
c0100a9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
      for(i=0;ebp!=0 && i<STACKFRAME_DEPTH;i++)
c0100a9e:	ff 45 ec             	incl   -0x14(%ebp)
c0100aa1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100aa5:	74 0a                	je     c0100ab1 <print_stackframe+0xdd>
c0100aa7:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100aab:	0f 8e 48 ff ff ff    	jle    c01009f9 <print_stackframe+0x25>


      }
}
c0100ab1:	90                   	nop
c0100ab2:	89 ec                	mov    %ebp,%esp
c0100ab4:	5d                   	pop    %ebp
c0100ab5:	c3                   	ret    

c0100ab6 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100ab6:	55                   	push   %ebp
c0100ab7:	89 e5                	mov    %esp,%ebp
c0100ab9:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100abc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100ac3:	eb 0c                	jmp    c0100ad1 <parse+0x1b>
            *buf ++ = '\0';
c0100ac5:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ac8:	8d 50 01             	lea    0x1(%eax),%edx
c0100acb:	89 55 08             	mov    %edx,0x8(%ebp)
c0100ace:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100ad1:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ad4:	0f b6 00             	movzbl (%eax),%eax
c0100ad7:	84 c0                	test   %al,%al
c0100ad9:	74 1d                	je     c0100af8 <parse+0x42>
c0100adb:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ade:	0f b6 00             	movzbl (%eax),%eax
c0100ae1:	0f be c0             	movsbl %al,%eax
c0100ae4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ae8:	c7 04 24 94 93 10 c0 	movl   $0xc0109394,(%esp)
c0100aef:	e8 35 83 00 00       	call   c0108e29 <strchr>
c0100af4:	85 c0                	test   %eax,%eax
c0100af6:	75 cd                	jne    c0100ac5 <parse+0xf>
        }
        if (*buf == '\0') {
c0100af8:	8b 45 08             	mov    0x8(%ebp),%eax
c0100afb:	0f b6 00             	movzbl (%eax),%eax
c0100afe:	84 c0                	test   %al,%al
c0100b00:	74 65                	je     c0100b67 <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100b02:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100b06:	75 14                	jne    c0100b1c <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100b08:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100b0f:	00 
c0100b10:	c7 04 24 99 93 10 c0 	movl   $0xc0109399,(%esp)
c0100b17:	e8 49 f8 ff ff       	call   c0100365 <cprintf>
        }
        argv[argc ++] = buf;
c0100b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b1f:	8d 50 01             	lea    0x1(%eax),%edx
c0100b22:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100b25:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100b2f:	01 c2                	add    %eax,%edx
c0100b31:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b34:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b36:	eb 03                	jmp    c0100b3b <parse+0x85>
            buf ++;
c0100b38:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b3b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b3e:	0f b6 00             	movzbl (%eax),%eax
c0100b41:	84 c0                	test   %al,%al
c0100b43:	74 8c                	je     c0100ad1 <parse+0x1b>
c0100b45:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b48:	0f b6 00             	movzbl (%eax),%eax
c0100b4b:	0f be c0             	movsbl %al,%eax
c0100b4e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b52:	c7 04 24 94 93 10 c0 	movl   $0xc0109394,(%esp)
c0100b59:	e8 cb 82 00 00       	call   c0108e29 <strchr>
c0100b5e:	85 c0                	test   %eax,%eax
c0100b60:	74 d6                	je     c0100b38 <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b62:	e9 6a ff ff ff       	jmp    c0100ad1 <parse+0x1b>
            break;
c0100b67:	90                   	nop
        }
    }
    return argc;
c0100b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100b6b:	89 ec                	mov    %ebp,%esp
c0100b6d:	5d                   	pop    %ebp
c0100b6e:	c3                   	ret    

c0100b6f <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100b6f:	55                   	push   %ebp
c0100b70:	89 e5                	mov    %esp,%ebp
c0100b72:	83 ec 68             	sub    $0x68,%esp
c0100b75:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100b78:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100b7b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b7f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b82:	89 04 24             	mov    %eax,(%esp)
c0100b85:	e8 2c ff ff ff       	call   c0100ab6 <parse>
c0100b8a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100b8d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100b91:	75 0a                	jne    c0100b9d <runcmd+0x2e>
        return 0;
c0100b93:	b8 00 00 00 00       	mov    $0x0,%eax
c0100b98:	e9 83 00 00 00       	jmp    c0100c20 <runcmd+0xb1>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100b9d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100ba4:	eb 5a                	jmp    c0100c00 <runcmd+0x91>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100ba6:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0100ba9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c0100bac:	89 c8                	mov    %ecx,%eax
c0100bae:	01 c0                	add    %eax,%eax
c0100bb0:	01 c8                	add    %ecx,%eax
c0100bb2:	c1 e0 02             	shl    $0x2,%eax
c0100bb5:	05 00 30 12 c0       	add    $0xc0123000,%eax
c0100bba:	8b 00                	mov    (%eax),%eax
c0100bbc:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100bc0:	89 04 24             	mov    %eax,(%esp)
c0100bc3:	e8 c5 81 00 00       	call   c0108d8d <strcmp>
c0100bc8:	85 c0                	test   %eax,%eax
c0100bca:	75 31                	jne    c0100bfd <runcmd+0x8e>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100bcc:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100bcf:	89 d0                	mov    %edx,%eax
c0100bd1:	01 c0                	add    %eax,%eax
c0100bd3:	01 d0                	add    %edx,%eax
c0100bd5:	c1 e0 02             	shl    $0x2,%eax
c0100bd8:	05 08 30 12 c0       	add    $0xc0123008,%eax
c0100bdd:	8b 10                	mov    (%eax),%edx
c0100bdf:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100be2:	83 c0 04             	add    $0x4,%eax
c0100be5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100be8:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100bee:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100bf2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bf6:	89 1c 24             	mov    %ebx,(%esp)
c0100bf9:	ff d2                	call   *%edx
c0100bfb:	eb 23                	jmp    c0100c20 <runcmd+0xb1>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100bfd:	ff 45 f4             	incl   -0xc(%ebp)
c0100c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c03:	83 f8 02             	cmp    $0x2,%eax
c0100c06:	76 9e                	jbe    c0100ba6 <runcmd+0x37>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100c08:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100c0b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c0f:	c7 04 24 b7 93 10 c0 	movl   $0xc01093b7,(%esp)
c0100c16:	e8 4a f7 ff ff       	call   c0100365 <cprintf>
    return 0;
c0100c1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100c20:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100c23:	89 ec                	mov    %ebp,%esp
c0100c25:	5d                   	pop    %ebp
c0100c26:	c3                   	ret    

c0100c27 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100c27:	55                   	push   %ebp
c0100c28:	89 e5                	mov    %esp,%ebp
c0100c2a:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100c2d:	c7 04 24 d0 93 10 c0 	movl   $0xc01093d0,(%esp)
c0100c34:	e8 2c f7 ff ff       	call   c0100365 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100c39:	c7 04 24 f8 93 10 c0 	movl   $0xc01093f8,(%esp)
c0100c40:	e8 20 f7 ff ff       	call   c0100365 <cprintf>

    if (tf != NULL) {
c0100c45:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100c49:	74 0b                	je     c0100c56 <kmonitor+0x2f>
        print_trapframe(tf);
c0100c4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c4e:	89 04 24             	mov    %eax,(%esp)
c0100c51:	e8 2b 17 00 00       	call   c0102381 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100c56:	c7 04 24 1d 94 10 c0 	movl   $0xc010941d,(%esp)
c0100c5d:	e8 f4 f5 ff ff       	call   c0100256 <readline>
c0100c62:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100c65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100c69:	74 eb                	je     c0100c56 <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
c0100c6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c6e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c75:	89 04 24             	mov    %eax,(%esp)
c0100c78:	e8 f2 fe ff ff       	call   c0100b6f <runcmd>
c0100c7d:	85 c0                	test   %eax,%eax
c0100c7f:	78 02                	js     c0100c83 <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
c0100c81:	eb d3                	jmp    c0100c56 <kmonitor+0x2f>
                break;
c0100c83:	90                   	nop
            }
        }
    }
}
c0100c84:	90                   	nop
c0100c85:	89 ec                	mov    %ebp,%esp
c0100c87:	5d                   	pop    %ebp
c0100c88:	c3                   	ret    

c0100c89 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100c89:	55                   	push   %ebp
c0100c8a:	89 e5                	mov    %esp,%ebp
c0100c8c:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c8f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c96:	eb 3d                	jmp    c0100cd5 <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100c98:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c9b:	89 d0                	mov    %edx,%eax
c0100c9d:	01 c0                	add    %eax,%eax
c0100c9f:	01 d0                	add    %edx,%eax
c0100ca1:	c1 e0 02             	shl    $0x2,%eax
c0100ca4:	05 04 30 12 c0       	add    $0xc0123004,%eax
c0100ca9:	8b 10                	mov    (%eax),%edx
c0100cab:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c0100cae:	89 c8                	mov    %ecx,%eax
c0100cb0:	01 c0                	add    %eax,%eax
c0100cb2:	01 c8                	add    %ecx,%eax
c0100cb4:	c1 e0 02             	shl    $0x2,%eax
c0100cb7:	05 00 30 12 c0       	add    $0xc0123000,%eax
c0100cbc:	8b 00                	mov    (%eax),%eax
c0100cbe:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100cc2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cc6:	c7 04 24 21 94 10 c0 	movl   $0xc0109421,(%esp)
c0100ccd:	e8 93 f6 ff ff       	call   c0100365 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100cd2:	ff 45 f4             	incl   -0xc(%ebp)
c0100cd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cd8:	83 f8 02             	cmp    $0x2,%eax
c0100cdb:	76 bb                	jbe    c0100c98 <mon_help+0xf>
    }
    return 0;
c0100cdd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ce2:	89 ec                	mov    %ebp,%esp
c0100ce4:	5d                   	pop    %ebp
c0100ce5:	c3                   	ret    

c0100ce6 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100ce6:	55                   	push   %ebp
c0100ce7:	89 e5                	mov    %esp,%ebp
c0100ce9:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100cec:	e8 97 fb ff ff       	call   c0100888 <print_kerninfo>
    return 0;
c0100cf1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cf6:	89 ec                	mov    %ebp,%esp
c0100cf8:	5d                   	pop    %ebp
c0100cf9:	c3                   	ret    

c0100cfa <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100cfa:	55                   	push   %ebp
c0100cfb:	89 e5                	mov    %esp,%ebp
c0100cfd:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100d00:	e8 cf fc ff ff       	call   c01009d4 <print_stackframe>
    return 0;
c0100d05:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d0a:	89 ec                	mov    %ebp,%esp
c0100d0c:	5d                   	pop    %ebp
c0100d0d:	c3                   	ret    

c0100d0e <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100d0e:	55                   	push   %ebp
c0100d0f:	89 e5                	mov    %esp,%ebp
c0100d11:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100d14:	a1 20 64 12 c0       	mov    0xc0126420,%eax
c0100d19:	85 c0                	test   %eax,%eax
c0100d1b:	75 5b                	jne    c0100d78 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
c0100d1d:	c7 05 20 64 12 c0 01 	movl   $0x1,0xc0126420
c0100d24:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100d27:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100d2d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d30:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d34:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d37:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d3b:	c7 04 24 2a 94 10 c0 	movl   $0xc010942a,(%esp)
c0100d42:	e8 1e f6 ff ff       	call   c0100365 <cprintf>
    vcprintf(fmt, ap);
c0100d47:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d4a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d4e:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d51:	89 04 24             	mov    %eax,(%esp)
c0100d54:	e8 d7 f5 ff ff       	call   c0100330 <vcprintf>
    cprintf("\n");
c0100d59:	c7 04 24 46 94 10 c0 	movl   $0xc0109446,(%esp)
c0100d60:	e8 00 f6 ff ff       	call   c0100365 <cprintf>
    
    cprintf("stack trackback:\n");
c0100d65:	c7 04 24 48 94 10 c0 	movl   $0xc0109448,(%esp)
c0100d6c:	e8 f4 f5 ff ff       	call   c0100365 <cprintf>
    print_stackframe();
c0100d71:	e8 5e fc ff ff       	call   c01009d4 <print_stackframe>
c0100d76:	eb 01                	jmp    c0100d79 <__panic+0x6b>
        goto panic_dead;
c0100d78:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100d79:	e8 46 12 00 00       	call   c0101fc4 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100d7e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100d85:	e8 9d fe ff ff       	call   c0100c27 <kmonitor>
c0100d8a:	eb f2                	jmp    c0100d7e <__panic+0x70>

c0100d8c <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100d8c:	55                   	push   %ebp
c0100d8d:	89 e5                	mov    %esp,%ebp
c0100d8f:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100d92:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d95:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100d98:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d9b:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d9f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100da2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100da6:	c7 04 24 5a 94 10 c0 	movl   $0xc010945a,(%esp)
c0100dad:	e8 b3 f5 ff ff       	call   c0100365 <cprintf>
    vcprintf(fmt, ap);
c0100db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100db5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100db9:	8b 45 10             	mov    0x10(%ebp),%eax
c0100dbc:	89 04 24             	mov    %eax,(%esp)
c0100dbf:	e8 6c f5 ff ff       	call   c0100330 <vcprintf>
    cprintf("\n");
c0100dc4:	c7 04 24 46 94 10 c0 	movl   $0xc0109446,(%esp)
c0100dcb:	e8 95 f5 ff ff       	call   c0100365 <cprintf>
    va_end(ap);
}
c0100dd0:	90                   	nop
c0100dd1:	89 ec                	mov    %ebp,%esp
c0100dd3:	5d                   	pop    %ebp
c0100dd4:	c3                   	ret    

c0100dd5 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100dd5:	55                   	push   %ebp
c0100dd6:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100dd8:	a1 20 64 12 c0       	mov    0xc0126420,%eax
}
c0100ddd:	5d                   	pop    %ebp
c0100dde:	c3                   	ret    

c0100ddf <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100ddf:	55                   	push   %ebp
c0100de0:	89 e5                	mov    %esp,%ebp
c0100de2:	83 ec 28             	sub    $0x28,%esp
c0100de5:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
c0100deb:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100def:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100df3:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100df7:	ee                   	out    %al,(%dx)
}
c0100df8:	90                   	nop
c0100df9:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100dff:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e03:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100e07:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100e0b:	ee                   	out    %al,(%dx)
}
c0100e0c:	90                   	nop
c0100e0d:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
c0100e13:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e17:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100e1b:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100e1f:	ee                   	out    %al,(%dx)
}
c0100e20:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100e21:	c7 05 24 64 12 c0 00 	movl   $0x0,0xc0126424
c0100e28:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100e2b:	c7 04 24 78 94 10 c0 	movl   $0xc0109478,(%esp)
c0100e32:	e8 2e f5 ff ff       	call   c0100365 <cprintf>
    pic_enable(IRQ_TIMER);
c0100e37:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100e3e:	e8 e6 11 00 00       	call   c0102029 <pic_enable>
}
c0100e43:	90                   	nop
c0100e44:	89 ec                	mov    %ebp,%esp
c0100e46:	5d                   	pop    %ebp
c0100e47:	c3                   	ret    

c0100e48 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100e48:	55                   	push   %ebp
c0100e49:	89 e5                	mov    %esp,%ebp
c0100e4b:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100e4e:	9c                   	pushf  
c0100e4f:	58                   	pop    %eax
c0100e50:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100e56:	25 00 02 00 00       	and    $0x200,%eax
c0100e5b:	85 c0                	test   %eax,%eax
c0100e5d:	74 0c                	je     c0100e6b <__intr_save+0x23>
        intr_disable();
c0100e5f:	e8 60 11 00 00       	call   c0101fc4 <intr_disable>
        return 1;
c0100e64:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e69:	eb 05                	jmp    c0100e70 <__intr_save+0x28>
    }
    return 0;
c0100e6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e70:	89 ec                	mov    %ebp,%esp
c0100e72:	5d                   	pop    %ebp
c0100e73:	c3                   	ret    

c0100e74 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e74:	55                   	push   %ebp
c0100e75:	89 e5                	mov    %esp,%ebp
c0100e77:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e7a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e7e:	74 05                	je     c0100e85 <__intr_restore+0x11>
        intr_enable();
c0100e80:	e8 37 11 00 00       	call   c0101fbc <intr_enable>
    }
}
c0100e85:	90                   	nop
c0100e86:	89 ec                	mov    %ebp,%esp
c0100e88:	5d                   	pop    %ebp
c0100e89:	c3                   	ret    

c0100e8a <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e8a:	55                   	push   %ebp
c0100e8b:	89 e5                	mov    %esp,%ebp
c0100e8d:	83 ec 10             	sub    $0x10,%esp
c0100e90:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e96:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100e9a:	89 c2                	mov    %eax,%edx
c0100e9c:	ec                   	in     (%dx),%al
c0100e9d:	88 45 f1             	mov    %al,-0xf(%ebp)
c0100ea0:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100ea6:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100eaa:	89 c2                	mov    %eax,%edx
c0100eac:	ec                   	in     (%dx),%al
c0100ead:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100eb0:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100eb6:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100eba:	89 c2                	mov    %eax,%edx
c0100ebc:	ec                   	in     (%dx),%al
c0100ebd:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100ec0:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
c0100ec6:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100eca:	89 c2                	mov    %eax,%edx
c0100ecc:	ec                   	in     (%dx),%al
c0100ecd:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100ed0:	90                   	nop
c0100ed1:	89 ec                	mov    %ebp,%esp
c0100ed3:	5d                   	pop    %ebp
c0100ed4:	c3                   	ret    

c0100ed5 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100ed5:	55                   	push   %ebp
c0100ed6:	89 e5                	mov    %esp,%ebp
c0100ed8:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100edb:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100ee2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ee5:	0f b7 00             	movzwl (%eax),%eax
c0100ee8:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100eec:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eef:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100ef4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ef7:	0f b7 00             	movzwl (%eax),%eax
c0100efa:	0f b7 c0             	movzwl %ax,%eax
c0100efd:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c0100f02:	74 12                	je     c0100f16 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100f04:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100f0b:	66 c7 05 46 64 12 c0 	movw   $0x3b4,0xc0126446
c0100f12:	b4 03 
c0100f14:	eb 13                	jmp    c0100f29 <cga_init+0x54>
    } else {
        *cp = was;
c0100f16:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f19:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100f1d:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100f20:	66 c7 05 46 64 12 c0 	movw   $0x3d4,0xc0126446
c0100f27:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100f29:	0f b7 05 46 64 12 c0 	movzwl 0xc0126446,%eax
c0100f30:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0100f34:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f38:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100f3c:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100f40:	ee                   	out    %al,(%dx)
}
c0100f41:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;
c0100f42:	0f b7 05 46 64 12 c0 	movzwl 0xc0126446,%eax
c0100f49:	40                   	inc    %eax
c0100f4a:	0f b7 c0             	movzwl %ax,%eax
c0100f4d:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f51:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f55:	89 c2                	mov    %eax,%edx
c0100f57:	ec                   	in     (%dx),%al
c0100f58:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
c0100f5b:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f5f:	0f b6 c0             	movzbl %al,%eax
c0100f62:	c1 e0 08             	shl    $0x8,%eax
c0100f65:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f68:	0f b7 05 46 64 12 c0 	movzwl 0xc0126446,%eax
c0100f6f:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0100f73:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f77:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f7b:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100f7f:	ee                   	out    %al,(%dx)
}
c0100f80:	90                   	nop
    pos |= inb(addr_6845 + 1);
c0100f81:	0f b7 05 46 64 12 c0 	movzwl 0xc0126446,%eax
c0100f88:	40                   	inc    %eax
c0100f89:	0f b7 c0             	movzwl %ax,%eax
c0100f8c:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f90:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100f94:	89 c2                	mov    %eax,%edx
c0100f96:	ec                   	in     (%dx),%al
c0100f97:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
c0100f9a:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100f9e:	0f b6 c0             	movzbl %al,%eax
c0100fa1:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100fa4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100fa7:	a3 40 64 12 c0       	mov    %eax,0xc0126440
    crt_pos = pos;
c0100fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100faf:	0f b7 c0             	movzwl %ax,%eax
c0100fb2:	66 a3 44 64 12 c0    	mov    %ax,0xc0126444
}
c0100fb8:	90                   	nop
c0100fb9:	89 ec                	mov    %ebp,%esp
c0100fbb:	5d                   	pop    %ebp
c0100fbc:	c3                   	ret    

c0100fbd <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100fbd:	55                   	push   %ebp
c0100fbe:	89 e5                	mov    %esp,%ebp
c0100fc0:	83 ec 48             	sub    $0x48,%esp
c0100fc3:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
c0100fc9:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fcd:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0100fd1:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0100fd5:	ee                   	out    %al,(%dx)
}
c0100fd6:	90                   	nop
c0100fd7:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
c0100fdd:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fe1:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0100fe5:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0100fe9:	ee                   	out    %al,(%dx)
}
c0100fea:	90                   	nop
c0100feb:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
c0100ff1:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ff5:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0100ff9:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0100ffd:	ee                   	out    %al,(%dx)
}
c0100ffe:	90                   	nop
c0100fff:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0101005:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101009:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c010100d:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101011:	ee                   	out    %al,(%dx)
}
c0101012:	90                   	nop
c0101013:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
c0101019:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010101d:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101021:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101025:	ee                   	out    %al,(%dx)
}
c0101026:	90                   	nop
c0101027:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
c010102d:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101031:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101035:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101039:	ee                   	out    %al,(%dx)
}
c010103a:	90                   	nop
c010103b:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0101041:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101045:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101049:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010104d:	ee                   	out    %al,(%dx)
}
c010104e:	90                   	nop
c010104f:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101055:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0101059:	89 c2                	mov    %eax,%edx
c010105b:	ec                   	in     (%dx),%al
c010105c:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c010105f:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0101063:	3c ff                	cmp    $0xff,%al
c0101065:	0f 95 c0             	setne  %al
c0101068:	0f b6 c0             	movzbl %al,%eax
c010106b:	a3 48 64 12 c0       	mov    %eax,0xc0126448
c0101070:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101076:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010107a:	89 c2                	mov    %eax,%edx
c010107c:	ec                   	in     (%dx),%al
c010107d:	88 45 f1             	mov    %al,-0xf(%ebp)
c0101080:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101086:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010108a:	89 c2                	mov    %eax,%edx
c010108c:	ec                   	in     (%dx),%al
c010108d:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101090:	a1 48 64 12 c0       	mov    0xc0126448,%eax
c0101095:	85 c0                	test   %eax,%eax
c0101097:	74 0c                	je     c01010a5 <serial_init+0xe8>
        pic_enable(IRQ_COM1);
c0101099:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01010a0:	e8 84 0f 00 00       	call   c0102029 <pic_enable>
    }
}
c01010a5:	90                   	nop
c01010a6:	89 ec                	mov    %ebp,%esp
c01010a8:	5d                   	pop    %ebp
c01010a9:	c3                   	ret    

c01010aa <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c01010aa:	55                   	push   %ebp
c01010ab:	89 e5                	mov    %esp,%ebp
c01010ad:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01010b0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01010b7:	eb 08                	jmp    c01010c1 <lpt_putc_sub+0x17>
        delay();
c01010b9:	e8 cc fd ff ff       	call   c0100e8a <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01010be:	ff 45 fc             	incl   -0x4(%ebp)
c01010c1:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c01010c7:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01010cb:	89 c2                	mov    %eax,%edx
c01010cd:	ec                   	in     (%dx),%al
c01010ce:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01010d1:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01010d5:	84 c0                	test   %al,%al
c01010d7:	78 09                	js     c01010e2 <lpt_putc_sub+0x38>
c01010d9:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01010e0:	7e d7                	jle    c01010b9 <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
c01010e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01010e5:	0f b6 c0             	movzbl %al,%eax
c01010e8:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
c01010ee:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010f1:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01010f5:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01010f9:	ee                   	out    %al,(%dx)
}
c01010fa:	90                   	nop
c01010fb:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c0101101:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101105:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101109:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010110d:	ee                   	out    %al,(%dx)
}
c010110e:	90                   	nop
c010110f:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c0101115:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101119:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010111d:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101121:	ee                   	out    %al,(%dx)
}
c0101122:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c0101123:	90                   	nop
c0101124:	89 ec                	mov    %ebp,%esp
c0101126:	5d                   	pop    %ebp
c0101127:	c3                   	ret    

c0101128 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c0101128:	55                   	push   %ebp
c0101129:	89 e5                	mov    %esp,%ebp
c010112b:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c010112e:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101132:	74 0d                	je     c0101141 <lpt_putc+0x19>
        lpt_putc_sub(c);
c0101134:	8b 45 08             	mov    0x8(%ebp),%eax
c0101137:	89 04 24             	mov    %eax,(%esp)
c010113a:	e8 6b ff ff ff       	call   c01010aa <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c010113f:	eb 24                	jmp    c0101165 <lpt_putc+0x3d>
        lpt_putc_sub('\b');
c0101141:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101148:	e8 5d ff ff ff       	call   c01010aa <lpt_putc_sub>
        lpt_putc_sub(' ');
c010114d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101154:	e8 51 ff ff ff       	call   c01010aa <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101159:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101160:	e8 45 ff ff ff       	call   c01010aa <lpt_putc_sub>
}
c0101165:	90                   	nop
c0101166:	89 ec                	mov    %ebp,%esp
c0101168:	5d                   	pop    %ebp
c0101169:	c3                   	ret    

c010116a <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c010116a:	55                   	push   %ebp
c010116b:	89 e5                	mov    %esp,%ebp
c010116d:	83 ec 38             	sub    $0x38,%esp
c0101170:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    // set black on white
    if (!(c & ~0xFF)) {
c0101173:	8b 45 08             	mov    0x8(%ebp),%eax
c0101176:	25 00 ff ff ff       	and    $0xffffff00,%eax
c010117b:	85 c0                	test   %eax,%eax
c010117d:	75 07                	jne    c0101186 <cga_putc+0x1c>
        c |= 0x0700;
c010117f:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101186:	8b 45 08             	mov    0x8(%ebp),%eax
c0101189:	0f b6 c0             	movzbl %al,%eax
c010118c:	83 f8 0d             	cmp    $0xd,%eax
c010118f:	74 72                	je     c0101203 <cga_putc+0x99>
c0101191:	83 f8 0d             	cmp    $0xd,%eax
c0101194:	0f 8f a3 00 00 00    	jg     c010123d <cga_putc+0xd3>
c010119a:	83 f8 08             	cmp    $0x8,%eax
c010119d:	74 0a                	je     c01011a9 <cga_putc+0x3f>
c010119f:	83 f8 0a             	cmp    $0xa,%eax
c01011a2:	74 4c                	je     c01011f0 <cga_putc+0x86>
c01011a4:	e9 94 00 00 00       	jmp    c010123d <cga_putc+0xd3>
    case '\b':
        if (crt_pos > 0) {
c01011a9:	0f b7 05 44 64 12 c0 	movzwl 0xc0126444,%eax
c01011b0:	85 c0                	test   %eax,%eax
c01011b2:	0f 84 af 00 00 00    	je     c0101267 <cga_putc+0xfd>
            crt_pos --;
c01011b8:	0f b7 05 44 64 12 c0 	movzwl 0xc0126444,%eax
c01011bf:	48                   	dec    %eax
c01011c0:	0f b7 c0             	movzwl %ax,%eax
c01011c3:	66 a3 44 64 12 c0    	mov    %ax,0xc0126444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c01011c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01011cc:	98                   	cwtl   
c01011cd:	25 00 ff ff ff       	and    $0xffffff00,%eax
c01011d2:	98                   	cwtl   
c01011d3:	83 c8 20             	or     $0x20,%eax
c01011d6:	98                   	cwtl   
c01011d7:	8b 0d 40 64 12 c0    	mov    0xc0126440,%ecx
c01011dd:	0f b7 15 44 64 12 c0 	movzwl 0xc0126444,%edx
c01011e4:	01 d2                	add    %edx,%edx
c01011e6:	01 ca                	add    %ecx,%edx
c01011e8:	0f b7 c0             	movzwl %ax,%eax
c01011eb:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c01011ee:	eb 77                	jmp    c0101267 <cga_putc+0xfd>
    case '\n':
        crt_pos += CRT_COLS;
c01011f0:	0f b7 05 44 64 12 c0 	movzwl 0xc0126444,%eax
c01011f7:	83 c0 50             	add    $0x50,%eax
c01011fa:	0f b7 c0             	movzwl %ax,%eax
c01011fd:	66 a3 44 64 12 c0    	mov    %ax,0xc0126444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101203:	0f b7 1d 44 64 12 c0 	movzwl 0xc0126444,%ebx
c010120a:	0f b7 0d 44 64 12 c0 	movzwl 0xc0126444,%ecx
c0101211:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c0101216:	89 c8                	mov    %ecx,%eax
c0101218:	f7 e2                	mul    %edx
c010121a:	c1 ea 06             	shr    $0x6,%edx
c010121d:	89 d0                	mov    %edx,%eax
c010121f:	c1 e0 02             	shl    $0x2,%eax
c0101222:	01 d0                	add    %edx,%eax
c0101224:	c1 e0 04             	shl    $0x4,%eax
c0101227:	29 c1                	sub    %eax,%ecx
c0101229:	89 ca                	mov    %ecx,%edx
c010122b:	0f b7 d2             	movzwl %dx,%edx
c010122e:	89 d8                	mov    %ebx,%eax
c0101230:	29 d0                	sub    %edx,%eax
c0101232:	0f b7 c0             	movzwl %ax,%eax
c0101235:	66 a3 44 64 12 c0    	mov    %ax,0xc0126444
        break;
c010123b:	eb 2b                	jmp    c0101268 <cga_putc+0xfe>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c010123d:	8b 0d 40 64 12 c0    	mov    0xc0126440,%ecx
c0101243:	0f b7 05 44 64 12 c0 	movzwl 0xc0126444,%eax
c010124a:	8d 50 01             	lea    0x1(%eax),%edx
c010124d:	0f b7 d2             	movzwl %dx,%edx
c0101250:	66 89 15 44 64 12 c0 	mov    %dx,0xc0126444
c0101257:	01 c0                	add    %eax,%eax
c0101259:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c010125c:	8b 45 08             	mov    0x8(%ebp),%eax
c010125f:	0f b7 c0             	movzwl %ax,%eax
c0101262:	66 89 02             	mov    %ax,(%edx)
        break;
c0101265:	eb 01                	jmp    c0101268 <cga_putc+0xfe>
        break;
c0101267:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101268:	0f b7 05 44 64 12 c0 	movzwl 0xc0126444,%eax
c010126f:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c0101274:	76 5e                	jbe    c01012d4 <cga_putc+0x16a>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101276:	a1 40 64 12 c0       	mov    0xc0126440,%eax
c010127b:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101281:	a1 40 64 12 c0       	mov    0xc0126440,%eax
c0101286:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c010128d:	00 
c010128e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101292:	89 04 24             	mov    %eax,(%esp)
c0101295:	e8 8d 7d 00 00       	call   c0109027 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c010129a:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c01012a1:	eb 15                	jmp    c01012b8 <cga_putc+0x14e>
            crt_buf[i] = 0x0700 | ' ';
c01012a3:	8b 15 40 64 12 c0    	mov    0xc0126440,%edx
c01012a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01012ac:	01 c0                	add    %eax,%eax
c01012ae:	01 d0                	add    %edx,%eax
c01012b0:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c01012b5:	ff 45 f4             	incl   -0xc(%ebp)
c01012b8:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c01012bf:	7e e2                	jle    c01012a3 <cga_putc+0x139>
        }
        crt_pos -= CRT_COLS;
c01012c1:	0f b7 05 44 64 12 c0 	movzwl 0xc0126444,%eax
c01012c8:	83 e8 50             	sub    $0x50,%eax
c01012cb:	0f b7 c0             	movzwl %ax,%eax
c01012ce:	66 a3 44 64 12 c0    	mov    %ax,0xc0126444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c01012d4:	0f b7 05 46 64 12 c0 	movzwl 0xc0126446,%eax
c01012db:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c01012df:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01012e3:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01012e7:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012eb:	ee                   	out    %al,(%dx)
}
c01012ec:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
c01012ed:	0f b7 05 44 64 12 c0 	movzwl 0xc0126444,%eax
c01012f4:	c1 e8 08             	shr    $0x8,%eax
c01012f7:	0f b7 c0             	movzwl %ax,%eax
c01012fa:	0f b6 c0             	movzbl %al,%eax
c01012fd:	0f b7 15 46 64 12 c0 	movzwl 0xc0126446,%edx
c0101304:	42                   	inc    %edx
c0101305:	0f b7 d2             	movzwl %dx,%edx
c0101308:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c010130c:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010130f:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101313:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101317:	ee                   	out    %al,(%dx)
}
c0101318:	90                   	nop
    outb(addr_6845, 15);
c0101319:	0f b7 05 46 64 12 c0 	movzwl 0xc0126446,%eax
c0101320:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101324:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101328:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010132c:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101330:	ee                   	out    %al,(%dx)
}
c0101331:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
c0101332:	0f b7 05 44 64 12 c0 	movzwl 0xc0126444,%eax
c0101339:	0f b6 c0             	movzbl %al,%eax
c010133c:	0f b7 15 46 64 12 c0 	movzwl 0xc0126446,%edx
c0101343:	42                   	inc    %edx
c0101344:	0f b7 d2             	movzwl %dx,%edx
c0101347:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
c010134b:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010134e:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101352:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101356:	ee                   	out    %al,(%dx)
}
c0101357:	90                   	nop
}
c0101358:	90                   	nop
c0101359:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010135c:	89 ec                	mov    %ebp,%esp
c010135e:	5d                   	pop    %ebp
c010135f:	c3                   	ret    

c0101360 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0101360:	55                   	push   %ebp
c0101361:	89 e5                	mov    %esp,%ebp
c0101363:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101366:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010136d:	eb 08                	jmp    c0101377 <serial_putc_sub+0x17>
        delay();
c010136f:	e8 16 fb ff ff       	call   c0100e8a <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101374:	ff 45 fc             	incl   -0x4(%ebp)
c0101377:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010137d:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101381:	89 c2                	mov    %eax,%edx
c0101383:	ec                   	in     (%dx),%al
c0101384:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101387:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010138b:	0f b6 c0             	movzbl %al,%eax
c010138e:	83 e0 20             	and    $0x20,%eax
c0101391:	85 c0                	test   %eax,%eax
c0101393:	75 09                	jne    c010139e <serial_putc_sub+0x3e>
c0101395:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c010139c:	7e d1                	jle    c010136f <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
c010139e:	8b 45 08             	mov    0x8(%ebp),%eax
c01013a1:	0f b6 c0             	movzbl %al,%eax
c01013a4:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c01013aa:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01013ad:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01013b1:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01013b5:	ee                   	out    %al,(%dx)
}
c01013b6:	90                   	nop
}
c01013b7:	90                   	nop
c01013b8:	89 ec                	mov    %ebp,%esp
c01013ba:	5d                   	pop    %ebp
c01013bb:	c3                   	ret    

c01013bc <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c01013bc:	55                   	push   %ebp
c01013bd:	89 e5                	mov    %esp,%ebp
c01013bf:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01013c2:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01013c6:	74 0d                	je     c01013d5 <serial_putc+0x19>
        serial_putc_sub(c);
c01013c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01013cb:	89 04 24             	mov    %eax,(%esp)
c01013ce:	e8 8d ff ff ff       	call   c0101360 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c01013d3:	eb 24                	jmp    c01013f9 <serial_putc+0x3d>
        serial_putc_sub('\b');
c01013d5:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01013dc:	e8 7f ff ff ff       	call   c0101360 <serial_putc_sub>
        serial_putc_sub(' ');
c01013e1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01013e8:	e8 73 ff ff ff       	call   c0101360 <serial_putc_sub>
        serial_putc_sub('\b');
c01013ed:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01013f4:	e8 67 ff ff ff       	call   c0101360 <serial_putc_sub>
}
c01013f9:	90                   	nop
c01013fa:	89 ec                	mov    %ebp,%esp
c01013fc:	5d                   	pop    %ebp
c01013fd:	c3                   	ret    

c01013fe <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c01013fe:	55                   	push   %ebp
c01013ff:	89 e5                	mov    %esp,%ebp
c0101401:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101404:	eb 33                	jmp    c0101439 <cons_intr+0x3b>
        if (c != 0) {
c0101406:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010140a:	74 2d                	je     c0101439 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c010140c:	a1 64 66 12 c0       	mov    0xc0126664,%eax
c0101411:	8d 50 01             	lea    0x1(%eax),%edx
c0101414:	89 15 64 66 12 c0    	mov    %edx,0xc0126664
c010141a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010141d:	88 90 60 64 12 c0    	mov    %dl,-0x3fed9ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101423:	a1 64 66 12 c0       	mov    0xc0126664,%eax
c0101428:	3d 00 02 00 00       	cmp    $0x200,%eax
c010142d:	75 0a                	jne    c0101439 <cons_intr+0x3b>
                cons.wpos = 0;
c010142f:	c7 05 64 66 12 c0 00 	movl   $0x0,0xc0126664
c0101436:	00 00 00 
    while ((c = (*proc)()) != -1) {
c0101439:	8b 45 08             	mov    0x8(%ebp),%eax
c010143c:	ff d0                	call   *%eax
c010143e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101441:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101445:	75 bf                	jne    c0101406 <cons_intr+0x8>
            }
        }
    }
}
c0101447:	90                   	nop
c0101448:	90                   	nop
c0101449:	89 ec                	mov    %ebp,%esp
c010144b:	5d                   	pop    %ebp
c010144c:	c3                   	ret    

c010144d <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c010144d:	55                   	push   %ebp
c010144e:	89 e5                	mov    %esp,%ebp
c0101450:	83 ec 10             	sub    $0x10,%esp
c0101453:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101459:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010145d:	89 c2                	mov    %eax,%edx
c010145f:	ec                   	in     (%dx),%al
c0101460:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101463:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0101467:	0f b6 c0             	movzbl %al,%eax
c010146a:	83 e0 01             	and    $0x1,%eax
c010146d:	85 c0                	test   %eax,%eax
c010146f:	75 07                	jne    c0101478 <serial_proc_data+0x2b>
        return -1;
c0101471:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101476:	eb 2a                	jmp    c01014a2 <serial_proc_data+0x55>
c0101478:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010147e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101482:	89 c2                	mov    %eax,%edx
c0101484:	ec                   	in     (%dx),%al
c0101485:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0101488:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c010148c:	0f b6 c0             	movzbl %al,%eax
c010148f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101492:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101496:	75 07                	jne    c010149f <serial_proc_data+0x52>
        c = '\b';
c0101498:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c010149f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01014a2:	89 ec                	mov    %ebp,%esp
c01014a4:	5d                   	pop    %ebp
c01014a5:	c3                   	ret    

c01014a6 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c01014a6:	55                   	push   %ebp
c01014a7:	89 e5                	mov    %esp,%ebp
c01014a9:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c01014ac:	a1 48 64 12 c0       	mov    0xc0126448,%eax
c01014b1:	85 c0                	test   %eax,%eax
c01014b3:	74 0c                	je     c01014c1 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c01014b5:	c7 04 24 4d 14 10 c0 	movl   $0xc010144d,(%esp)
c01014bc:	e8 3d ff ff ff       	call   c01013fe <cons_intr>
    }
}
c01014c1:	90                   	nop
c01014c2:	89 ec                	mov    %ebp,%esp
c01014c4:	5d                   	pop    %ebp
c01014c5:	c3                   	ret    

c01014c6 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c01014c6:	55                   	push   %ebp
c01014c7:	89 e5                	mov    %esp,%ebp
c01014c9:	83 ec 38             	sub    $0x38,%esp
c01014cc:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01014d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01014d5:	89 c2                	mov    %eax,%edx
c01014d7:	ec                   	in     (%dx),%al
c01014d8:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c01014db:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c01014df:	0f b6 c0             	movzbl %al,%eax
c01014e2:	83 e0 01             	and    $0x1,%eax
c01014e5:	85 c0                	test   %eax,%eax
c01014e7:	75 0a                	jne    c01014f3 <kbd_proc_data+0x2d>
        return -1;
c01014e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01014ee:	e9 56 01 00 00       	jmp    c0101649 <kbd_proc_data+0x183>
c01014f3:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01014f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01014fc:	89 c2                	mov    %eax,%edx
c01014fe:	ec                   	in     (%dx),%al
c01014ff:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101502:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101506:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101509:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c010150d:	75 17                	jne    c0101526 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
c010150f:	a1 68 66 12 c0       	mov    0xc0126668,%eax
c0101514:	83 c8 40             	or     $0x40,%eax
c0101517:	a3 68 66 12 c0       	mov    %eax,0xc0126668
        return 0;
c010151c:	b8 00 00 00 00       	mov    $0x0,%eax
c0101521:	e9 23 01 00 00       	jmp    c0101649 <kbd_proc_data+0x183>
    } else if (data & 0x80) {
c0101526:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010152a:	84 c0                	test   %al,%al
c010152c:	79 45                	jns    c0101573 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c010152e:	a1 68 66 12 c0       	mov    0xc0126668,%eax
c0101533:	83 e0 40             	and    $0x40,%eax
c0101536:	85 c0                	test   %eax,%eax
c0101538:	75 08                	jne    c0101542 <kbd_proc_data+0x7c>
c010153a:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010153e:	24 7f                	and    $0x7f,%al
c0101540:	eb 04                	jmp    c0101546 <kbd_proc_data+0x80>
c0101542:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101546:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0101549:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010154d:	0f b6 80 40 30 12 c0 	movzbl -0x3fedcfc0(%eax),%eax
c0101554:	0c 40                	or     $0x40,%al
c0101556:	0f b6 c0             	movzbl %al,%eax
c0101559:	f7 d0                	not    %eax
c010155b:	89 c2                	mov    %eax,%edx
c010155d:	a1 68 66 12 c0       	mov    0xc0126668,%eax
c0101562:	21 d0                	and    %edx,%eax
c0101564:	a3 68 66 12 c0       	mov    %eax,0xc0126668
        return 0;
c0101569:	b8 00 00 00 00       	mov    $0x0,%eax
c010156e:	e9 d6 00 00 00       	jmp    c0101649 <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
c0101573:	a1 68 66 12 c0       	mov    0xc0126668,%eax
c0101578:	83 e0 40             	and    $0x40,%eax
c010157b:	85 c0                	test   %eax,%eax
c010157d:	74 11                	je     c0101590 <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c010157f:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101583:	a1 68 66 12 c0       	mov    0xc0126668,%eax
c0101588:	83 e0 bf             	and    $0xffffffbf,%eax
c010158b:	a3 68 66 12 c0       	mov    %eax,0xc0126668
    }

    shift |= shiftcode[data];
c0101590:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101594:	0f b6 80 40 30 12 c0 	movzbl -0x3fedcfc0(%eax),%eax
c010159b:	0f b6 d0             	movzbl %al,%edx
c010159e:	a1 68 66 12 c0       	mov    0xc0126668,%eax
c01015a3:	09 d0                	or     %edx,%eax
c01015a5:	a3 68 66 12 c0       	mov    %eax,0xc0126668
    shift ^= togglecode[data];
c01015aa:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015ae:	0f b6 80 40 31 12 c0 	movzbl -0x3fedcec0(%eax),%eax
c01015b5:	0f b6 d0             	movzbl %al,%edx
c01015b8:	a1 68 66 12 c0       	mov    0xc0126668,%eax
c01015bd:	31 d0                	xor    %edx,%eax
c01015bf:	a3 68 66 12 c0       	mov    %eax,0xc0126668

    c = charcode[shift & (CTL | SHIFT)][data];
c01015c4:	a1 68 66 12 c0       	mov    0xc0126668,%eax
c01015c9:	83 e0 03             	and    $0x3,%eax
c01015cc:	8b 14 85 40 35 12 c0 	mov    -0x3fedcac0(,%eax,4),%edx
c01015d3:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015d7:	01 d0                	add    %edx,%eax
c01015d9:	0f b6 00             	movzbl (%eax),%eax
c01015dc:	0f b6 c0             	movzbl %al,%eax
c01015df:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c01015e2:	a1 68 66 12 c0       	mov    0xc0126668,%eax
c01015e7:	83 e0 08             	and    $0x8,%eax
c01015ea:	85 c0                	test   %eax,%eax
c01015ec:	74 22                	je     c0101610 <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
c01015ee:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c01015f2:	7e 0c                	jle    c0101600 <kbd_proc_data+0x13a>
c01015f4:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c01015f8:	7f 06                	jg     c0101600 <kbd_proc_data+0x13a>
            c += 'A' - 'a';
c01015fa:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c01015fe:	eb 10                	jmp    c0101610 <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
c0101600:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101604:	7e 0a                	jle    c0101610 <kbd_proc_data+0x14a>
c0101606:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c010160a:	7f 04                	jg     c0101610 <kbd_proc_data+0x14a>
            c += 'a' - 'A';
c010160c:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101610:	a1 68 66 12 c0       	mov    0xc0126668,%eax
c0101615:	f7 d0                	not    %eax
c0101617:	83 e0 06             	and    $0x6,%eax
c010161a:	85 c0                	test   %eax,%eax
c010161c:	75 28                	jne    c0101646 <kbd_proc_data+0x180>
c010161e:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101625:	75 1f                	jne    c0101646 <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
c0101627:	c7 04 24 93 94 10 c0 	movl   $0xc0109493,(%esp)
c010162e:	e8 32 ed ff ff       	call   c0100365 <cprintf>
c0101633:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c0101639:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010163d:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c0101641:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0101644:	ee                   	out    %al,(%dx)
}
c0101645:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0101646:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101649:	89 ec                	mov    %ebp,%esp
c010164b:	5d                   	pop    %ebp
c010164c:	c3                   	ret    

c010164d <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c010164d:	55                   	push   %ebp
c010164e:	89 e5                	mov    %esp,%ebp
c0101650:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c0101653:	c7 04 24 c6 14 10 c0 	movl   $0xc01014c6,(%esp)
c010165a:	e8 9f fd ff ff       	call   c01013fe <cons_intr>
}
c010165f:	90                   	nop
c0101660:	89 ec                	mov    %ebp,%esp
c0101662:	5d                   	pop    %ebp
c0101663:	c3                   	ret    

c0101664 <kbd_init>:

static void
kbd_init(void) {
c0101664:	55                   	push   %ebp
c0101665:	89 e5                	mov    %esp,%ebp
c0101667:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c010166a:	e8 de ff ff ff       	call   c010164d <kbd_intr>
    pic_enable(IRQ_KBD);
c010166f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0101676:	e8 ae 09 00 00       	call   c0102029 <pic_enable>
}
c010167b:	90                   	nop
c010167c:	89 ec                	mov    %ebp,%esp
c010167e:	5d                   	pop    %ebp
c010167f:	c3                   	ret    

c0101680 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0101680:	55                   	push   %ebp
c0101681:	89 e5                	mov    %esp,%ebp
c0101683:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101686:	e8 4a f8 ff ff       	call   c0100ed5 <cga_init>
    serial_init();
c010168b:	e8 2d f9 ff ff       	call   c0100fbd <serial_init>
    kbd_init();
c0101690:	e8 cf ff ff ff       	call   c0101664 <kbd_init>
    if (!serial_exists) {
c0101695:	a1 48 64 12 c0       	mov    0xc0126448,%eax
c010169a:	85 c0                	test   %eax,%eax
c010169c:	75 0c                	jne    c01016aa <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c010169e:	c7 04 24 9f 94 10 c0 	movl   $0xc010949f,(%esp)
c01016a5:	e8 bb ec ff ff       	call   c0100365 <cprintf>
    }
}
c01016aa:	90                   	nop
c01016ab:	89 ec                	mov    %ebp,%esp
c01016ad:	5d                   	pop    %ebp
c01016ae:	c3                   	ret    

c01016af <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c01016af:	55                   	push   %ebp
c01016b0:	89 e5                	mov    %esp,%ebp
c01016b2:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c01016b5:	e8 8e f7 ff ff       	call   c0100e48 <__intr_save>
c01016ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c01016bd:	8b 45 08             	mov    0x8(%ebp),%eax
c01016c0:	89 04 24             	mov    %eax,(%esp)
c01016c3:	e8 60 fa ff ff       	call   c0101128 <lpt_putc>
        cga_putc(c);
c01016c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01016cb:	89 04 24             	mov    %eax,(%esp)
c01016ce:	e8 97 fa ff ff       	call   c010116a <cga_putc>
        serial_putc(c);
c01016d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01016d6:	89 04 24             	mov    %eax,(%esp)
c01016d9:	e8 de fc ff ff       	call   c01013bc <serial_putc>
    }
    local_intr_restore(intr_flag);
c01016de:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01016e1:	89 04 24             	mov    %eax,(%esp)
c01016e4:	e8 8b f7 ff ff       	call   c0100e74 <__intr_restore>
}
c01016e9:	90                   	nop
c01016ea:	89 ec                	mov    %ebp,%esp
c01016ec:	5d                   	pop    %ebp
c01016ed:	c3                   	ret    

c01016ee <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c01016ee:	55                   	push   %ebp
c01016ef:	89 e5                	mov    %esp,%ebp
c01016f1:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c01016f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c01016fb:	e8 48 f7 ff ff       	call   c0100e48 <__intr_save>
c0101700:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101703:	e8 9e fd ff ff       	call   c01014a6 <serial_intr>
        kbd_intr();
c0101708:	e8 40 ff ff ff       	call   c010164d <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c010170d:	8b 15 60 66 12 c0    	mov    0xc0126660,%edx
c0101713:	a1 64 66 12 c0       	mov    0xc0126664,%eax
c0101718:	39 c2                	cmp    %eax,%edx
c010171a:	74 31                	je     c010174d <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c010171c:	a1 60 66 12 c0       	mov    0xc0126660,%eax
c0101721:	8d 50 01             	lea    0x1(%eax),%edx
c0101724:	89 15 60 66 12 c0    	mov    %edx,0xc0126660
c010172a:	0f b6 80 60 64 12 c0 	movzbl -0x3fed9ba0(%eax),%eax
c0101731:	0f b6 c0             	movzbl %al,%eax
c0101734:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101737:	a1 60 66 12 c0       	mov    0xc0126660,%eax
c010173c:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101741:	75 0a                	jne    c010174d <cons_getc+0x5f>
                cons.rpos = 0;
c0101743:	c7 05 60 66 12 c0 00 	movl   $0x0,0xc0126660
c010174a:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c010174d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101750:	89 04 24             	mov    %eax,(%esp)
c0101753:	e8 1c f7 ff ff       	call   c0100e74 <__intr_restore>
    return c;
c0101758:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010175b:	89 ec                	mov    %ebp,%esp
c010175d:	5d                   	pop    %ebp
c010175e:	c3                   	ret    

c010175f <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c010175f:	55                   	push   %ebp
c0101760:	89 e5                	mov    %esp,%ebp
c0101762:	83 ec 14             	sub    $0x14,%esp
c0101765:	8b 45 08             	mov    0x8(%ebp),%eax
c0101768:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c010176c:	90                   	nop
c010176d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101770:	83 c0 07             	add    $0x7,%eax
c0101773:	0f b7 c0             	movzwl %ax,%eax
c0101776:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010177a:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010177e:	89 c2                	mov    %eax,%edx
c0101780:	ec                   	in     (%dx),%al
c0101781:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101784:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101788:	0f b6 c0             	movzbl %al,%eax
c010178b:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010178e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101791:	25 80 00 00 00       	and    $0x80,%eax
c0101796:	85 c0                	test   %eax,%eax
c0101798:	75 d3                	jne    c010176d <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c010179a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010179e:	74 11                	je     c01017b1 <ide_wait_ready+0x52>
c01017a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01017a3:	83 e0 21             	and    $0x21,%eax
c01017a6:	85 c0                	test   %eax,%eax
c01017a8:	74 07                	je     c01017b1 <ide_wait_ready+0x52>
        return -1;
c01017aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01017af:	eb 05                	jmp    c01017b6 <ide_wait_ready+0x57>
    }
    return 0;
c01017b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01017b6:	89 ec                	mov    %ebp,%esp
c01017b8:	5d                   	pop    %ebp
c01017b9:	c3                   	ret    

c01017ba <ide_init>:

void
ide_init(void) {
c01017ba:	55                   	push   %ebp
c01017bb:	89 e5                	mov    %esp,%ebp
c01017bd:	57                   	push   %edi
c01017be:	53                   	push   %ebx
c01017bf:	81 ec 50 02 00 00    	sub    $0x250,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c01017c5:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c01017cb:	e9 bd 02 00 00       	jmp    c0101a8d <ide_init+0x2d3>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c01017d0:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01017d4:	89 d0                	mov    %edx,%eax
c01017d6:	c1 e0 03             	shl    $0x3,%eax
c01017d9:	29 d0                	sub    %edx,%eax
c01017db:	c1 e0 03             	shl    $0x3,%eax
c01017de:	05 80 66 12 c0       	add    $0xc0126680,%eax
c01017e3:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c01017e6:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01017ea:	d1 e8                	shr    %eax
c01017ec:	0f b7 c0             	movzwl %ax,%eax
c01017ef:	8b 04 85 c0 94 10 c0 	mov    -0x3fef6b40(,%eax,4),%eax
c01017f6:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c01017fa:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01017fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101805:	00 
c0101806:	89 04 24             	mov    %eax,(%esp)
c0101809:	e8 51 ff ff ff       	call   c010175f <ide_wait_ready>

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c010180e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101812:	c1 e0 04             	shl    $0x4,%eax
c0101815:	24 10                	and    $0x10,%al
c0101817:	0c e0                	or     $0xe0,%al
c0101819:	0f b6 c0             	movzbl %al,%eax
c010181c:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101820:	83 c2 06             	add    $0x6,%edx
c0101823:	0f b7 d2             	movzwl %dx,%edx
c0101826:	66 89 55 ca          	mov    %dx,-0x36(%ebp)
c010182a:	88 45 c9             	mov    %al,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010182d:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0101831:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0101835:	ee                   	out    %al,(%dx)
}
c0101836:	90                   	nop
        ide_wait_ready(iobase, 0);
c0101837:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010183b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101842:	00 
c0101843:	89 04 24             	mov    %eax,(%esp)
c0101846:	e8 14 ff ff ff       	call   c010175f <ide_wait_ready>

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c010184b:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010184f:	83 c0 07             	add    $0x7,%eax
c0101852:	0f b7 c0             	movzwl %ax,%eax
c0101855:	66 89 45 ce          	mov    %ax,-0x32(%ebp)
c0101859:	c6 45 cd ec          	movb   $0xec,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010185d:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0101861:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0101865:	ee                   	out    %al,(%dx)
}
c0101866:	90                   	nop
        ide_wait_ready(iobase, 0);
c0101867:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010186b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101872:	00 
c0101873:	89 04 24             	mov    %eax,(%esp)
c0101876:	e8 e4 fe ff ff       	call   c010175f <ide_wait_ready>

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c010187b:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010187f:	83 c0 07             	add    $0x7,%eax
c0101882:	0f b7 c0             	movzwl %ax,%eax
c0101885:	66 89 45 d2          	mov    %ax,-0x2e(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101889:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c010188d:	89 c2                	mov    %eax,%edx
c010188f:	ec                   	in     (%dx),%al
c0101890:	88 45 d1             	mov    %al,-0x2f(%ebp)
    return data;
c0101893:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0101897:	84 c0                	test   %al,%al
c0101899:	0f 84 e4 01 00 00    	je     c0101a83 <ide_init+0x2c9>
c010189f:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018a3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01018aa:	00 
c01018ab:	89 04 24             	mov    %eax,(%esp)
c01018ae:	e8 ac fe ff ff       	call   c010175f <ide_wait_ready>
c01018b3:	85 c0                	test   %eax,%eax
c01018b5:	0f 85 c8 01 00 00    	jne    c0101a83 <ide_init+0x2c9>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c01018bb:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01018bf:	89 d0                	mov    %edx,%eax
c01018c1:	c1 e0 03             	shl    $0x3,%eax
c01018c4:	29 d0                	sub    %edx,%eax
c01018c6:	c1 e0 03             	shl    $0x3,%eax
c01018c9:	05 80 66 12 c0       	add    $0xc0126680,%eax
c01018ce:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c01018d1:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018d5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c01018d8:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c01018de:	89 45 c0             	mov    %eax,-0x40(%ebp)
c01018e1:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
    asm volatile (
c01018e8:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01018eb:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c01018ee:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01018f1:	89 cb                	mov    %ecx,%ebx
c01018f3:	89 df                	mov    %ebx,%edi
c01018f5:	89 c1                	mov    %eax,%ecx
c01018f7:	fc                   	cld    
c01018f8:	f2 6d                	repnz insl (%dx),%es:(%edi)
c01018fa:	89 c8                	mov    %ecx,%eax
c01018fc:	89 fb                	mov    %edi,%ebx
c01018fe:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c0101901:	89 45 bc             	mov    %eax,-0x44(%ebp)
}
c0101904:	90                   	nop

        unsigned char *ident = (unsigned char *)buffer;
c0101905:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c010190b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c010190e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101911:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c0101917:	89 45 e0             	mov    %eax,-0x20(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c010191a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010191d:	25 00 00 00 04       	and    $0x4000000,%eax
c0101922:	85 c0                	test   %eax,%eax
c0101924:	74 0e                	je     c0101934 <ide_init+0x17a>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c0101926:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101929:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c010192f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0101932:	eb 09                	jmp    c010193d <ide_init+0x183>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c0101934:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101937:	8b 40 78             	mov    0x78(%eax),%eax
c010193a:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c010193d:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101941:	89 d0                	mov    %edx,%eax
c0101943:	c1 e0 03             	shl    $0x3,%eax
c0101946:	29 d0                	sub    %edx,%eax
c0101948:	c1 e0 03             	shl    $0x3,%eax
c010194b:	8d 90 84 66 12 c0    	lea    -0x3fed997c(%eax),%edx
c0101951:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101954:	89 02                	mov    %eax,(%edx)
        ide_devices[ideno].size = sectors;
c0101956:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010195a:	89 d0                	mov    %edx,%eax
c010195c:	c1 e0 03             	shl    $0x3,%eax
c010195f:	29 d0                	sub    %edx,%eax
c0101961:	c1 e0 03             	shl    $0x3,%eax
c0101964:	8d 90 88 66 12 c0    	lea    -0x3fed9978(%eax),%edx
c010196a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010196d:	89 02                	mov    %eax,(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c010196f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101972:	83 c0 62             	add    $0x62,%eax
c0101975:	0f b7 00             	movzwl (%eax),%eax
c0101978:	25 00 02 00 00       	and    $0x200,%eax
c010197d:	85 c0                	test   %eax,%eax
c010197f:	75 24                	jne    c01019a5 <ide_init+0x1eb>
c0101981:	c7 44 24 0c c8 94 10 	movl   $0xc01094c8,0xc(%esp)
c0101988:	c0 
c0101989:	c7 44 24 08 0b 95 10 	movl   $0xc010950b,0x8(%esp)
c0101990:	c0 
c0101991:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0101998:	00 
c0101999:	c7 04 24 20 95 10 c0 	movl   $0xc0109520,(%esp)
c01019a0:	e8 69 f3 ff ff       	call   c0100d0e <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c01019a5:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01019a9:	89 d0                	mov    %edx,%eax
c01019ab:	c1 e0 03             	shl    $0x3,%eax
c01019ae:	29 d0                	sub    %edx,%eax
c01019b0:	c1 e0 03             	shl    $0x3,%eax
c01019b3:	05 80 66 12 c0       	add    $0xc0126680,%eax
c01019b8:	83 c0 0c             	add    $0xc,%eax
c01019bb:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01019be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01019c1:	83 c0 36             	add    $0x36,%eax
c01019c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
        unsigned int i, length = 40;
c01019c7:	c7 45 d4 28 00 00 00 	movl   $0x28,-0x2c(%ebp)
        for (i = 0; i < length; i += 2) {
c01019ce:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01019d5:	eb 34                	jmp    c0101a0b <ide_init+0x251>
            model[i] = data[i + 1], model[i + 1] = data[i];
c01019d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01019da:	8d 50 01             	lea    0x1(%eax),%edx
c01019dd:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01019e0:	01 c2                	add    %eax,%edx
c01019e2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01019e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01019e8:	01 c8                	add    %ecx,%eax
c01019ea:	0f b6 12             	movzbl (%edx),%edx
c01019ed:	88 10                	mov    %dl,(%eax)
c01019ef:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01019f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01019f5:	01 c2                	add    %eax,%edx
c01019f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01019fa:	8d 48 01             	lea    0x1(%eax),%ecx
c01019fd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101a00:	01 c8                	add    %ecx,%eax
c0101a02:	0f b6 12             	movzbl (%edx),%edx
c0101a05:	88 10                	mov    %dl,(%eax)
        for (i = 0; i < length; i += 2) {
c0101a07:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c0101a0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a0e:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0101a11:	72 c4                	jb     c01019d7 <ide_init+0x21d>
        }
        do {
            model[i] = '\0';
c0101a13:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101a16:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a19:	01 d0                	add    %edx,%eax
c0101a1b:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c0101a1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a21:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101a24:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0101a27:	85 c0                	test   %eax,%eax
c0101a29:	74 0f                	je     c0101a3a <ide_init+0x280>
c0101a2b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101a2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a31:	01 d0                	add    %edx,%eax
c0101a33:	0f b6 00             	movzbl (%eax),%eax
c0101a36:	3c 20                	cmp    $0x20,%al
c0101a38:	74 d9                	je     c0101a13 <ide_init+0x259>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c0101a3a:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101a3e:	89 d0                	mov    %edx,%eax
c0101a40:	c1 e0 03             	shl    $0x3,%eax
c0101a43:	29 d0                	sub    %edx,%eax
c0101a45:	c1 e0 03             	shl    $0x3,%eax
c0101a48:	05 80 66 12 c0       	add    $0xc0126680,%eax
c0101a4d:	8d 48 0c             	lea    0xc(%eax),%ecx
c0101a50:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101a54:	89 d0                	mov    %edx,%eax
c0101a56:	c1 e0 03             	shl    $0x3,%eax
c0101a59:	29 d0                	sub    %edx,%eax
c0101a5b:	c1 e0 03             	shl    $0x3,%eax
c0101a5e:	05 88 66 12 c0       	add    $0xc0126688,%eax
c0101a63:	8b 10                	mov    (%eax),%edx
c0101a65:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101a69:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0101a6d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101a71:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a75:	c7 04 24 32 95 10 c0 	movl   $0xc0109532,(%esp)
c0101a7c:	e8 e4 e8 ff ff       	call   c0100365 <cprintf>
c0101a81:	eb 01                	jmp    c0101a84 <ide_init+0x2ca>
            continue ;
c0101a83:	90                   	nop
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0101a84:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101a88:	40                   	inc    %eax
c0101a89:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c0101a8d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101a91:	83 f8 03             	cmp    $0x3,%eax
c0101a94:	0f 86 36 fd ff ff    	jbe    c01017d0 <ide_init+0x16>
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c0101a9a:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
c0101aa1:	e8 83 05 00 00       	call   c0102029 <pic_enable>
    pic_enable(IRQ_IDE2);
c0101aa6:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c0101aad:	e8 77 05 00 00       	call   c0102029 <pic_enable>
}
c0101ab2:	90                   	nop
c0101ab3:	81 c4 50 02 00 00    	add    $0x250,%esp
c0101ab9:	5b                   	pop    %ebx
c0101aba:	5f                   	pop    %edi
c0101abb:	5d                   	pop    %ebp
c0101abc:	c3                   	ret    

c0101abd <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c0101abd:	55                   	push   %ebp
c0101abe:	89 e5                	mov    %esp,%ebp
c0101ac0:	83 ec 04             	sub    $0x4,%esp
c0101ac3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ac6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c0101aca:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101ace:	83 f8 03             	cmp    $0x3,%eax
c0101ad1:	77 21                	ja     c0101af4 <ide_device_valid+0x37>
c0101ad3:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c0101ad7:	89 d0                	mov    %edx,%eax
c0101ad9:	c1 e0 03             	shl    $0x3,%eax
c0101adc:	29 d0                	sub    %edx,%eax
c0101ade:	c1 e0 03             	shl    $0x3,%eax
c0101ae1:	05 80 66 12 c0       	add    $0xc0126680,%eax
c0101ae6:	0f b6 00             	movzbl (%eax),%eax
c0101ae9:	84 c0                	test   %al,%al
c0101aeb:	74 07                	je     c0101af4 <ide_device_valid+0x37>
c0101aed:	b8 01 00 00 00       	mov    $0x1,%eax
c0101af2:	eb 05                	jmp    c0101af9 <ide_device_valid+0x3c>
c0101af4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101af9:	89 ec                	mov    %ebp,%esp
c0101afb:	5d                   	pop    %ebp
c0101afc:	c3                   	ret    

c0101afd <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c0101afd:	55                   	push   %ebp
c0101afe:	89 e5                	mov    %esp,%ebp
c0101b00:	83 ec 08             	sub    $0x8,%esp
c0101b03:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b06:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c0101b0a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101b0e:	89 04 24             	mov    %eax,(%esp)
c0101b11:	e8 a7 ff ff ff       	call   c0101abd <ide_device_valid>
c0101b16:	85 c0                	test   %eax,%eax
c0101b18:	74 17                	je     c0101b31 <ide_device_size+0x34>
        return ide_devices[ideno].size;
c0101b1a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c0101b1e:	89 d0                	mov    %edx,%eax
c0101b20:	c1 e0 03             	shl    $0x3,%eax
c0101b23:	29 d0                	sub    %edx,%eax
c0101b25:	c1 e0 03             	shl    $0x3,%eax
c0101b28:	05 88 66 12 c0       	add    $0xc0126688,%eax
c0101b2d:	8b 00                	mov    (%eax),%eax
c0101b2f:	eb 05                	jmp    c0101b36 <ide_device_size+0x39>
    }
    return 0;
c0101b31:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101b36:	89 ec                	mov    %ebp,%esp
c0101b38:	5d                   	pop    %ebp
c0101b39:	c3                   	ret    

c0101b3a <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c0101b3a:	55                   	push   %ebp
c0101b3b:	89 e5                	mov    %esp,%ebp
c0101b3d:	57                   	push   %edi
c0101b3e:	53                   	push   %ebx
c0101b3f:	83 ec 50             	sub    $0x50,%esp
c0101b42:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b45:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101b49:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101b50:	77 23                	ja     c0101b75 <ide_read_secs+0x3b>
c0101b52:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101b56:	83 f8 03             	cmp    $0x3,%eax
c0101b59:	77 1a                	ja     c0101b75 <ide_read_secs+0x3b>
c0101b5b:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
c0101b5f:	89 d0                	mov    %edx,%eax
c0101b61:	c1 e0 03             	shl    $0x3,%eax
c0101b64:	29 d0                	sub    %edx,%eax
c0101b66:	c1 e0 03             	shl    $0x3,%eax
c0101b69:	05 80 66 12 c0       	add    $0xc0126680,%eax
c0101b6e:	0f b6 00             	movzbl (%eax),%eax
c0101b71:	84 c0                	test   %al,%al
c0101b73:	75 24                	jne    c0101b99 <ide_read_secs+0x5f>
c0101b75:	c7 44 24 0c 50 95 10 	movl   $0xc0109550,0xc(%esp)
c0101b7c:	c0 
c0101b7d:	c7 44 24 08 0b 95 10 	movl   $0xc010950b,0x8(%esp)
c0101b84:	c0 
c0101b85:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c0101b8c:	00 
c0101b8d:	c7 04 24 20 95 10 c0 	movl   $0xc0109520,(%esp)
c0101b94:	e8 75 f1 ff ff       	call   c0100d0e <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101b99:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101ba0:	77 0f                	ja     c0101bb1 <ide_read_secs+0x77>
c0101ba2:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101ba5:	8b 45 14             	mov    0x14(%ebp),%eax
c0101ba8:	01 d0                	add    %edx,%eax
c0101baa:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101baf:	76 24                	jbe    c0101bd5 <ide_read_secs+0x9b>
c0101bb1:	c7 44 24 0c 78 95 10 	movl   $0xc0109578,0xc(%esp)
c0101bb8:	c0 
c0101bb9:	c7 44 24 08 0b 95 10 	movl   $0xc010950b,0x8(%esp)
c0101bc0:	c0 
c0101bc1:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0101bc8:	00 
c0101bc9:	c7 04 24 20 95 10 c0 	movl   $0xc0109520,(%esp)
c0101bd0:	e8 39 f1 ff ff       	call   c0100d0e <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101bd5:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101bd9:	d1 e8                	shr    %eax
c0101bdb:	0f b7 c0             	movzwl %ax,%eax
c0101bde:	8b 04 85 c0 94 10 c0 	mov    -0x3fef6b40(,%eax,4),%eax
c0101be5:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101be9:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101bed:	d1 e8                	shr    %eax
c0101bef:	0f b7 c0             	movzwl %ax,%eax
c0101bf2:	0f b7 04 85 c2 94 10 	movzwl -0x3fef6b3e(,%eax,4),%eax
c0101bf9:	c0 
c0101bfa:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101bfe:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101c02:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101c09:	00 
c0101c0a:	89 04 24             	mov    %eax,(%esp)
c0101c0d:	e8 4d fb ff ff       	call   c010175f <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101c12:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101c15:	83 c0 02             	add    $0x2,%eax
c0101c18:	0f b7 c0             	movzwl %ax,%eax
c0101c1b:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101c1f:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101c23:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101c27:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101c2b:	ee                   	out    %al,(%dx)
}
c0101c2c:	90                   	nop
    outb(iobase + ISA_SECCNT, nsecs);
c0101c2d:	8b 45 14             	mov    0x14(%ebp),%eax
c0101c30:	0f b6 c0             	movzbl %al,%eax
c0101c33:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101c37:	83 c2 02             	add    $0x2,%edx
c0101c3a:	0f b7 d2             	movzwl %dx,%edx
c0101c3d:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101c41:	88 45 d9             	mov    %al,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101c44:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101c48:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101c4c:	ee                   	out    %al,(%dx)
}
c0101c4d:	90                   	nop
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101c4e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c51:	0f b6 c0             	movzbl %al,%eax
c0101c54:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101c58:	83 c2 03             	add    $0x3,%edx
c0101c5b:	0f b7 d2             	movzwl %dx,%edx
c0101c5e:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101c62:	88 45 dd             	mov    %al,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101c65:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101c69:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101c6d:	ee                   	out    %al,(%dx)
}
c0101c6e:	90                   	nop
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101c6f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c72:	c1 e8 08             	shr    $0x8,%eax
c0101c75:	0f b6 c0             	movzbl %al,%eax
c0101c78:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101c7c:	83 c2 04             	add    $0x4,%edx
c0101c7f:	0f b7 d2             	movzwl %dx,%edx
c0101c82:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101c86:	88 45 e1             	mov    %al,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101c89:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101c8d:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101c91:	ee                   	out    %al,(%dx)
}
c0101c92:	90                   	nop
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101c93:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c96:	c1 e8 10             	shr    $0x10,%eax
c0101c99:	0f b6 c0             	movzbl %al,%eax
c0101c9c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101ca0:	83 c2 05             	add    $0x5,%edx
c0101ca3:	0f b7 d2             	movzwl %dx,%edx
c0101ca6:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101caa:	88 45 e5             	mov    %al,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101cad:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101cb1:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101cb5:	ee                   	out    %al,(%dx)
}
c0101cb6:	90                   	nop
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101cb7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0101cba:	c0 e0 04             	shl    $0x4,%al
c0101cbd:	24 10                	and    $0x10,%al
c0101cbf:	88 c2                	mov    %al,%dl
c0101cc1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101cc4:	c1 e8 18             	shr    $0x18,%eax
c0101cc7:	24 0f                	and    $0xf,%al
c0101cc9:	08 d0                	or     %dl,%al
c0101ccb:	0c e0                	or     $0xe0,%al
c0101ccd:	0f b6 c0             	movzbl %al,%eax
c0101cd0:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101cd4:	83 c2 06             	add    $0x6,%edx
c0101cd7:	0f b7 d2             	movzwl %dx,%edx
c0101cda:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101cde:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101ce1:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101ce5:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101ce9:	ee                   	out    %al,(%dx)
}
c0101cea:	90                   	nop
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c0101ceb:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101cef:	83 c0 07             	add    $0x7,%eax
c0101cf2:	0f b7 c0             	movzwl %ax,%eax
c0101cf5:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101cf9:	c6 45 ed 20          	movb   $0x20,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101cfd:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101d01:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101d05:	ee                   	out    %al,(%dx)
}
c0101d06:	90                   	nop

    int ret = 0;
c0101d07:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101d0e:	eb 58                	jmp    c0101d68 <ide_read_secs+0x22e>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101d10:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101d14:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101d1b:	00 
c0101d1c:	89 04 24             	mov    %eax,(%esp)
c0101d1f:	e8 3b fa ff ff       	call   c010175f <ide_wait_ready>
c0101d24:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101d27:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101d2b:	75 43                	jne    c0101d70 <ide_read_secs+0x236>
            goto out;
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c0101d2d:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101d31:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101d34:	8b 45 10             	mov    0x10(%ebp),%eax
c0101d37:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101d3a:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c0101d41:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101d44:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101d47:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101d4a:	89 cb                	mov    %ecx,%ebx
c0101d4c:	89 df                	mov    %ebx,%edi
c0101d4e:	89 c1                	mov    %eax,%ecx
c0101d50:	fc                   	cld    
c0101d51:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0101d53:	89 c8                	mov    %ecx,%eax
c0101d55:	89 fb                	mov    %edi,%ebx
c0101d57:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101d5a:	89 45 c8             	mov    %eax,-0x38(%ebp)
}
c0101d5d:	90                   	nop
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101d5e:	ff 4d 14             	decl   0x14(%ebp)
c0101d61:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101d68:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101d6c:	75 a2                	jne    c0101d10 <ide_read_secs+0x1d6>
    }

out:
c0101d6e:	eb 01                	jmp    c0101d71 <ide_read_secs+0x237>
            goto out;
c0101d70:	90                   	nop
    return ret;
c0101d71:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101d74:	83 c4 50             	add    $0x50,%esp
c0101d77:	5b                   	pop    %ebx
c0101d78:	5f                   	pop    %edi
c0101d79:	5d                   	pop    %ebp
c0101d7a:	c3                   	ret    

c0101d7b <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c0101d7b:	55                   	push   %ebp
c0101d7c:	89 e5                	mov    %esp,%ebp
c0101d7e:	56                   	push   %esi
c0101d7f:	53                   	push   %ebx
c0101d80:	83 ec 50             	sub    $0x50,%esp
c0101d83:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d86:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101d8a:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101d91:	77 23                	ja     c0101db6 <ide_write_secs+0x3b>
c0101d93:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101d97:	83 f8 03             	cmp    $0x3,%eax
c0101d9a:	77 1a                	ja     c0101db6 <ide_write_secs+0x3b>
c0101d9c:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
c0101da0:	89 d0                	mov    %edx,%eax
c0101da2:	c1 e0 03             	shl    $0x3,%eax
c0101da5:	29 d0                	sub    %edx,%eax
c0101da7:	c1 e0 03             	shl    $0x3,%eax
c0101daa:	05 80 66 12 c0       	add    $0xc0126680,%eax
c0101daf:	0f b6 00             	movzbl (%eax),%eax
c0101db2:	84 c0                	test   %al,%al
c0101db4:	75 24                	jne    c0101dda <ide_write_secs+0x5f>
c0101db6:	c7 44 24 0c 50 95 10 	movl   $0xc0109550,0xc(%esp)
c0101dbd:	c0 
c0101dbe:	c7 44 24 08 0b 95 10 	movl   $0xc010950b,0x8(%esp)
c0101dc5:	c0 
c0101dc6:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0101dcd:	00 
c0101dce:	c7 04 24 20 95 10 c0 	movl   $0xc0109520,(%esp)
c0101dd5:	e8 34 ef ff ff       	call   c0100d0e <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101dda:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101de1:	77 0f                	ja     c0101df2 <ide_write_secs+0x77>
c0101de3:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101de6:	8b 45 14             	mov    0x14(%ebp),%eax
c0101de9:	01 d0                	add    %edx,%eax
c0101deb:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101df0:	76 24                	jbe    c0101e16 <ide_write_secs+0x9b>
c0101df2:	c7 44 24 0c 78 95 10 	movl   $0xc0109578,0xc(%esp)
c0101df9:	c0 
c0101dfa:	c7 44 24 08 0b 95 10 	movl   $0xc010950b,0x8(%esp)
c0101e01:	c0 
c0101e02:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c0101e09:	00 
c0101e0a:	c7 04 24 20 95 10 c0 	movl   $0xc0109520,(%esp)
c0101e11:	e8 f8 ee ff ff       	call   c0100d0e <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101e16:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101e1a:	d1 e8                	shr    %eax
c0101e1c:	0f b7 c0             	movzwl %ax,%eax
c0101e1f:	8b 04 85 c0 94 10 c0 	mov    -0x3fef6b40(,%eax,4),%eax
c0101e26:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101e2a:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101e2e:	d1 e8                	shr    %eax
c0101e30:	0f b7 c0             	movzwl %ax,%eax
c0101e33:	0f b7 04 85 c2 94 10 	movzwl -0x3fef6b3e(,%eax,4),%eax
c0101e3a:	c0 
c0101e3b:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101e3f:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101e43:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101e4a:	00 
c0101e4b:	89 04 24             	mov    %eax,(%esp)
c0101e4e:	e8 0c f9 ff ff       	call   c010175f <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101e53:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101e56:	83 c0 02             	add    $0x2,%eax
c0101e59:	0f b7 c0             	movzwl %ax,%eax
c0101e5c:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101e60:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101e64:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101e68:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101e6c:	ee                   	out    %al,(%dx)
}
c0101e6d:	90                   	nop
    outb(iobase + ISA_SECCNT, nsecs);
c0101e6e:	8b 45 14             	mov    0x14(%ebp),%eax
c0101e71:	0f b6 c0             	movzbl %al,%eax
c0101e74:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101e78:	83 c2 02             	add    $0x2,%edx
c0101e7b:	0f b7 d2             	movzwl %dx,%edx
c0101e7e:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101e82:	88 45 d9             	mov    %al,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101e85:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101e89:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101e8d:	ee                   	out    %al,(%dx)
}
c0101e8e:	90                   	nop
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101e8f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101e92:	0f b6 c0             	movzbl %al,%eax
c0101e95:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101e99:	83 c2 03             	add    $0x3,%edx
c0101e9c:	0f b7 d2             	movzwl %dx,%edx
c0101e9f:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101ea3:	88 45 dd             	mov    %al,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101ea6:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101eaa:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101eae:	ee                   	out    %al,(%dx)
}
c0101eaf:	90                   	nop
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101eb0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101eb3:	c1 e8 08             	shr    $0x8,%eax
c0101eb6:	0f b6 c0             	movzbl %al,%eax
c0101eb9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101ebd:	83 c2 04             	add    $0x4,%edx
c0101ec0:	0f b7 d2             	movzwl %dx,%edx
c0101ec3:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101ec7:	88 45 e1             	mov    %al,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101eca:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101ece:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101ed2:	ee                   	out    %al,(%dx)
}
c0101ed3:	90                   	nop
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101ed4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101ed7:	c1 e8 10             	shr    $0x10,%eax
c0101eda:	0f b6 c0             	movzbl %al,%eax
c0101edd:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101ee1:	83 c2 05             	add    $0x5,%edx
c0101ee4:	0f b7 d2             	movzwl %dx,%edx
c0101ee7:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101eeb:	88 45 e5             	mov    %al,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101eee:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101ef2:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101ef6:	ee                   	out    %al,(%dx)
}
c0101ef7:	90                   	nop
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101ef8:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0101efb:	c0 e0 04             	shl    $0x4,%al
c0101efe:	24 10                	and    $0x10,%al
c0101f00:	88 c2                	mov    %al,%dl
c0101f02:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f05:	c1 e8 18             	shr    $0x18,%eax
c0101f08:	24 0f                	and    $0xf,%al
c0101f0a:	08 d0                	or     %dl,%al
c0101f0c:	0c e0                	or     $0xe0,%al
c0101f0e:	0f b6 c0             	movzbl %al,%eax
c0101f11:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101f15:	83 c2 06             	add    $0x6,%edx
c0101f18:	0f b7 d2             	movzwl %dx,%edx
c0101f1b:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101f1f:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101f22:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101f26:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101f2a:	ee                   	out    %al,(%dx)
}
c0101f2b:	90                   	nop
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c0101f2c:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101f30:	83 c0 07             	add    $0x7,%eax
c0101f33:	0f b7 c0             	movzwl %ax,%eax
c0101f36:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101f3a:	c6 45 ed 30          	movb   $0x30,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101f3e:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101f42:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101f46:	ee                   	out    %al,(%dx)
}
c0101f47:	90                   	nop

    int ret = 0;
c0101f48:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101f4f:	eb 58                	jmp    c0101fa9 <ide_write_secs+0x22e>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101f51:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101f55:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101f5c:	00 
c0101f5d:	89 04 24             	mov    %eax,(%esp)
c0101f60:	e8 fa f7 ff ff       	call   c010175f <ide_wait_ready>
c0101f65:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101f68:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101f6c:	75 43                	jne    c0101fb1 <ide_write_secs+0x236>
            goto out;
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c0101f6e:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101f72:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101f75:	8b 45 10             	mov    0x10(%ebp),%eax
c0101f78:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101f7b:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c0101f82:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101f85:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101f88:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101f8b:	89 cb                	mov    %ecx,%ebx
c0101f8d:	89 de                	mov    %ebx,%esi
c0101f8f:	89 c1                	mov    %eax,%ecx
c0101f91:	fc                   	cld    
c0101f92:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c0101f94:	89 c8                	mov    %ecx,%eax
c0101f96:	89 f3                	mov    %esi,%ebx
c0101f98:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101f9b:	89 45 c8             	mov    %eax,-0x38(%ebp)
}
c0101f9e:	90                   	nop
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101f9f:	ff 4d 14             	decl   0x14(%ebp)
c0101fa2:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101fa9:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101fad:	75 a2                	jne    c0101f51 <ide_write_secs+0x1d6>
    }

out:
c0101faf:	eb 01                	jmp    c0101fb2 <ide_write_secs+0x237>
            goto out;
c0101fb1:	90                   	nop
    return ret;
c0101fb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101fb5:	83 c4 50             	add    $0x50,%esp
c0101fb8:	5b                   	pop    %ebx
c0101fb9:	5e                   	pop    %esi
c0101fba:	5d                   	pop    %ebp
c0101fbb:	c3                   	ret    

c0101fbc <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0101fbc:	55                   	push   %ebp
c0101fbd:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c0101fbf:	fb                   	sti    
}
c0101fc0:	90                   	nop
    sti();
}
c0101fc1:	90                   	nop
c0101fc2:	5d                   	pop    %ebp
c0101fc3:	c3                   	ret    

c0101fc4 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0101fc4:	55                   	push   %ebp
c0101fc5:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c0101fc7:	fa                   	cli    
}
c0101fc8:	90                   	nop
    cli();
}
c0101fc9:	90                   	nop
c0101fca:	5d                   	pop    %ebp
c0101fcb:	c3                   	ret    

c0101fcc <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0101fcc:	55                   	push   %ebp
c0101fcd:	89 e5                	mov    %esp,%ebp
c0101fcf:	83 ec 14             	sub    $0x14,%esp
c0101fd2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fd5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0101fd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101fdc:	66 a3 50 35 12 c0    	mov    %ax,0xc0123550
    if (did_init) {
c0101fe2:	a1 60 67 12 c0       	mov    0xc0126760,%eax
c0101fe7:	85 c0                	test   %eax,%eax
c0101fe9:	74 39                	je     c0102024 <pic_setmask+0x58>
        outb(IO_PIC1 + 1, mask);
c0101feb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101fee:	0f b6 c0             	movzbl %al,%eax
c0101ff1:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
c0101ff7:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101ffa:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101ffe:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0102002:	ee                   	out    %al,(%dx)
}
c0102003:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
c0102004:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0102008:	c1 e8 08             	shr    $0x8,%eax
c010200b:	0f b7 c0             	movzwl %ax,%eax
c010200e:	0f b6 c0             	movzbl %al,%eax
c0102011:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
c0102017:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010201a:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c010201e:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0102022:	ee                   	out    %al,(%dx)
}
c0102023:	90                   	nop
    }
}
c0102024:	90                   	nop
c0102025:	89 ec                	mov    %ebp,%esp
c0102027:	5d                   	pop    %ebp
c0102028:	c3                   	ret    

c0102029 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0102029:	55                   	push   %ebp
c010202a:	89 e5                	mov    %esp,%ebp
c010202c:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c010202f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102032:	ba 01 00 00 00       	mov    $0x1,%edx
c0102037:	88 c1                	mov    %al,%cl
c0102039:	d3 e2                	shl    %cl,%edx
c010203b:	89 d0                	mov    %edx,%eax
c010203d:	98                   	cwtl   
c010203e:	f7 d0                	not    %eax
c0102040:	0f bf d0             	movswl %ax,%edx
c0102043:	0f b7 05 50 35 12 c0 	movzwl 0xc0123550,%eax
c010204a:	98                   	cwtl   
c010204b:	21 d0                	and    %edx,%eax
c010204d:	98                   	cwtl   
c010204e:	0f b7 c0             	movzwl %ax,%eax
c0102051:	89 04 24             	mov    %eax,(%esp)
c0102054:	e8 73 ff ff ff       	call   c0101fcc <pic_setmask>
}
c0102059:	90                   	nop
c010205a:	89 ec                	mov    %ebp,%esp
c010205c:	5d                   	pop    %ebp
c010205d:	c3                   	ret    

c010205e <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c010205e:	55                   	push   %ebp
c010205f:	89 e5                	mov    %esp,%ebp
c0102061:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c0102064:	c7 05 60 67 12 c0 01 	movl   $0x1,0xc0126760
c010206b:	00 00 00 
c010206e:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
c0102074:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102078:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c010207c:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0102080:	ee                   	out    %al,(%dx)
}
c0102081:	90                   	nop
c0102082:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
c0102088:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010208c:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0102090:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0102094:	ee                   	out    %al,(%dx)
}
c0102095:	90                   	nop
c0102096:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c010209c:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020a0:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01020a4:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01020a8:	ee                   	out    %al,(%dx)
}
c01020a9:	90                   	nop
c01020aa:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
c01020b0:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020b4:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01020b8:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01020bc:	ee                   	out    %al,(%dx)
}
c01020bd:	90                   	nop
c01020be:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
c01020c4:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020c8:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01020cc:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01020d0:	ee                   	out    %al,(%dx)
}
c01020d1:	90                   	nop
c01020d2:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
c01020d8:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020dc:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01020e0:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01020e4:	ee                   	out    %al,(%dx)
}
c01020e5:	90                   	nop
c01020e6:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
c01020ec:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020f0:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01020f4:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01020f8:	ee                   	out    %al,(%dx)
}
c01020f9:	90                   	nop
c01020fa:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
c0102100:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102104:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0102108:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010210c:	ee                   	out    %al,(%dx)
}
c010210d:	90                   	nop
c010210e:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
c0102114:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102118:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010211c:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102120:	ee                   	out    %al,(%dx)
}
c0102121:	90                   	nop
c0102122:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c0102128:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010212c:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0102130:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102134:	ee                   	out    %al,(%dx)
}
c0102135:	90                   	nop
c0102136:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
c010213c:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102140:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0102144:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102148:	ee                   	out    %al,(%dx)
}
c0102149:	90                   	nop
c010214a:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c0102150:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102154:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0102158:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010215c:	ee                   	out    %al,(%dx)
}
c010215d:	90                   	nop
c010215e:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
c0102164:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102168:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010216c:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0102170:	ee                   	out    %al,(%dx)
}
c0102171:	90                   	nop
c0102172:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
c0102178:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010217c:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0102180:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0102184:	ee                   	out    %al,(%dx)
}
c0102185:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c0102186:	0f b7 05 50 35 12 c0 	movzwl 0xc0123550,%eax
c010218d:	3d ff ff 00 00       	cmp    $0xffff,%eax
c0102192:	74 0f                	je     c01021a3 <pic_init+0x145>
        pic_setmask(irq_mask);
c0102194:	0f b7 05 50 35 12 c0 	movzwl 0xc0123550,%eax
c010219b:	89 04 24             	mov    %eax,(%esp)
c010219e:	e8 29 fe ff ff       	call   c0101fcc <pic_setmask>
    }
}
c01021a3:	90                   	nop
c01021a4:	89 ec                	mov    %ebp,%esp
c01021a6:	5d                   	pop    %ebp
c01021a7:	c3                   	ret    

c01021a8 <print_ticks>:
#include <swap.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c01021a8:	55                   	push   %ebp
c01021a9:	89 e5                	mov    %esp,%ebp
c01021ab:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c01021ae:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01021b5:	00 
c01021b6:	c7 04 24 c0 95 10 c0 	movl   $0xc01095c0,(%esp)
c01021bd:	e8 a3 e1 ff ff       	call   c0100365 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c01021c2:	90                   	nop
c01021c3:	89 ec                	mov    %ebp,%esp
c01021c5:	5d                   	pop    %ebp
c01021c6:	c3                   	ret    

c01021c7 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01021c7:	55                   	push   %ebp
c01021c8:	89 e5                	mov    %esp,%ebp
c01021ca:	83 ec 10             	sub    $0x10,%esp
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */

     extern uintptr_t __vectors[];
     int i;
     for(i=0;i<256;i++)
c01021cd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01021d4:	e9 c4 00 00 00       	jmp    c010229d <idt_init+0xd6>
     {
        SETGATE(idt[i],0,GD_KTEXT,__vectors[i],0);
c01021d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021dc:	8b 04 85 e0 35 12 c0 	mov    -0x3fedca20(,%eax,4),%eax
c01021e3:	0f b7 d0             	movzwl %ax,%edx
c01021e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021e9:	66 89 14 c5 80 67 12 	mov    %dx,-0x3fed9880(,%eax,8)
c01021f0:	c0 
c01021f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021f4:	66 c7 04 c5 82 67 12 	movw   $0x8,-0x3fed987e(,%eax,8)
c01021fb:	c0 08 00 
c01021fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102201:	0f b6 14 c5 84 67 12 	movzbl -0x3fed987c(,%eax,8),%edx
c0102208:	c0 
c0102209:	80 e2 e0             	and    $0xe0,%dl
c010220c:	88 14 c5 84 67 12 c0 	mov    %dl,-0x3fed987c(,%eax,8)
c0102213:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102216:	0f b6 14 c5 84 67 12 	movzbl -0x3fed987c(,%eax,8),%edx
c010221d:	c0 
c010221e:	80 e2 1f             	and    $0x1f,%dl
c0102221:	88 14 c5 84 67 12 c0 	mov    %dl,-0x3fed987c(,%eax,8)
c0102228:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010222b:	0f b6 14 c5 85 67 12 	movzbl -0x3fed987b(,%eax,8),%edx
c0102232:	c0 
c0102233:	80 e2 f0             	and    $0xf0,%dl
c0102236:	80 ca 0e             	or     $0xe,%dl
c0102239:	88 14 c5 85 67 12 c0 	mov    %dl,-0x3fed987b(,%eax,8)
c0102240:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102243:	0f b6 14 c5 85 67 12 	movzbl -0x3fed987b(,%eax,8),%edx
c010224a:	c0 
c010224b:	80 e2 ef             	and    $0xef,%dl
c010224e:	88 14 c5 85 67 12 c0 	mov    %dl,-0x3fed987b(,%eax,8)
c0102255:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102258:	0f b6 14 c5 85 67 12 	movzbl -0x3fed987b(,%eax,8),%edx
c010225f:	c0 
c0102260:	80 e2 9f             	and    $0x9f,%dl
c0102263:	88 14 c5 85 67 12 c0 	mov    %dl,-0x3fed987b(,%eax,8)
c010226a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010226d:	0f b6 14 c5 85 67 12 	movzbl -0x3fed987b(,%eax,8),%edx
c0102274:	c0 
c0102275:	80 ca 80             	or     $0x80,%dl
c0102278:	88 14 c5 85 67 12 c0 	mov    %dl,-0x3fed987b(,%eax,8)
c010227f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102282:	8b 04 85 e0 35 12 c0 	mov    -0x3fedca20(,%eax,4),%eax
c0102289:	c1 e8 10             	shr    $0x10,%eax
c010228c:	0f b7 d0             	movzwl %ax,%edx
c010228f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102292:	66 89 14 c5 86 67 12 	mov    %dx,-0x3fed987a(,%eax,8)
c0102299:	c0 
     for(i=0;i<256;i++)
c010229a:	ff 45 fc             	incl   -0x4(%ebp)
c010229d:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
c01022a4:	0f 8e 2f ff ff ff    	jle    c01021d9 <idt_init+0x12>
     }
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], 3);
c01022aa:	a1 c4 37 12 c0       	mov    0xc01237c4,%eax
c01022af:	0f b7 c0             	movzwl %ax,%eax
c01022b2:	66 a3 48 6b 12 c0    	mov    %ax,0xc0126b48
c01022b8:	66 c7 05 4a 6b 12 c0 	movw   $0x8,0xc0126b4a
c01022bf:	08 00 
c01022c1:	0f b6 05 4c 6b 12 c0 	movzbl 0xc0126b4c,%eax
c01022c8:	24 e0                	and    $0xe0,%al
c01022ca:	a2 4c 6b 12 c0       	mov    %al,0xc0126b4c
c01022cf:	0f b6 05 4c 6b 12 c0 	movzbl 0xc0126b4c,%eax
c01022d6:	24 1f                	and    $0x1f,%al
c01022d8:	a2 4c 6b 12 c0       	mov    %al,0xc0126b4c
c01022dd:	0f b6 05 4d 6b 12 c0 	movzbl 0xc0126b4d,%eax
c01022e4:	24 f0                	and    $0xf0,%al
c01022e6:	0c 0e                	or     $0xe,%al
c01022e8:	a2 4d 6b 12 c0       	mov    %al,0xc0126b4d
c01022ed:	0f b6 05 4d 6b 12 c0 	movzbl 0xc0126b4d,%eax
c01022f4:	24 ef                	and    $0xef,%al
c01022f6:	a2 4d 6b 12 c0       	mov    %al,0xc0126b4d
c01022fb:	0f b6 05 4d 6b 12 c0 	movzbl 0xc0126b4d,%eax
c0102302:	0c 60                	or     $0x60,%al
c0102304:	a2 4d 6b 12 c0       	mov    %al,0xc0126b4d
c0102309:	0f b6 05 4d 6b 12 c0 	movzbl 0xc0126b4d,%eax
c0102310:	0c 80                	or     $0x80,%al
c0102312:	a2 4d 6b 12 c0       	mov    %al,0xc0126b4d
c0102317:	a1 c4 37 12 c0       	mov    0xc01237c4,%eax
c010231c:	c1 e8 10             	shr    $0x10,%eax
c010231f:	0f b7 c0             	movzwl %ax,%eax
c0102322:	66 a3 4e 6b 12 c0    	mov    %ax,0xc0126b4e
c0102328:	c7 45 f8 60 35 12 c0 	movl   $0xc0123560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c010232f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0102332:	0f 01 18             	lidtl  (%eax)
}
c0102335:	90                   	nop





}
c0102336:	90                   	nop
c0102337:	89 ec                	mov    %ebp,%esp
c0102339:	5d                   	pop    %ebp
c010233a:	c3                   	ret    

c010233b <trapname>:

static const char *
trapname(int trapno) {
c010233b:	55                   	push   %ebp
c010233c:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c010233e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102341:	83 f8 13             	cmp    $0x13,%eax
c0102344:	77 0c                	ja     c0102352 <trapname+0x17>
        return excnames[trapno];
c0102346:	8b 45 08             	mov    0x8(%ebp),%eax
c0102349:	8b 04 85 20 9a 10 c0 	mov    -0x3fef65e0(,%eax,4),%eax
c0102350:	eb 18                	jmp    c010236a <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0102352:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0102356:	7e 0d                	jle    c0102365 <trapname+0x2a>
c0102358:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c010235c:	7f 07                	jg     c0102365 <trapname+0x2a>
        return "Hardware Interrupt";
c010235e:	b8 ca 95 10 c0       	mov    $0xc01095ca,%eax
c0102363:	eb 05                	jmp    c010236a <trapname+0x2f>
    }
    return "(unknown trap)";
c0102365:	b8 dd 95 10 c0       	mov    $0xc01095dd,%eax
}
c010236a:	5d                   	pop    %ebp
c010236b:	c3                   	ret    

c010236c <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c010236c:	55                   	push   %ebp
c010236d:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c010236f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102372:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102376:	83 f8 08             	cmp    $0x8,%eax
c0102379:	0f 94 c0             	sete   %al
c010237c:	0f b6 c0             	movzbl %al,%eax
}
c010237f:	5d                   	pop    %ebp
c0102380:	c3                   	ret    

c0102381 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0102381:	55                   	push   %ebp
c0102382:	89 e5                	mov    %esp,%ebp
c0102384:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0102387:	8b 45 08             	mov    0x8(%ebp),%eax
c010238a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010238e:	c7 04 24 1e 96 10 c0 	movl   $0xc010961e,(%esp)
c0102395:	e8 cb df ff ff       	call   c0100365 <cprintf>
    print_regs(&tf->tf_regs);
c010239a:	8b 45 08             	mov    0x8(%ebp),%eax
c010239d:	89 04 24             	mov    %eax,(%esp)
c01023a0:	e8 8f 01 00 00       	call   c0102534 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c01023a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01023a8:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c01023ac:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023b0:	c7 04 24 2f 96 10 c0 	movl   $0xc010962f,(%esp)
c01023b7:	e8 a9 df ff ff       	call   c0100365 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c01023bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01023bf:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c01023c3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023c7:	c7 04 24 42 96 10 c0 	movl   $0xc0109642,(%esp)
c01023ce:	e8 92 df ff ff       	call   c0100365 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c01023d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01023d6:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c01023da:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023de:	c7 04 24 55 96 10 c0 	movl   $0xc0109655,(%esp)
c01023e5:	e8 7b df ff ff       	call   c0100365 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c01023ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01023ed:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c01023f1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023f5:	c7 04 24 68 96 10 c0 	movl   $0xc0109668,(%esp)
c01023fc:	e8 64 df ff ff       	call   c0100365 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0102401:	8b 45 08             	mov    0x8(%ebp),%eax
c0102404:	8b 40 30             	mov    0x30(%eax),%eax
c0102407:	89 04 24             	mov    %eax,(%esp)
c010240a:	e8 2c ff ff ff       	call   c010233b <trapname>
c010240f:	8b 55 08             	mov    0x8(%ebp),%edx
c0102412:	8b 52 30             	mov    0x30(%edx),%edx
c0102415:	89 44 24 08          	mov    %eax,0x8(%esp)
c0102419:	89 54 24 04          	mov    %edx,0x4(%esp)
c010241d:	c7 04 24 7b 96 10 c0 	movl   $0xc010967b,(%esp)
c0102424:	e8 3c df ff ff       	call   c0100365 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0102429:	8b 45 08             	mov    0x8(%ebp),%eax
c010242c:	8b 40 34             	mov    0x34(%eax),%eax
c010242f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102433:	c7 04 24 8d 96 10 c0 	movl   $0xc010968d,(%esp)
c010243a:	e8 26 df ff ff       	call   c0100365 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c010243f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102442:	8b 40 38             	mov    0x38(%eax),%eax
c0102445:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102449:	c7 04 24 9c 96 10 c0 	movl   $0xc010969c,(%esp)
c0102450:	e8 10 df ff ff       	call   c0100365 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0102455:	8b 45 08             	mov    0x8(%ebp),%eax
c0102458:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010245c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102460:	c7 04 24 ab 96 10 c0 	movl   $0xc01096ab,(%esp)
c0102467:	e8 f9 de ff ff       	call   c0100365 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c010246c:	8b 45 08             	mov    0x8(%ebp),%eax
c010246f:	8b 40 40             	mov    0x40(%eax),%eax
c0102472:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102476:	c7 04 24 be 96 10 c0 	movl   $0xc01096be,(%esp)
c010247d:	e8 e3 de ff ff       	call   c0100365 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0102482:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0102489:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0102490:	eb 3d                	jmp    c01024cf <print_trapframe+0x14e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0102492:	8b 45 08             	mov    0x8(%ebp),%eax
c0102495:	8b 50 40             	mov    0x40(%eax),%edx
c0102498:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010249b:	21 d0                	and    %edx,%eax
c010249d:	85 c0                	test   %eax,%eax
c010249f:	74 28                	je     c01024c9 <print_trapframe+0x148>
c01024a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01024a4:	8b 04 85 80 35 12 c0 	mov    -0x3fedca80(,%eax,4),%eax
c01024ab:	85 c0                	test   %eax,%eax
c01024ad:	74 1a                	je     c01024c9 <print_trapframe+0x148>
            cprintf("%s,", IA32flags[i]);
c01024af:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01024b2:	8b 04 85 80 35 12 c0 	mov    -0x3fedca80(,%eax,4),%eax
c01024b9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024bd:	c7 04 24 cd 96 10 c0 	movl   $0xc01096cd,(%esp)
c01024c4:	e8 9c de ff ff       	call   c0100365 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c01024c9:	ff 45 f4             	incl   -0xc(%ebp)
c01024cc:	d1 65 f0             	shll   -0x10(%ebp)
c01024cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01024d2:	83 f8 17             	cmp    $0x17,%eax
c01024d5:	76 bb                	jbe    c0102492 <print_trapframe+0x111>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c01024d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01024da:	8b 40 40             	mov    0x40(%eax),%eax
c01024dd:	c1 e8 0c             	shr    $0xc,%eax
c01024e0:	83 e0 03             	and    $0x3,%eax
c01024e3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024e7:	c7 04 24 d1 96 10 c0 	movl   $0xc01096d1,(%esp)
c01024ee:	e8 72 de ff ff       	call   c0100365 <cprintf>

    if (!trap_in_kernel(tf)) {
c01024f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01024f6:	89 04 24             	mov    %eax,(%esp)
c01024f9:	e8 6e fe ff ff       	call   c010236c <trap_in_kernel>
c01024fe:	85 c0                	test   %eax,%eax
c0102500:	75 2d                	jne    c010252f <print_trapframe+0x1ae>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0102502:	8b 45 08             	mov    0x8(%ebp),%eax
c0102505:	8b 40 44             	mov    0x44(%eax),%eax
c0102508:	89 44 24 04          	mov    %eax,0x4(%esp)
c010250c:	c7 04 24 da 96 10 c0 	movl   $0xc01096da,(%esp)
c0102513:	e8 4d de ff ff       	call   c0100365 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0102518:	8b 45 08             	mov    0x8(%ebp),%eax
c010251b:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c010251f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102523:	c7 04 24 e9 96 10 c0 	movl   $0xc01096e9,(%esp)
c010252a:	e8 36 de ff ff       	call   c0100365 <cprintf>
    }
}
c010252f:	90                   	nop
c0102530:	89 ec                	mov    %ebp,%esp
c0102532:	5d                   	pop    %ebp
c0102533:	c3                   	ret    

c0102534 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0102534:	55                   	push   %ebp
c0102535:	89 e5                	mov    %esp,%ebp
c0102537:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c010253a:	8b 45 08             	mov    0x8(%ebp),%eax
c010253d:	8b 00                	mov    (%eax),%eax
c010253f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102543:	c7 04 24 fc 96 10 c0 	movl   $0xc01096fc,(%esp)
c010254a:	e8 16 de ff ff       	call   c0100365 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c010254f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102552:	8b 40 04             	mov    0x4(%eax),%eax
c0102555:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102559:	c7 04 24 0b 97 10 c0 	movl   $0xc010970b,(%esp)
c0102560:	e8 00 de ff ff       	call   c0100365 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0102565:	8b 45 08             	mov    0x8(%ebp),%eax
c0102568:	8b 40 08             	mov    0x8(%eax),%eax
c010256b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010256f:	c7 04 24 1a 97 10 c0 	movl   $0xc010971a,(%esp)
c0102576:	e8 ea dd ff ff       	call   c0100365 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c010257b:	8b 45 08             	mov    0x8(%ebp),%eax
c010257e:	8b 40 0c             	mov    0xc(%eax),%eax
c0102581:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102585:	c7 04 24 29 97 10 c0 	movl   $0xc0109729,(%esp)
c010258c:	e8 d4 dd ff ff       	call   c0100365 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0102591:	8b 45 08             	mov    0x8(%ebp),%eax
c0102594:	8b 40 10             	mov    0x10(%eax),%eax
c0102597:	89 44 24 04          	mov    %eax,0x4(%esp)
c010259b:	c7 04 24 38 97 10 c0 	movl   $0xc0109738,(%esp)
c01025a2:	e8 be dd ff ff       	call   c0100365 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c01025a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01025aa:	8b 40 14             	mov    0x14(%eax),%eax
c01025ad:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025b1:	c7 04 24 47 97 10 c0 	movl   $0xc0109747,(%esp)
c01025b8:	e8 a8 dd ff ff       	call   c0100365 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c01025bd:	8b 45 08             	mov    0x8(%ebp),%eax
c01025c0:	8b 40 18             	mov    0x18(%eax),%eax
c01025c3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025c7:	c7 04 24 56 97 10 c0 	movl   $0xc0109756,(%esp)
c01025ce:	e8 92 dd ff ff       	call   c0100365 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c01025d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01025d6:	8b 40 1c             	mov    0x1c(%eax),%eax
c01025d9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025dd:	c7 04 24 65 97 10 c0 	movl   $0xc0109765,(%esp)
c01025e4:	e8 7c dd ff ff       	call   c0100365 <cprintf>
}
c01025e9:	90                   	nop
c01025ea:	89 ec                	mov    %ebp,%esp
c01025ec:	5d                   	pop    %ebp
c01025ed:	c3                   	ret    

c01025ee <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c01025ee:	55                   	push   %ebp
c01025ef:	89 e5                	mov    %esp,%ebp
c01025f1:	83 ec 38             	sub    $0x38,%esp
c01025f4:	89 5d fc             	mov    %ebx,-0x4(%ebp)
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c01025f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01025fa:	8b 40 34             	mov    0x34(%eax),%eax
c01025fd:	83 e0 01             	and    $0x1,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102600:	85 c0                	test   %eax,%eax
c0102602:	74 07                	je     c010260b <print_pgfault+0x1d>
c0102604:	bb 74 97 10 c0       	mov    $0xc0109774,%ebx
c0102609:	eb 05                	jmp    c0102610 <print_pgfault+0x22>
c010260b:	bb 85 97 10 c0       	mov    $0xc0109785,%ebx
            (tf->tf_err & 2) ? 'W' : 'R',
c0102610:	8b 45 08             	mov    0x8(%ebp),%eax
c0102613:	8b 40 34             	mov    0x34(%eax),%eax
c0102616:	83 e0 02             	and    $0x2,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102619:	85 c0                	test   %eax,%eax
c010261b:	74 07                	je     c0102624 <print_pgfault+0x36>
c010261d:	b9 57 00 00 00       	mov    $0x57,%ecx
c0102622:	eb 05                	jmp    c0102629 <print_pgfault+0x3b>
c0102624:	b9 52 00 00 00       	mov    $0x52,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
c0102629:	8b 45 08             	mov    0x8(%ebp),%eax
c010262c:	8b 40 34             	mov    0x34(%eax),%eax
c010262f:	83 e0 04             	and    $0x4,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102632:	85 c0                	test   %eax,%eax
c0102634:	74 07                	je     c010263d <print_pgfault+0x4f>
c0102636:	ba 55 00 00 00       	mov    $0x55,%edx
c010263b:	eb 05                	jmp    c0102642 <print_pgfault+0x54>
c010263d:	ba 4b 00 00 00       	mov    $0x4b,%edx
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c0102642:	0f 20 d0             	mov    %cr2,%eax
c0102645:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c0102648:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010264b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
c010264f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0102653:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102657:	89 44 24 04          	mov    %eax,0x4(%esp)
c010265b:	c7 04 24 94 97 10 c0 	movl   $0xc0109794,(%esp)
c0102662:	e8 fe dc ff ff       	call   c0100365 <cprintf>
}
c0102667:	90                   	nop
c0102668:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010266b:	89 ec                	mov    %ebp,%esp
c010266d:	5d                   	pop    %ebp
c010266e:	c3                   	ret    

c010266f <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c010266f:	55                   	push   %ebp
c0102670:	89 e5                	mov    %esp,%ebp
c0102672:	83 ec 28             	sub    $0x28,%esp
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
c0102675:	8b 45 08             	mov    0x8(%ebp),%eax
c0102678:	89 04 24             	mov    %eax,(%esp)
c010267b:	e8 6e ff ff ff       	call   c01025ee <print_pgfault>
    if (check_mm_struct != NULL) {
c0102680:	a1 0c 71 12 c0       	mov    0xc012710c,%eax
c0102685:	85 c0                	test   %eax,%eax
c0102687:	74 26                	je     c01026af <pgfault_handler+0x40>
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c0102689:	0f 20 d0             	mov    %cr2,%eax
c010268c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c010268f:	8b 4d f4             	mov    -0xc(%ebp),%ecx
        return do_pgfault(check_mm_struct, tf->tf_err, rcr2());
c0102692:	8b 45 08             	mov    0x8(%ebp),%eax
c0102695:	8b 50 34             	mov    0x34(%eax),%edx
c0102698:	a1 0c 71 12 c0       	mov    0xc012710c,%eax
c010269d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01026a1:	89 54 24 04          	mov    %edx,0x4(%esp)
c01026a5:	89 04 24             	mov    %eax,(%esp)
c01026a8:	e8 f7 5a 00 00       	call   c01081a4 <do_pgfault>
c01026ad:	eb 1c                	jmp    c01026cb <pgfault_handler+0x5c>
    }
    panic("unhandled page fault.\n");
c01026af:	c7 44 24 08 b7 97 10 	movl   $0xc01097b7,0x8(%esp)
c01026b6:	c0 
c01026b7:	c7 44 24 04 b0 00 00 	movl   $0xb0,0x4(%esp)
c01026be:	00 
c01026bf:	c7 04 24 ce 97 10 c0 	movl   $0xc01097ce,(%esp)
c01026c6:	e8 43 e6 ff ff       	call   c0100d0e <__panic>
}
c01026cb:	89 ec                	mov    %ebp,%esp
c01026cd:	5d                   	pop    %ebp
c01026ce:	c3                   	ret    

c01026cf <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c01026cf:	55                   	push   %ebp
c01026d0:	89 e5                	mov    %esp,%ebp
c01026d2:	83 ec 28             	sub    $0x28,%esp
    char c;

    int ret;

    switch (tf->tf_trapno) {
c01026d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01026d8:	8b 40 30             	mov    0x30(%eax),%eax
c01026db:	83 f8 2f             	cmp    $0x2f,%eax
c01026de:	77 1e                	ja     c01026fe <trap_dispatch+0x2f>
c01026e0:	83 f8 0e             	cmp    $0xe,%eax
c01026e3:	0f 82 1a 01 00 00    	jb     c0102803 <trap_dispatch+0x134>
c01026e9:	83 e8 0e             	sub    $0xe,%eax
c01026ec:	83 f8 21             	cmp    $0x21,%eax
c01026ef:	0f 87 0e 01 00 00    	ja     c0102803 <trap_dispatch+0x134>
c01026f5:	8b 04 85 48 98 10 c0 	mov    -0x3fef67b8(,%eax,4),%eax
c01026fc:	ff e0                	jmp    *%eax
c01026fe:	83 e8 78             	sub    $0x78,%eax
c0102701:	83 f8 01             	cmp    $0x1,%eax
c0102704:	0f 87 f9 00 00 00    	ja     c0102803 <trap_dispatch+0x134>
c010270a:	e9 d8 00 00 00       	jmp    c01027e7 <trap_dispatch+0x118>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c010270f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102712:	89 04 24             	mov    %eax,(%esp)
c0102715:	e8 55 ff ff ff       	call   c010266f <pgfault_handler>
c010271a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010271d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0102721:	0f 84 14 01 00 00    	je     c010283b <trap_dispatch+0x16c>
            print_trapframe(tf);
c0102727:	8b 45 08             	mov    0x8(%ebp),%eax
c010272a:	89 04 24             	mov    %eax,(%esp)
c010272d:	e8 4f fc ff ff       	call   c0102381 <print_trapframe>
            panic("handle pgfault failed. %e\n", ret);
c0102732:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102735:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102739:	c7 44 24 08 df 97 10 	movl   $0xc01097df,0x8(%esp)
c0102740:	c0 
c0102741:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
c0102748:	00 
c0102749:	c7 04 24 ce 97 10 c0 	movl   $0xc01097ce,(%esp)
c0102750:	e8 b9 e5 ff ff       	call   c0100d0e <__panic>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
	    ticks+=1;
c0102755:	a1 24 64 12 c0       	mov    0xc0126424,%eax
c010275a:	40                   	inc    %eax
c010275b:	a3 24 64 12 c0       	mov    %eax,0xc0126424
        if (ticks % TICK_NUM == 0) {
c0102760:	8b 0d 24 64 12 c0    	mov    0xc0126424,%ecx
c0102766:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c010276b:	89 c8                	mov    %ecx,%eax
c010276d:	f7 e2                	mul    %edx
c010276f:	c1 ea 05             	shr    $0x5,%edx
c0102772:	89 d0                	mov    %edx,%eax
c0102774:	c1 e0 02             	shl    $0x2,%eax
c0102777:	01 d0                	add    %edx,%eax
c0102779:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0102780:	01 d0                	add    %edx,%eax
c0102782:	c1 e0 02             	shl    $0x2,%eax
c0102785:	29 c1                	sub    %eax,%ecx
c0102787:	89 ca                	mov    %ecx,%edx
c0102789:	85 d2                	test   %edx,%edx
c010278b:	0f 85 ad 00 00 00    	jne    c010283e <trap_dispatch+0x16f>
            print_ticks();
c0102791:	e8 12 fa ff ff       	call   c01021a8 <print_ticks>
        }
        break;
c0102796:	e9 a3 00 00 00       	jmp    c010283e <trap_dispatch+0x16f>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c010279b:	e8 4e ef ff ff       	call   c01016ee <cons_getc>
c01027a0:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c01027a3:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c01027a7:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01027ab:	89 54 24 08          	mov    %edx,0x8(%esp)
c01027af:	89 44 24 04          	mov    %eax,0x4(%esp)
c01027b3:	c7 04 24 fa 97 10 c0 	movl   $0xc01097fa,(%esp)
c01027ba:	e8 a6 db ff ff       	call   c0100365 <cprintf>
        break;
c01027bf:	eb 7e                	jmp    c010283f <trap_dispatch+0x170>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c01027c1:	e8 28 ef ff ff       	call   c01016ee <cons_getc>
c01027c6:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c01027c9:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c01027cd:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01027d1:	89 54 24 08          	mov    %edx,0x8(%esp)
c01027d5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01027d9:	c7 04 24 0c 98 10 c0 	movl   $0xc010980c,(%esp)
c01027e0:	e8 80 db ff ff       	call   c0100365 <cprintf>
        break;
c01027e5:	eb 58                	jmp    c010283f <trap_dispatch+0x170>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c01027e7:	c7 44 24 08 1b 98 10 	movl   $0xc010981b,0x8(%esp)
c01027ee:	c0 
c01027ef:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c01027f6:	00 
c01027f7:	c7 04 24 ce 97 10 c0 	movl   $0xc01097ce,(%esp)
c01027fe:	e8 0b e5 ff ff       	call   c0100d0e <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0102803:	8b 45 08             	mov    0x8(%ebp),%eax
c0102806:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010280a:	83 e0 03             	and    $0x3,%eax
c010280d:	85 c0                	test   %eax,%eax
c010280f:	75 2e                	jne    c010283f <trap_dispatch+0x170>
            print_trapframe(tf);
c0102811:	8b 45 08             	mov    0x8(%ebp),%eax
c0102814:	89 04 24             	mov    %eax,(%esp)
c0102817:	e8 65 fb ff ff       	call   c0102381 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c010281c:	c7 44 24 08 2b 98 10 	movl   $0xc010982b,0x8(%esp)
c0102823:	c0 
c0102824:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
c010282b:	00 
c010282c:	c7 04 24 ce 97 10 c0 	movl   $0xc01097ce,(%esp)
c0102833:	e8 d6 e4 ff ff       	call   c0100d0e <__panic>
        break;
c0102838:	90                   	nop
c0102839:	eb 04                	jmp    c010283f <trap_dispatch+0x170>
        break;
c010283b:	90                   	nop
c010283c:	eb 01                	jmp    c010283f <trap_dispatch+0x170>
        break;
c010283e:	90                   	nop
        }
    }
}
c010283f:	90                   	nop
c0102840:	89 ec                	mov    %ebp,%esp
c0102842:	5d                   	pop    %ebp
c0102843:	c3                   	ret    

c0102844 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0102844:	55                   	push   %ebp
c0102845:	89 e5                	mov    %esp,%ebp
c0102847:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c010284a:	8b 45 08             	mov    0x8(%ebp),%eax
c010284d:	89 04 24             	mov    %eax,(%esp)
c0102850:	e8 7a fe ff ff       	call   c01026cf <trap_dispatch>
}
c0102855:	90                   	nop
c0102856:	89 ec                	mov    %ebp,%esp
c0102858:	5d                   	pop    %ebp
c0102859:	c3                   	ret    

c010285a <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c010285a:	1e                   	push   %ds
    pushl %es
c010285b:	06                   	push   %es
    pushl %fs
c010285c:	0f a0                	push   %fs
    pushl %gs
c010285e:	0f a8                	push   %gs
    pushal
c0102860:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0102861:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0102866:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0102868:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c010286a:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c010286b:	e8 d4 ff ff ff       	call   c0102844 <trap>

    # pop the pushed stack pointer
    popl %esp
c0102870:	5c                   	pop    %esp

c0102871 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0102871:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0102872:	0f a9                	pop    %gs
    popl %fs
c0102874:	0f a1                	pop    %fs
    popl %es
c0102876:	07                   	pop    %es
    popl %ds
c0102877:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0102878:	83 c4 08             	add    $0x8,%esp
    iret
c010287b:	cf                   	iret   

c010287c <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c010287c:	6a 00                	push   $0x0
  pushl $0
c010287e:	6a 00                	push   $0x0
  jmp __alltraps
c0102880:	e9 d5 ff ff ff       	jmp    c010285a <__alltraps>

c0102885 <vector1>:
.globl vector1
vector1:
  pushl $0
c0102885:	6a 00                	push   $0x0
  pushl $1
c0102887:	6a 01                	push   $0x1
  jmp __alltraps
c0102889:	e9 cc ff ff ff       	jmp    c010285a <__alltraps>

c010288e <vector2>:
.globl vector2
vector2:
  pushl $0
c010288e:	6a 00                	push   $0x0
  pushl $2
c0102890:	6a 02                	push   $0x2
  jmp __alltraps
c0102892:	e9 c3 ff ff ff       	jmp    c010285a <__alltraps>

c0102897 <vector3>:
.globl vector3
vector3:
  pushl $0
c0102897:	6a 00                	push   $0x0
  pushl $3
c0102899:	6a 03                	push   $0x3
  jmp __alltraps
c010289b:	e9 ba ff ff ff       	jmp    c010285a <__alltraps>

c01028a0 <vector4>:
.globl vector4
vector4:
  pushl $0
c01028a0:	6a 00                	push   $0x0
  pushl $4
c01028a2:	6a 04                	push   $0x4
  jmp __alltraps
c01028a4:	e9 b1 ff ff ff       	jmp    c010285a <__alltraps>

c01028a9 <vector5>:
.globl vector5
vector5:
  pushl $0
c01028a9:	6a 00                	push   $0x0
  pushl $5
c01028ab:	6a 05                	push   $0x5
  jmp __alltraps
c01028ad:	e9 a8 ff ff ff       	jmp    c010285a <__alltraps>

c01028b2 <vector6>:
.globl vector6
vector6:
  pushl $0
c01028b2:	6a 00                	push   $0x0
  pushl $6
c01028b4:	6a 06                	push   $0x6
  jmp __alltraps
c01028b6:	e9 9f ff ff ff       	jmp    c010285a <__alltraps>

c01028bb <vector7>:
.globl vector7
vector7:
  pushl $0
c01028bb:	6a 00                	push   $0x0
  pushl $7
c01028bd:	6a 07                	push   $0x7
  jmp __alltraps
c01028bf:	e9 96 ff ff ff       	jmp    c010285a <__alltraps>

c01028c4 <vector8>:
.globl vector8
vector8:
  pushl $8
c01028c4:	6a 08                	push   $0x8
  jmp __alltraps
c01028c6:	e9 8f ff ff ff       	jmp    c010285a <__alltraps>

c01028cb <vector9>:
.globl vector9
vector9:
  pushl $0
c01028cb:	6a 00                	push   $0x0
  pushl $9
c01028cd:	6a 09                	push   $0x9
  jmp __alltraps
c01028cf:	e9 86 ff ff ff       	jmp    c010285a <__alltraps>

c01028d4 <vector10>:
.globl vector10
vector10:
  pushl $10
c01028d4:	6a 0a                	push   $0xa
  jmp __alltraps
c01028d6:	e9 7f ff ff ff       	jmp    c010285a <__alltraps>

c01028db <vector11>:
.globl vector11
vector11:
  pushl $11
c01028db:	6a 0b                	push   $0xb
  jmp __alltraps
c01028dd:	e9 78 ff ff ff       	jmp    c010285a <__alltraps>

c01028e2 <vector12>:
.globl vector12
vector12:
  pushl $12
c01028e2:	6a 0c                	push   $0xc
  jmp __alltraps
c01028e4:	e9 71 ff ff ff       	jmp    c010285a <__alltraps>

c01028e9 <vector13>:
.globl vector13
vector13:
  pushl $13
c01028e9:	6a 0d                	push   $0xd
  jmp __alltraps
c01028eb:	e9 6a ff ff ff       	jmp    c010285a <__alltraps>

c01028f0 <vector14>:
.globl vector14
vector14:
  pushl $14
c01028f0:	6a 0e                	push   $0xe
  jmp __alltraps
c01028f2:	e9 63 ff ff ff       	jmp    c010285a <__alltraps>

c01028f7 <vector15>:
.globl vector15
vector15:
  pushl $0
c01028f7:	6a 00                	push   $0x0
  pushl $15
c01028f9:	6a 0f                	push   $0xf
  jmp __alltraps
c01028fb:	e9 5a ff ff ff       	jmp    c010285a <__alltraps>

c0102900 <vector16>:
.globl vector16
vector16:
  pushl $0
c0102900:	6a 00                	push   $0x0
  pushl $16
c0102902:	6a 10                	push   $0x10
  jmp __alltraps
c0102904:	e9 51 ff ff ff       	jmp    c010285a <__alltraps>

c0102909 <vector17>:
.globl vector17
vector17:
  pushl $17
c0102909:	6a 11                	push   $0x11
  jmp __alltraps
c010290b:	e9 4a ff ff ff       	jmp    c010285a <__alltraps>

c0102910 <vector18>:
.globl vector18
vector18:
  pushl $0
c0102910:	6a 00                	push   $0x0
  pushl $18
c0102912:	6a 12                	push   $0x12
  jmp __alltraps
c0102914:	e9 41 ff ff ff       	jmp    c010285a <__alltraps>

c0102919 <vector19>:
.globl vector19
vector19:
  pushl $0
c0102919:	6a 00                	push   $0x0
  pushl $19
c010291b:	6a 13                	push   $0x13
  jmp __alltraps
c010291d:	e9 38 ff ff ff       	jmp    c010285a <__alltraps>

c0102922 <vector20>:
.globl vector20
vector20:
  pushl $0
c0102922:	6a 00                	push   $0x0
  pushl $20
c0102924:	6a 14                	push   $0x14
  jmp __alltraps
c0102926:	e9 2f ff ff ff       	jmp    c010285a <__alltraps>

c010292b <vector21>:
.globl vector21
vector21:
  pushl $0
c010292b:	6a 00                	push   $0x0
  pushl $21
c010292d:	6a 15                	push   $0x15
  jmp __alltraps
c010292f:	e9 26 ff ff ff       	jmp    c010285a <__alltraps>

c0102934 <vector22>:
.globl vector22
vector22:
  pushl $0
c0102934:	6a 00                	push   $0x0
  pushl $22
c0102936:	6a 16                	push   $0x16
  jmp __alltraps
c0102938:	e9 1d ff ff ff       	jmp    c010285a <__alltraps>

c010293d <vector23>:
.globl vector23
vector23:
  pushl $0
c010293d:	6a 00                	push   $0x0
  pushl $23
c010293f:	6a 17                	push   $0x17
  jmp __alltraps
c0102941:	e9 14 ff ff ff       	jmp    c010285a <__alltraps>

c0102946 <vector24>:
.globl vector24
vector24:
  pushl $0
c0102946:	6a 00                	push   $0x0
  pushl $24
c0102948:	6a 18                	push   $0x18
  jmp __alltraps
c010294a:	e9 0b ff ff ff       	jmp    c010285a <__alltraps>

c010294f <vector25>:
.globl vector25
vector25:
  pushl $0
c010294f:	6a 00                	push   $0x0
  pushl $25
c0102951:	6a 19                	push   $0x19
  jmp __alltraps
c0102953:	e9 02 ff ff ff       	jmp    c010285a <__alltraps>

c0102958 <vector26>:
.globl vector26
vector26:
  pushl $0
c0102958:	6a 00                	push   $0x0
  pushl $26
c010295a:	6a 1a                	push   $0x1a
  jmp __alltraps
c010295c:	e9 f9 fe ff ff       	jmp    c010285a <__alltraps>

c0102961 <vector27>:
.globl vector27
vector27:
  pushl $0
c0102961:	6a 00                	push   $0x0
  pushl $27
c0102963:	6a 1b                	push   $0x1b
  jmp __alltraps
c0102965:	e9 f0 fe ff ff       	jmp    c010285a <__alltraps>

c010296a <vector28>:
.globl vector28
vector28:
  pushl $0
c010296a:	6a 00                	push   $0x0
  pushl $28
c010296c:	6a 1c                	push   $0x1c
  jmp __alltraps
c010296e:	e9 e7 fe ff ff       	jmp    c010285a <__alltraps>

c0102973 <vector29>:
.globl vector29
vector29:
  pushl $0
c0102973:	6a 00                	push   $0x0
  pushl $29
c0102975:	6a 1d                	push   $0x1d
  jmp __alltraps
c0102977:	e9 de fe ff ff       	jmp    c010285a <__alltraps>

c010297c <vector30>:
.globl vector30
vector30:
  pushl $0
c010297c:	6a 00                	push   $0x0
  pushl $30
c010297e:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102980:	e9 d5 fe ff ff       	jmp    c010285a <__alltraps>

c0102985 <vector31>:
.globl vector31
vector31:
  pushl $0
c0102985:	6a 00                	push   $0x0
  pushl $31
c0102987:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102989:	e9 cc fe ff ff       	jmp    c010285a <__alltraps>

c010298e <vector32>:
.globl vector32
vector32:
  pushl $0
c010298e:	6a 00                	push   $0x0
  pushl $32
c0102990:	6a 20                	push   $0x20
  jmp __alltraps
c0102992:	e9 c3 fe ff ff       	jmp    c010285a <__alltraps>

c0102997 <vector33>:
.globl vector33
vector33:
  pushl $0
c0102997:	6a 00                	push   $0x0
  pushl $33
c0102999:	6a 21                	push   $0x21
  jmp __alltraps
c010299b:	e9 ba fe ff ff       	jmp    c010285a <__alltraps>

c01029a0 <vector34>:
.globl vector34
vector34:
  pushl $0
c01029a0:	6a 00                	push   $0x0
  pushl $34
c01029a2:	6a 22                	push   $0x22
  jmp __alltraps
c01029a4:	e9 b1 fe ff ff       	jmp    c010285a <__alltraps>

c01029a9 <vector35>:
.globl vector35
vector35:
  pushl $0
c01029a9:	6a 00                	push   $0x0
  pushl $35
c01029ab:	6a 23                	push   $0x23
  jmp __alltraps
c01029ad:	e9 a8 fe ff ff       	jmp    c010285a <__alltraps>

c01029b2 <vector36>:
.globl vector36
vector36:
  pushl $0
c01029b2:	6a 00                	push   $0x0
  pushl $36
c01029b4:	6a 24                	push   $0x24
  jmp __alltraps
c01029b6:	e9 9f fe ff ff       	jmp    c010285a <__alltraps>

c01029bb <vector37>:
.globl vector37
vector37:
  pushl $0
c01029bb:	6a 00                	push   $0x0
  pushl $37
c01029bd:	6a 25                	push   $0x25
  jmp __alltraps
c01029bf:	e9 96 fe ff ff       	jmp    c010285a <__alltraps>

c01029c4 <vector38>:
.globl vector38
vector38:
  pushl $0
c01029c4:	6a 00                	push   $0x0
  pushl $38
c01029c6:	6a 26                	push   $0x26
  jmp __alltraps
c01029c8:	e9 8d fe ff ff       	jmp    c010285a <__alltraps>

c01029cd <vector39>:
.globl vector39
vector39:
  pushl $0
c01029cd:	6a 00                	push   $0x0
  pushl $39
c01029cf:	6a 27                	push   $0x27
  jmp __alltraps
c01029d1:	e9 84 fe ff ff       	jmp    c010285a <__alltraps>

c01029d6 <vector40>:
.globl vector40
vector40:
  pushl $0
c01029d6:	6a 00                	push   $0x0
  pushl $40
c01029d8:	6a 28                	push   $0x28
  jmp __alltraps
c01029da:	e9 7b fe ff ff       	jmp    c010285a <__alltraps>

c01029df <vector41>:
.globl vector41
vector41:
  pushl $0
c01029df:	6a 00                	push   $0x0
  pushl $41
c01029e1:	6a 29                	push   $0x29
  jmp __alltraps
c01029e3:	e9 72 fe ff ff       	jmp    c010285a <__alltraps>

c01029e8 <vector42>:
.globl vector42
vector42:
  pushl $0
c01029e8:	6a 00                	push   $0x0
  pushl $42
c01029ea:	6a 2a                	push   $0x2a
  jmp __alltraps
c01029ec:	e9 69 fe ff ff       	jmp    c010285a <__alltraps>

c01029f1 <vector43>:
.globl vector43
vector43:
  pushl $0
c01029f1:	6a 00                	push   $0x0
  pushl $43
c01029f3:	6a 2b                	push   $0x2b
  jmp __alltraps
c01029f5:	e9 60 fe ff ff       	jmp    c010285a <__alltraps>

c01029fa <vector44>:
.globl vector44
vector44:
  pushl $0
c01029fa:	6a 00                	push   $0x0
  pushl $44
c01029fc:	6a 2c                	push   $0x2c
  jmp __alltraps
c01029fe:	e9 57 fe ff ff       	jmp    c010285a <__alltraps>

c0102a03 <vector45>:
.globl vector45
vector45:
  pushl $0
c0102a03:	6a 00                	push   $0x0
  pushl $45
c0102a05:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102a07:	e9 4e fe ff ff       	jmp    c010285a <__alltraps>

c0102a0c <vector46>:
.globl vector46
vector46:
  pushl $0
c0102a0c:	6a 00                	push   $0x0
  pushl $46
c0102a0e:	6a 2e                	push   $0x2e
  jmp __alltraps
c0102a10:	e9 45 fe ff ff       	jmp    c010285a <__alltraps>

c0102a15 <vector47>:
.globl vector47
vector47:
  pushl $0
c0102a15:	6a 00                	push   $0x0
  pushl $47
c0102a17:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102a19:	e9 3c fe ff ff       	jmp    c010285a <__alltraps>

c0102a1e <vector48>:
.globl vector48
vector48:
  pushl $0
c0102a1e:	6a 00                	push   $0x0
  pushl $48
c0102a20:	6a 30                	push   $0x30
  jmp __alltraps
c0102a22:	e9 33 fe ff ff       	jmp    c010285a <__alltraps>

c0102a27 <vector49>:
.globl vector49
vector49:
  pushl $0
c0102a27:	6a 00                	push   $0x0
  pushl $49
c0102a29:	6a 31                	push   $0x31
  jmp __alltraps
c0102a2b:	e9 2a fe ff ff       	jmp    c010285a <__alltraps>

c0102a30 <vector50>:
.globl vector50
vector50:
  pushl $0
c0102a30:	6a 00                	push   $0x0
  pushl $50
c0102a32:	6a 32                	push   $0x32
  jmp __alltraps
c0102a34:	e9 21 fe ff ff       	jmp    c010285a <__alltraps>

c0102a39 <vector51>:
.globl vector51
vector51:
  pushl $0
c0102a39:	6a 00                	push   $0x0
  pushl $51
c0102a3b:	6a 33                	push   $0x33
  jmp __alltraps
c0102a3d:	e9 18 fe ff ff       	jmp    c010285a <__alltraps>

c0102a42 <vector52>:
.globl vector52
vector52:
  pushl $0
c0102a42:	6a 00                	push   $0x0
  pushl $52
c0102a44:	6a 34                	push   $0x34
  jmp __alltraps
c0102a46:	e9 0f fe ff ff       	jmp    c010285a <__alltraps>

c0102a4b <vector53>:
.globl vector53
vector53:
  pushl $0
c0102a4b:	6a 00                	push   $0x0
  pushl $53
c0102a4d:	6a 35                	push   $0x35
  jmp __alltraps
c0102a4f:	e9 06 fe ff ff       	jmp    c010285a <__alltraps>

c0102a54 <vector54>:
.globl vector54
vector54:
  pushl $0
c0102a54:	6a 00                	push   $0x0
  pushl $54
c0102a56:	6a 36                	push   $0x36
  jmp __alltraps
c0102a58:	e9 fd fd ff ff       	jmp    c010285a <__alltraps>

c0102a5d <vector55>:
.globl vector55
vector55:
  pushl $0
c0102a5d:	6a 00                	push   $0x0
  pushl $55
c0102a5f:	6a 37                	push   $0x37
  jmp __alltraps
c0102a61:	e9 f4 fd ff ff       	jmp    c010285a <__alltraps>

c0102a66 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102a66:	6a 00                	push   $0x0
  pushl $56
c0102a68:	6a 38                	push   $0x38
  jmp __alltraps
c0102a6a:	e9 eb fd ff ff       	jmp    c010285a <__alltraps>

c0102a6f <vector57>:
.globl vector57
vector57:
  pushl $0
c0102a6f:	6a 00                	push   $0x0
  pushl $57
c0102a71:	6a 39                	push   $0x39
  jmp __alltraps
c0102a73:	e9 e2 fd ff ff       	jmp    c010285a <__alltraps>

c0102a78 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102a78:	6a 00                	push   $0x0
  pushl $58
c0102a7a:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102a7c:	e9 d9 fd ff ff       	jmp    c010285a <__alltraps>

c0102a81 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102a81:	6a 00                	push   $0x0
  pushl $59
c0102a83:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102a85:	e9 d0 fd ff ff       	jmp    c010285a <__alltraps>

c0102a8a <vector60>:
.globl vector60
vector60:
  pushl $0
c0102a8a:	6a 00                	push   $0x0
  pushl $60
c0102a8c:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102a8e:	e9 c7 fd ff ff       	jmp    c010285a <__alltraps>

c0102a93 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102a93:	6a 00                	push   $0x0
  pushl $61
c0102a95:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102a97:	e9 be fd ff ff       	jmp    c010285a <__alltraps>

c0102a9c <vector62>:
.globl vector62
vector62:
  pushl $0
c0102a9c:	6a 00                	push   $0x0
  pushl $62
c0102a9e:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102aa0:	e9 b5 fd ff ff       	jmp    c010285a <__alltraps>

c0102aa5 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102aa5:	6a 00                	push   $0x0
  pushl $63
c0102aa7:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102aa9:	e9 ac fd ff ff       	jmp    c010285a <__alltraps>

c0102aae <vector64>:
.globl vector64
vector64:
  pushl $0
c0102aae:	6a 00                	push   $0x0
  pushl $64
c0102ab0:	6a 40                	push   $0x40
  jmp __alltraps
c0102ab2:	e9 a3 fd ff ff       	jmp    c010285a <__alltraps>

c0102ab7 <vector65>:
.globl vector65
vector65:
  pushl $0
c0102ab7:	6a 00                	push   $0x0
  pushl $65
c0102ab9:	6a 41                	push   $0x41
  jmp __alltraps
c0102abb:	e9 9a fd ff ff       	jmp    c010285a <__alltraps>

c0102ac0 <vector66>:
.globl vector66
vector66:
  pushl $0
c0102ac0:	6a 00                	push   $0x0
  pushl $66
c0102ac2:	6a 42                	push   $0x42
  jmp __alltraps
c0102ac4:	e9 91 fd ff ff       	jmp    c010285a <__alltraps>

c0102ac9 <vector67>:
.globl vector67
vector67:
  pushl $0
c0102ac9:	6a 00                	push   $0x0
  pushl $67
c0102acb:	6a 43                	push   $0x43
  jmp __alltraps
c0102acd:	e9 88 fd ff ff       	jmp    c010285a <__alltraps>

c0102ad2 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102ad2:	6a 00                	push   $0x0
  pushl $68
c0102ad4:	6a 44                	push   $0x44
  jmp __alltraps
c0102ad6:	e9 7f fd ff ff       	jmp    c010285a <__alltraps>

c0102adb <vector69>:
.globl vector69
vector69:
  pushl $0
c0102adb:	6a 00                	push   $0x0
  pushl $69
c0102add:	6a 45                	push   $0x45
  jmp __alltraps
c0102adf:	e9 76 fd ff ff       	jmp    c010285a <__alltraps>

c0102ae4 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102ae4:	6a 00                	push   $0x0
  pushl $70
c0102ae6:	6a 46                	push   $0x46
  jmp __alltraps
c0102ae8:	e9 6d fd ff ff       	jmp    c010285a <__alltraps>

c0102aed <vector71>:
.globl vector71
vector71:
  pushl $0
c0102aed:	6a 00                	push   $0x0
  pushl $71
c0102aef:	6a 47                	push   $0x47
  jmp __alltraps
c0102af1:	e9 64 fd ff ff       	jmp    c010285a <__alltraps>

c0102af6 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102af6:	6a 00                	push   $0x0
  pushl $72
c0102af8:	6a 48                	push   $0x48
  jmp __alltraps
c0102afa:	e9 5b fd ff ff       	jmp    c010285a <__alltraps>

c0102aff <vector73>:
.globl vector73
vector73:
  pushl $0
c0102aff:	6a 00                	push   $0x0
  pushl $73
c0102b01:	6a 49                	push   $0x49
  jmp __alltraps
c0102b03:	e9 52 fd ff ff       	jmp    c010285a <__alltraps>

c0102b08 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102b08:	6a 00                	push   $0x0
  pushl $74
c0102b0a:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102b0c:	e9 49 fd ff ff       	jmp    c010285a <__alltraps>

c0102b11 <vector75>:
.globl vector75
vector75:
  pushl $0
c0102b11:	6a 00                	push   $0x0
  pushl $75
c0102b13:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102b15:	e9 40 fd ff ff       	jmp    c010285a <__alltraps>

c0102b1a <vector76>:
.globl vector76
vector76:
  pushl $0
c0102b1a:	6a 00                	push   $0x0
  pushl $76
c0102b1c:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102b1e:	e9 37 fd ff ff       	jmp    c010285a <__alltraps>

c0102b23 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102b23:	6a 00                	push   $0x0
  pushl $77
c0102b25:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102b27:	e9 2e fd ff ff       	jmp    c010285a <__alltraps>

c0102b2c <vector78>:
.globl vector78
vector78:
  pushl $0
c0102b2c:	6a 00                	push   $0x0
  pushl $78
c0102b2e:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102b30:	e9 25 fd ff ff       	jmp    c010285a <__alltraps>

c0102b35 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102b35:	6a 00                	push   $0x0
  pushl $79
c0102b37:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102b39:	e9 1c fd ff ff       	jmp    c010285a <__alltraps>

c0102b3e <vector80>:
.globl vector80
vector80:
  pushl $0
c0102b3e:	6a 00                	push   $0x0
  pushl $80
c0102b40:	6a 50                	push   $0x50
  jmp __alltraps
c0102b42:	e9 13 fd ff ff       	jmp    c010285a <__alltraps>

c0102b47 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102b47:	6a 00                	push   $0x0
  pushl $81
c0102b49:	6a 51                	push   $0x51
  jmp __alltraps
c0102b4b:	e9 0a fd ff ff       	jmp    c010285a <__alltraps>

c0102b50 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102b50:	6a 00                	push   $0x0
  pushl $82
c0102b52:	6a 52                	push   $0x52
  jmp __alltraps
c0102b54:	e9 01 fd ff ff       	jmp    c010285a <__alltraps>

c0102b59 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102b59:	6a 00                	push   $0x0
  pushl $83
c0102b5b:	6a 53                	push   $0x53
  jmp __alltraps
c0102b5d:	e9 f8 fc ff ff       	jmp    c010285a <__alltraps>

c0102b62 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102b62:	6a 00                	push   $0x0
  pushl $84
c0102b64:	6a 54                	push   $0x54
  jmp __alltraps
c0102b66:	e9 ef fc ff ff       	jmp    c010285a <__alltraps>

c0102b6b <vector85>:
.globl vector85
vector85:
  pushl $0
c0102b6b:	6a 00                	push   $0x0
  pushl $85
c0102b6d:	6a 55                	push   $0x55
  jmp __alltraps
c0102b6f:	e9 e6 fc ff ff       	jmp    c010285a <__alltraps>

c0102b74 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102b74:	6a 00                	push   $0x0
  pushl $86
c0102b76:	6a 56                	push   $0x56
  jmp __alltraps
c0102b78:	e9 dd fc ff ff       	jmp    c010285a <__alltraps>

c0102b7d <vector87>:
.globl vector87
vector87:
  pushl $0
c0102b7d:	6a 00                	push   $0x0
  pushl $87
c0102b7f:	6a 57                	push   $0x57
  jmp __alltraps
c0102b81:	e9 d4 fc ff ff       	jmp    c010285a <__alltraps>

c0102b86 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102b86:	6a 00                	push   $0x0
  pushl $88
c0102b88:	6a 58                	push   $0x58
  jmp __alltraps
c0102b8a:	e9 cb fc ff ff       	jmp    c010285a <__alltraps>

c0102b8f <vector89>:
.globl vector89
vector89:
  pushl $0
c0102b8f:	6a 00                	push   $0x0
  pushl $89
c0102b91:	6a 59                	push   $0x59
  jmp __alltraps
c0102b93:	e9 c2 fc ff ff       	jmp    c010285a <__alltraps>

c0102b98 <vector90>:
.globl vector90
vector90:
  pushl $0
c0102b98:	6a 00                	push   $0x0
  pushl $90
c0102b9a:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102b9c:	e9 b9 fc ff ff       	jmp    c010285a <__alltraps>

c0102ba1 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102ba1:	6a 00                	push   $0x0
  pushl $91
c0102ba3:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102ba5:	e9 b0 fc ff ff       	jmp    c010285a <__alltraps>

c0102baa <vector92>:
.globl vector92
vector92:
  pushl $0
c0102baa:	6a 00                	push   $0x0
  pushl $92
c0102bac:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102bae:	e9 a7 fc ff ff       	jmp    c010285a <__alltraps>

c0102bb3 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102bb3:	6a 00                	push   $0x0
  pushl $93
c0102bb5:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102bb7:	e9 9e fc ff ff       	jmp    c010285a <__alltraps>

c0102bbc <vector94>:
.globl vector94
vector94:
  pushl $0
c0102bbc:	6a 00                	push   $0x0
  pushl $94
c0102bbe:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102bc0:	e9 95 fc ff ff       	jmp    c010285a <__alltraps>

c0102bc5 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102bc5:	6a 00                	push   $0x0
  pushl $95
c0102bc7:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102bc9:	e9 8c fc ff ff       	jmp    c010285a <__alltraps>

c0102bce <vector96>:
.globl vector96
vector96:
  pushl $0
c0102bce:	6a 00                	push   $0x0
  pushl $96
c0102bd0:	6a 60                	push   $0x60
  jmp __alltraps
c0102bd2:	e9 83 fc ff ff       	jmp    c010285a <__alltraps>

c0102bd7 <vector97>:
.globl vector97
vector97:
  pushl $0
c0102bd7:	6a 00                	push   $0x0
  pushl $97
c0102bd9:	6a 61                	push   $0x61
  jmp __alltraps
c0102bdb:	e9 7a fc ff ff       	jmp    c010285a <__alltraps>

c0102be0 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102be0:	6a 00                	push   $0x0
  pushl $98
c0102be2:	6a 62                	push   $0x62
  jmp __alltraps
c0102be4:	e9 71 fc ff ff       	jmp    c010285a <__alltraps>

c0102be9 <vector99>:
.globl vector99
vector99:
  pushl $0
c0102be9:	6a 00                	push   $0x0
  pushl $99
c0102beb:	6a 63                	push   $0x63
  jmp __alltraps
c0102bed:	e9 68 fc ff ff       	jmp    c010285a <__alltraps>

c0102bf2 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102bf2:	6a 00                	push   $0x0
  pushl $100
c0102bf4:	6a 64                	push   $0x64
  jmp __alltraps
c0102bf6:	e9 5f fc ff ff       	jmp    c010285a <__alltraps>

c0102bfb <vector101>:
.globl vector101
vector101:
  pushl $0
c0102bfb:	6a 00                	push   $0x0
  pushl $101
c0102bfd:	6a 65                	push   $0x65
  jmp __alltraps
c0102bff:	e9 56 fc ff ff       	jmp    c010285a <__alltraps>

c0102c04 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102c04:	6a 00                	push   $0x0
  pushl $102
c0102c06:	6a 66                	push   $0x66
  jmp __alltraps
c0102c08:	e9 4d fc ff ff       	jmp    c010285a <__alltraps>

c0102c0d <vector103>:
.globl vector103
vector103:
  pushl $0
c0102c0d:	6a 00                	push   $0x0
  pushl $103
c0102c0f:	6a 67                	push   $0x67
  jmp __alltraps
c0102c11:	e9 44 fc ff ff       	jmp    c010285a <__alltraps>

c0102c16 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102c16:	6a 00                	push   $0x0
  pushl $104
c0102c18:	6a 68                	push   $0x68
  jmp __alltraps
c0102c1a:	e9 3b fc ff ff       	jmp    c010285a <__alltraps>

c0102c1f <vector105>:
.globl vector105
vector105:
  pushl $0
c0102c1f:	6a 00                	push   $0x0
  pushl $105
c0102c21:	6a 69                	push   $0x69
  jmp __alltraps
c0102c23:	e9 32 fc ff ff       	jmp    c010285a <__alltraps>

c0102c28 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102c28:	6a 00                	push   $0x0
  pushl $106
c0102c2a:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102c2c:	e9 29 fc ff ff       	jmp    c010285a <__alltraps>

c0102c31 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102c31:	6a 00                	push   $0x0
  pushl $107
c0102c33:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102c35:	e9 20 fc ff ff       	jmp    c010285a <__alltraps>

c0102c3a <vector108>:
.globl vector108
vector108:
  pushl $0
c0102c3a:	6a 00                	push   $0x0
  pushl $108
c0102c3c:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102c3e:	e9 17 fc ff ff       	jmp    c010285a <__alltraps>

c0102c43 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102c43:	6a 00                	push   $0x0
  pushl $109
c0102c45:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102c47:	e9 0e fc ff ff       	jmp    c010285a <__alltraps>

c0102c4c <vector110>:
.globl vector110
vector110:
  pushl $0
c0102c4c:	6a 00                	push   $0x0
  pushl $110
c0102c4e:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102c50:	e9 05 fc ff ff       	jmp    c010285a <__alltraps>

c0102c55 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102c55:	6a 00                	push   $0x0
  pushl $111
c0102c57:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102c59:	e9 fc fb ff ff       	jmp    c010285a <__alltraps>

c0102c5e <vector112>:
.globl vector112
vector112:
  pushl $0
c0102c5e:	6a 00                	push   $0x0
  pushl $112
c0102c60:	6a 70                	push   $0x70
  jmp __alltraps
c0102c62:	e9 f3 fb ff ff       	jmp    c010285a <__alltraps>

c0102c67 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102c67:	6a 00                	push   $0x0
  pushl $113
c0102c69:	6a 71                	push   $0x71
  jmp __alltraps
c0102c6b:	e9 ea fb ff ff       	jmp    c010285a <__alltraps>

c0102c70 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102c70:	6a 00                	push   $0x0
  pushl $114
c0102c72:	6a 72                	push   $0x72
  jmp __alltraps
c0102c74:	e9 e1 fb ff ff       	jmp    c010285a <__alltraps>

c0102c79 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102c79:	6a 00                	push   $0x0
  pushl $115
c0102c7b:	6a 73                	push   $0x73
  jmp __alltraps
c0102c7d:	e9 d8 fb ff ff       	jmp    c010285a <__alltraps>

c0102c82 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102c82:	6a 00                	push   $0x0
  pushl $116
c0102c84:	6a 74                	push   $0x74
  jmp __alltraps
c0102c86:	e9 cf fb ff ff       	jmp    c010285a <__alltraps>

c0102c8b <vector117>:
.globl vector117
vector117:
  pushl $0
c0102c8b:	6a 00                	push   $0x0
  pushl $117
c0102c8d:	6a 75                	push   $0x75
  jmp __alltraps
c0102c8f:	e9 c6 fb ff ff       	jmp    c010285a <__alltraps>

c0102c94 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102c94:	6a 00                	push   $0x0
  pushl $118
c0102c96:	6a 76                	push   $0x76
  jmp __alltraps
c0102c98:	e9 bd fb ff ff       	jmp    c010285a <__alltraps>

c0102c9d <vector119>:
.globl vector119
vector119:
  pushl $0
c0102c9d:	6a 00                	push   $0x0
  pushl $119
c0102c9f:	6a 77                	push   $0x77
  jmp __alltraps
c0102ca1:	e9 b4 fb ff ff       	jmp    c010285a <__alltraps>

c0102ca6 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102ca6:	6a 00                	push   $0x0
  pushl $120
c0102ca8:	6a 78                	push   $0x78
  jmp __alltraps
c0102caa:	e9 ab fb ff ff       	jmp    c010285a <__alltraps>

c0102caf <vector121>:
.globl vector121
vector121:
  pushl $0
c0102caf:	6a 00                	push   $0x0
  pushl $121
c0102cb1:	6a 79                	push   $0x79
  jmp __alltraps
c0102cb3:	e9 a2 fb ff ff       	jmp    c010285a <__alltraps>

c0102cb8 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102cb8:	6a 00                	push   $0x0
  pushl $122
c0102cba:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102cbc:	e9 99 fb ff ff       	jmp    c010285a <__alltraps>

c0102cc1 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102cc1:	6a 00                	push   $0x0
  pushl $123
c0102cc3:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102cc5:	e9 90 fb ff ff       	jmp    c010285a <__alltraps>

c0102cca <vector124>:
.globl vector124
vector124:
  pushl $0
c0102cca:	6a 00                	push   $0x0
  pushl $124
c0102ccc:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102cce:	e9 87 fb ff ff       	jmp    c010285a <__alltraps>

c0102cd3 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102cd3:	6a 00                	push   $0x0
  pushl $125
c0102cd5:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102cd7:	e9 7e fb ff ff       	jmp    c010285a <__alltraps>

c0102cdc <vector126>:
.globl vector126
vector126:
  pushl $0
c0102cdc:	6a 00                	push   $0x0
  pushl $126
c0102cde:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102ce0:	e9 75 fb ff ff       	jmp    c010285a <__alltraps>

c0102ce5 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102ce5:	6a 00                	push   $0x0
  pushl $127
c0102ce7:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102ce9:	e9 6c fb ff ff       	jmp    c010285a <__alltraps>

c0102cee <vector128>:
.globl vector128
vector128:
  pushl $0
c0102cee:	6a 00                	push   $0x0
  pushl $128
c0102cf0:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102cf5:	e9 60 fb ff ff       	jmp    c010285a <__alltraps>

c0102cfa <vector129>:
.globl vector129
vector129:
  pushl $0
c0102cfa:	6a 00                	push   $0x0
  pushl $129
c0102cfc:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102d01:	e9 54 fb ff ff       	jmp    c010285a <__alltraps>

c0102d06 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102d06:	6a 00                	push   $0x0
  pushl $130
c0102d08:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102d0d:	e9 48 fb ff ff       	jmp    c010285a <__alltraps>

c0102d12 <vector131>:
.globl vector131
vector131:
  pushl $0
c0102d12:	6a 00                	push   $0x0
  pushl $131
c0102d14:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102d19:	e9 3c fb ff ff       	jmp    c010285a <__alltraps>

c0102d1e <vector132>:
.globl vector132
vector132:
  pushl $0
c0102d1e:	6a 00                	push   $0x0
  pushl $132
c0102d20:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102d25:	e9 30 fb ff ff       	jmp    c010285a <__alltraps>

c0102d2a <vector133>:
.globl vector133
vector133:
  pushl $0
c0102d2a:	6a 00                	push   $0x0
  pushl $133
c0102d2c:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102d31:	e9 24 fb ff ff       	jmp    c010285a <__alltraps>

c0102d36 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102d36:	6a 00                	push   $0x0
  pushl $134
c0102d38:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102d3d:	e9 18 fb ff ff       	jmp    c010285a <__alltraps>

c0102d42 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102d42:	6a 00                	push   $0x0
  pushl $135
c0102d44:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102d49:	e9 0c fb ff ff       	jmp    c010285a <__alltraps>

c0102d4e <vector136>:
.globl vector136
vector136:
  pushl $0
c0102d4e:	6a 00                	push   $0x0
  pushl $136
c0102d50:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102d55:	e9 00 fb ff ff       	jmp    c010285a <__alltraps>

c0102d5a <vector137>:
.globl vector137
vector137:
  pushl $0
c0102d5a:	6a 00                	push   $0x0
  pushl $137
c0102d5c:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102d61:	e9 f4 fa ff ff       	jmp    c010285a <__alltraps>

c0102d66 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102d66:	6a 00                	push   $0x0
  pushl $138
c0102d68:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102d6d:	e9 e8 fa ff ff       	jmp    c010285a <__alltraps>

c0102d72 <vector139>:
.globl vector139
vector139:
  pushl $0
c0102d72:	6a 00                	push   $0x0
  pushl $139
c0102d74:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102d79:	e9 dc fa ff ff       	jmp    c010285a <__alltraps>

c0102d7e <vector140>:
.globl vector140
vector140:
  pushl $0
c0102d7e:	6a 00                	push   $0x0
  pushl $140
c0102d80:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102d85:	e9 d0 fa ff ff       	jmp    c010285a <__alltraps>

c0102d8a <vector141>:
.globl vector141
vector141:
  pushl $0
c0102d8a:	6a 00                	push   $0x0
  pushl $141
c0102d8c:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102d91:	e9 c4 fa ff ff       	jmp    c010285a <__alltraps>

c0102d96 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102d96:	6a 00                	push   $0x0
  pushl $142
c0102d98:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102d9d:	e9 b8 fa ff ff       	jmp    c010285a <__alltraps>

c0102da2 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102da2:	6a 00                	push   $0x0
  pushl $143
c0102da4:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102da9:	e9 ac fa ff ff       	jmp    c010285a <__alltraps>

c0102dae <vector144>:
.globl vector144
vector144:
  pushl $0
c0102dae:	6a 00                	push   $0x0
  pushl $144
c0102db0:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102db5:	e9 a0 fa ff ff       	jmp    c010285a <__alltraps>

c0102dba <vector145>:
.globl vector145
vector145:
  pushl $0
c0102dba:	6a 00                	push   $0x0
  pushl $145
c0102dbc:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102dc1:	e9 94 fa ff ff       	jmp    c010285a <__alltraps>

c0102dc6 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102dc6:	6a 00                	push   $0x0
  pushl $146
c0102dc8:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102dcd:	e9 88 fa ff ff       	jmp    c010285a <__alltraps>

c0102dd2 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102dd2:	6a 00                	push   $0x0
  pushl $147
c0102dd4:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102dd9:	e9 7c fa ff ff       	jmp    c010285a <__alltraps>

c0102dde <vector148>:
.globl vector148
vector148:
  pushl $0
c0102dde:	6a 00                	push   $0x0
  pushl $148
c0102de0:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102de5:	e9 70 fa ff ff       	jmp    c010285a <__alltraps>

c0102dea <vector149>:
.globl vector149
vector149:
  pushl $0
c0102dea:	6a 00                	push   $0x0
  pushl $149
c0102dec:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102df1:	e9 64 fa ff ff       	jmp    c010285a <__alltraps>

c0102df6 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102df6:	6a 00                	push   $0x0
  pushl $150
c0102df8:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102dfd:	e9 58 fa ff ff       	jmp    c010285a <__alltraps>

c0102e02 <vector151>:
.globl vector151
vector151:
  pushl $0
c0102e02:	6a 00                	push   $0x0
  pushl $151
c0102e04:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102e09:	e9 4c fa ff ff       	jmp    c010285a <__alltraps>

c0102e0e <vector152>:
.globl vector152
vector152:
  pushl $0
c0102e0e:	6a 00                	push   $0x0
  pushl $152
c0102e10:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102e15:	e9 40 fa ff ff       	jmp    c010285a <__alltraps>

c0102e1a <vector153>:
.globl vector153
vector153:
  pushl $0
c0102e1a:	6a 00                	push   $0x0
  pushl $153
c0102e1c:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102e21:	e9 34 fa ff ff       	jmp    c010285a <__alltraps>

c0102e26 <vector154>:
.globl vector154
vector154:
  pushl $0
c0102e26:	6a 00                	push   $0x0
  pushl $154
c0102e28:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102e2d:	e9 28 fa ff ff       	jmp    c010285a <__alltraps>

c0102e32 <vector155>:
.globl vector155
vector155:
  pushl $0
c0102e32:	6a 00                	push   $0x0
  pushl $155
c0102e34:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102e39:	e9 1c fa ff ff       	jmp    c010285a <__alltraps>

c0102e3e <vector156>:
.globl vector156
vector156:
  pushl $0
c0102e3e:	6a 00                	push   $0x0
  pushl $156
c0102e40:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102e45:	e9 10 fa ff ff       	jmp    c010285a <__alltraps>

c0102e4a <vector157>:
.globl vector157
vector157:
  pushl $0
c0102e4a:	6a 00                	push   $0x0
  pushl $157
c0102e4c:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102e51:	e9 04 fa ff ff       	jmp    c010285a <__alltraps>

c0102e56 <vector158>:
.globl vector158
vector158:
  pushl $0
c0102e56:	6a 00                	push   $0x0
  pushl $158
c0102e58:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102e5d:	e9 f8 f9 ff ff       	jmp    c010285a <__alltraps>

c0102e62 <vector159>:
.globl vector159
vector159:
  pushl $0
c0102e62:	6a 00                	push   $0x0
  pushl $159
c0102e64:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102e69:	e9 ec f9 ff ff       	jmp    c010285a <__alltraps>

c0102e6e <vector160>:
.globl vector160
vector160:
  pushl $0
c0102e6e:	6a 00                	push   $0x0
  pushl $160
c0102e70:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102e75:	e9 e0 f9 ff ff       	jmp    c010285a <__alltraps>

c0102e7a <vector161>:
.globl vector161
vector161:
  pushl $0
c0102e7a:	6a 00                	push   $0x0
  pushl $161
c0102e7c:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102e81:	e9 d4 f9 ff ff       	jmp    c010285a <__alltraps>

c0102e86 <vector162>:
.globl vector162
vector162:
  pushl $0
c0102e86:	6a 00                	push   $0x0
  pushl $162
c0102e88:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102e8d:	e9 c8 f9 ff ff       	jmp    c010285a <__alltraps>

c0102e92 <vector163>:
.globl vector163
vector163:
  pushl $0
c0102e92:	6a 00                	push   $0x0
  pushl $163
c0102e94:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102e99:	e9 bc f9 ff ff       	jmp    c010285a <__alltraps>

c0102e9e <vector164>:
.globl vector164
vector164:
  pushl $0
c0102e9e:	6a 00                	push   $0x0
  pushl $164
c0102ea0:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102ea5:	e9 b0 f9 ff ff       	jmp    c010285a <__alltraps>

c0102eaa <vector165>:
.globl vector165
vector165:
  pushl $0
c0102eaa:	6a 00                	push   $0x0
  pushl $165
c0102eac:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102eb1:	e9 a4 f9 ff ff       	jmp    c010285a <__alltraps>

c0102eb6 <vector166>:
.globl vector166
vector166:
  pushl $0
c0102eb6:	6a 00                	push   $0x0
  pushl $166
c0102eb8:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0102ebd:	e9 98 f9 ff ff       	jmp    c010285a <__alltraps>

c0102ec2 <vector167>:
.globl vector167
vector167:
  pushl $0
c0102ec2:	6a 00                	push   $0x0
  pushl $167
c0102ec4:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102ec9:	e9 8c f9 ff ff       	jmp    c010285a <__alltraps>

c0102ece <vector168>:
.globl vector168
vector168:
  pushl $0
c0102ece:	6a 00                	push   $0x0
  pushl $168
c0102ed0:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102ed5:	e9 80 f9 ff ff       	jmp    c010285a <__alltraps>

c0102eda <vector169>:
.globl vector169
vector169:
  pushl $0
c0102eda:	6a 00                	push   $0x0
  pushl $169
c0102edc:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102ee1:	e9 74 f9 ff ff       	jmp    c010285a <__alltraps>

c0102ee6 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102ee6:	6a 00                	push   $0x0
  pushl $170
c0102ee8:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102eed:	e9 68 f9 ff ff       	jmp    c010285a <__alltraps>

c0102ef2 <vector171>:
.globl vector171
vector171:
  pushl $0
c0102ef2:	6a 00                	push   $0x0
  pushl $171
c0102ef4:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102ef9:	e9 5c f9 ff ff       	jmp    c010285a <__alltraps>

c0102efe <vector172>:
.globl vector172
vector172:
  pushl $0
c0102efe:	6a 00                	push   $0x0
  pushl $172
c0102f00:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102f05:	e9 50 f9 ff ff       	jmp    c010285a <__alltraps>

c0102f0a <vector173>:
.globl vector173
vector173:
  pushl $0
c0102f0a:	6a 00                	push   $0x0
  pushl $173
c0102f0c:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102f11:	e9 44 f9 ff ff       	jmp    c010285a <__alltraps>

c0102f16 <vector174>:
.globl vector174
vector174:
  pushl $0
c0102f16:	6a 00                	push   $0x0
  pushl $174
c0102f18:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102f1d:	e9 38 f9 ff ff       	jmp    c010285a <__alltraps>

c0102f22 <vector175>:
.globl vector175
vector175:
  pushl $0
c0102f22:	6a 00                	push   $0x0
  pushl $175
c0102f24:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102f29:	e9 2c f9 ff ff       	jmp    c010285a <__alltraps>

c0102f2e <vector176>:
.globl vector176
vector176:
  pushl $0
c0102f2e:	6a 00                	push   $0x0
  pushl $176
c0102f30:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102f35:	e9 20 f9 ff ff       	jmp    c010285a <__alltraps>

c0102f3a <vector177>:
.globl vector177
vector177:
  pushl $0
c0102f3a:	6a 00                	push   $0x0
  pushl $177
c0102f3c:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102f41:	e9 14 f9 ff ff       	jmp    c010285a <__alltraps>

c0102f46 <vector178>:
.globl vector178
vector178:
  pushl $0
c0102f46:	6a 00                	push   $0x0
  pushl $178
c0102f48:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102f4d:	e9 08 f9 ff ff       	jmp    c010285a <__alltraps>

c0102f52 <vector179>:
.globl vector179
vector179:
  pushl $0
c0102f52:	6a 00                	push   $0x0
  pushl $179
c0102f54:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102f59:	e9 fc f8 ff ff       	jmp    c010285a <__alltraps>

c0102f5e <vector180>:
.globl vector180
vector180:
  pushl $0
c0102f5e:	6a 00                	push   $0x0
  pushl $180
c0102f60:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102f65:	e9 f0 f8 ff ff       	jmp    c010285a <__alltraps>

c0102f6a <vector181>:
.globl vector181
vector181:
  pushl $0
c0102f6a:	6a 00                	push   $0x0
  pushl $181
c0102f6c:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0102f71:	e9 e4 f8 ff ff       	jmp    c010285a <__alltraps>

c0102f76 <vector182>:
.globl vector182
vector182:
  pushl $0
c0102f76:	6a 00                	push   $0x0
  pushl $182
c0102f78:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102f7d:	e9 d8 f8 ff ff       	jmp    c010285a <__alltraps>

c0102f82 <vector183>:
.globl vector183
vector183:
  pushl $0
c0102f82:	6a 00                	push   $0x0
  pushl $183
c0102f84:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0102f89:	e9 cc f8 ff ff       	jmp    c010285a <__alltraps>

c0102f8e <vector184>:
.globl vector184
vector184:
  pushl $0
c0102f8e:	6a 00                	push   $0x0
  pushl $184
c0102f90:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0102f95:	e9 c0 f8 ff ff       	jmp    c010285a <__alltraps>

c0102f9a <vector185>:
.globl vector185
vector185:
  pushl $0
c0102f9a:	6a 00                	push   $0x0
  pushl $185
c0102f9c:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102fa1:	e9 b4 f8 ff ff       	jmp    c010285a <__alltraps>

c0102fa6 <vector186>:
.globl vector186
vector186:
  pushl $0
c0102fa6:	6a 00                	push   $0x0
  pushl $186
c0102fa8:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0102fad:	e9 a8 f8 ff ff       	jmp    c010285a <__alltraps>

c0102fb2 <vector187>:
.globl vector187
vector187:
  pushl $0
c0102fb2:	6a 00                	push   $0x0
  pushl $187
c0102fb4:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0102fb9:	e9 9c f8 ff ff       	jmp    c010285a <__alltraps>

c0102fbe <vector188>:
.globl vector188
vector188:
  pushl $0
c0102fbe:	6a 00                	push   $0x0
  pushl $188
c0102fc0:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0102fc5:	e9 90 f8 ff ff       	jmp    c010285a <__alltraps>

c0102fca <vector189>:
.globl vector189
vector189:
  pushl $0
c0102fca:	6a 00                	push   $0x0
  pushl $189
c0102fcc:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102fd1:	e9 84 f8 ff ff       	jmp    c010285a <__alltraps>

c0102fd6 <vector190>:
.globl vector190
vector190:
  pushl $0
c0102fd6:	6a 00                	push   $0x0
  pushl $190
c0102fd8:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0102fdd:	e9 78 f8 ff ff       	jmp    c010285a <__alltraps>

c0102fe2 <vector191>:
.globl vector191
vector191:
  pushl $0
c0102fe2:	6a 00                	push   $0x0
  pushl $191
c0102fe4:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0102fe9:	e9 6c f8 ff ff       	jmp    c010285a <__alltraps>

c0102fee <vector192>:
.globl vector192
vector192:
  pushl $0
c0102fee:	6a 00                	push   $0x0
  pushl $192
c0102ff0:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102ff5:	e9 60 f8 ff ff       	jmp    c010285a <__alltraps>

c0102ffa <vector193>:
.globl vector193
vector193:
  pushl $0
c0102ffa:	6a 00                	push   $0x0
  pushl $193
c0102ffc:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0103001:	e9 54 f8 ff ff       	jmp    c010285a <__alltraps>

c0103006 <vector194>:
.globl vector194
vector194:
  pushl $0
c0103006:	6a 00                	push   $0x0
  pushl $194
c0103008:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c010300d:	e9 48 f8 ff ff       	jmp    c010285a <__alltraps>

c0103012 <vector195>:
.globl vector195
vector195:
  pushl $0
c0103012:	6a 00                	push   $0x0
  pushl $195
c0103014:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0103019:	e9 3c f8 ff ff       	jmp    c010285a <__alltraps>

c010301e <vector196>:
.globl vector196
vector196:
  pushl $0
c010301e:	6a 00                	push   $0x0
  pushl $196
c0103020:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0103025:	e9 30 f8 ff ff       	jmp    c010285a <__alltraps>

c010302a <vector197>:
.globl vector197
vector197:
  pushl $0
c010302a:	6a 00                	push   $0x0
  pushl $197
c010302c:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0103031:	e9 24 f8 ff ff       	jmp    c010285a <__alltraps>

c0103036 <vector198>:
.globl vector198
vector198:
  pushl $0
c0103036:	6a 00                	push   $0x0
  pushl $198
c0103038:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c010303d:	e9 18 f8 ff ff       	jmp    c010285a <__alltraps>

c0103042 <vector199>:
.globl vector199
vector199:
  pushl $0
c0103042:	6a 00                	push   $0x0
  pushl $199
c0103044:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0103049:	e9 0c f8 ff ff       	jmp    c010285a <__alltraps>

c010304e <vector200>:
.globl vector200
vector200:
  pushl $0
c010304e:	6a 00                	push   $0x0
  pushl $200
c0103050:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0103055:	e9 00 f8 ff ff       	jmp    c010285a <__alltraps>

c010305a <vector201>:
.globl vector201
vector201:
  pushl $0
c010305a:	6a 00                	push   $0x0
  pushl $201
c010305c:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0103061:	e9 f4 f7 ff ff       	jmp    c010285a <__alltraps>

c0103066 <vector202>:
.globl vector202
vector202:
  pushl $0
c0103066:	6a 00                	push   $0x0
  pushl $202
c0103068:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c010306d:	e9 e8 f7 ff ff       	jmp    c010285a <__alltraps>

c0103072 <vector203>:
.globl vector203
vector203:
  pushl $0
c0103072:	6a 00                	push   $0x0
  pushl $203
c0103074:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0103079:	e9 dc f7 ff ff       	jmp    c010285a <__alltraps>

c010307e <vector204>:
.globl vector204
vector204:
  pushl $0
c010307e:	6a 00                	push   $0x0
  pushl $204
c0103080:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0103085:	e9 d0 f7 ff ff       	jmp    c010285a <__alltraps>

c010308a <vector205>:
.globl vector205
vector205:
  pushl $0
c010308a:	6a 00                	push   $0x0
  pushl $205
c010308c:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0103091:	e9 c4 f7 ff ff       	jmp    c010285a <__alltraps>

c0103096 <vector206>:
.globl vector206
vector206:
  pushl $0
c0103096:	6a 00                	push   $0x0
  pushl $206
c0103098:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c010309d:	e9 b8 f7 ff ff       	jmp    c010285a <__alltraps>

c01030a2 <vector207>:
.globl vector207
vector207:
  pushl $0
c01030a2:	6a 00                	push   $0x0
  pushl $207
c01030a4:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01030a9:	e9 ac f7 ff ff       	jmp    c010285a <__alltraps>

c01030ae <vector208>:
.globl vector208
vector208:
  pushl $0
c01030ae:	6a 00                	push   $0x0
  pushl $208
c01030b0:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c01030b5:	e9 a0 f7 ff ff       	jmp    c010285a <__alltraps>

c01030ba <vector209>:
.globl vector209
vector209:
  pushl $0
c01030ba:	6a 00                	push   $0x0
  pushl $209
c01030bc:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01030c1:	e9 94 f7 ff ff       	jmp    c010285a <__alltraps>

c01030c6 <vector210>:
.globl vector210
vector210:
  pushl $0
c01030c6:	6a 00                	push   $0x0
  pushl $210
c01030c8:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c01030cd:	e9 88 f7 ff ff       	jmp    c010285a <__alltraps>

c01030d2 <vector211>:
.globl vector211
vector211:
  pushl $0
c01030d2:	6a 00                	push   $0x0
  pushl $211
c01030d4:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c01030d9:	e9 7c f7 ff ff       	jmp    c010285a <__alltraps>

c01030de <vector212>:
.globl vector212
vector212:
  pushl $0
c01030de:	6a 00                	push   $0x0
  pushl $212
c01030e0:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c01030e5:	e9 70 f7 ff ff       	jmp    c010285a <__alltraps>

c01030ea <vector213>:
.globl vector213
vector213:
  pushl $0
c01030ea:	6a 00                	push   $0x0
  pushl $213
c01030ec:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c01030f1:	e9 64 f7 ff ff       	jmp    c010285a <__alltraps>

c01030f6 <vector214>:
.globl vector214
vector214:
  pushl $0
c01030f6:	6a 00                	push   $0x0
  pushl $214
c01030f8:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c01030fd:	e9 58 f7 ff ff       	jmp    c010285a <__alltraps>

c0103102 <vector215>:
.globl vector215
vector215:
  pushl $0
c0103102:	6a 00                	push   $0x0
  pushl $215
c0103104:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0103109:	e9 4c f7 ff ff       	jmp    c010285a <__alltraps>

c010310e <vector216>:
.globl vector216
vector216:
  pushl $0
c010310e:	6a 00                	push   $0x0
  pushl $216
c0103110:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0103115:	e9 40 f7 ff ff       	jmp    c010285a <__alltraps>

c010311a <vector217>:
.globl vector217
vector217:
  pushl $0
c010311a:	6a 00                	push   $0x0
  pushl $217
c010311c:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0103121:	e9 34 f7 ff ff       	jmp    c010285a <__alltraps>

c0103126 <vector218>:
.globl vector218
vector218:
  pushl $0
c0103126:	6a 00                	push   $0x0
  pushl $218
c0103128:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c010312d:	e9 28 f7 ff ff       	jmp    c010285a <__alltraps>

c0103132 <vector219>:
.globl vector219
vector219:
  pushl $0
c0103132:	6a 00                	push   $0x0
  pushl $219
c0103134:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0103139:	e9 1c f7 ff ff       	jmp    c010285a <__alltraps>

c010313e <vector220>:
.globl vector220
vector220:
  pushl $0
c010313e:	6a 00                	push   $0x0
  pushl $220
c0103140:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0103145:	e9 10 f7 ff ff       	jmp    c010285a <__alltraps>

c010314a <vector221>:
.globl vector221
vector221:
  pushl $0
c010314a:	6a 00                	push   $0x0
  pushl $221
c010314c:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0103151:	e9 04 f7 ff ff       	jmp    c010285a <__alltraps>

c0103156 <vector222>:
.globl vector222
vector222:
  pushl $0
c0103156:	6a 00                	push   $0x0
  pushl $222
c0103158:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c010315d:	e9 f8 f6 ff ff       	jmp    c010285a <__alltraps>

c0103162 <vector223>:
.globl vector223
vector223:
  pushl $0
c0103162:	6a 00                	push   $0x0
  pushl $223
c0103164:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0103169:	e9 ec f6 ff ff       	jmp    c010285a <__alltraps>

c010316e <vector224>:
.globl vector224
vector224:
  pushl $0
c010316e:	6a 00                	push   $0x0
  pushl $224
c0103170:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0103175:	e9 e0 f6 ff ff       	jmp    c010285a <__alltraps>

c010317a <vector225>:
.globl vector225
vector225:
  pushl $0
c010317a:	6a 00                	push   $0x0
  pushl $225
c010317c:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0103181:	e9 d4 f6 ff ff       	jmp    c010285a <__alltraps>

c0103186 <vector226>:
.globl vector226
vector226:
  pushl $0
c0103186:	6a 00                	push   $0x0
  pushl $226
c0103188:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c010318d:	e9 c8 f6 ff ff       	jmp    c010285a <__alltraps>

c0103192 <vector227>:
.globl vector227
vector227:
  pushl $0
c0103192:	6a 00                	push   $0x0
  pushl $227
c0103194:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0103199:	e9 bc f6 ff ff       	jmp    c010285a <__alltraps>

c010319e <vector228>:
.globl vector228
vector228:
  pushl $0
c010319e:	6a 00                	push   $0x0
  pushl $228
c01031a0:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c01031a5:	e9 b0 f6 ff ff       	jmp    c010285a <__alltraps>

c01031aa <vector229>:
.globl vector229
vector229:
  pushl $0
c01031aa:	6a 00                	push   $0x0
  pushl $229
c01031ac:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01031b1:	e9 a4 f6 ff ff       	jmp    c010285a <__alltraps>

c01031b6 <vector230>:
.globl vector230
vector230:
  pushl $0
c01031b6:	6a 00                	push   $0x0
  pushl $230
c01031b8:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01031bd:	e9 98 f6 ff ff       	jmp    c010285a <__alltraps>

c01031c2 <vector231>:
.globl vector231
vector231:
  pushl $0
c01031c2:	6a 00                	push   $0x0
  pushl $231
c01031c4:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01031c9:	e9 8c f6 ff ff       	jmp    c010285a <__alltraps>

c01031ce <vector232>:
.globl vector232
vector232:
  pushl $0
c01031ce:	6a 00                	push   $0x0
  pushl $232
c01031d0:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c01031d5:	e9 80 f6 ff ff       	jmp    c010285a <__alltraps>

c01031da <vector233>:
.globl vector233
vector233:
  pushl $0
c01031da:	6a 00                	push   $0x0
  pushl $233
c01031dc:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c01031e1:	e9 74 f6 ff ff       	jmp    c010285a <__alltraps>

c01031e6 <vector234>:
.globl vector234
vector234:
  pushl $0
c01031e6:	6a 00                	push   $0x0
  pushl $234
c01031e8:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c01031ed:	e9 68 f6 ff ff       	jmp    c010285a <__alltraps>

c01031f2 <vector235>:
.globl vector235
vector235:
  pushl $0
c01031f2:	6a 00                	push   $0x0
  pushl $235
c01031f4:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c01031f9:	e9 5c f6 ff ff       	jmp    c010285a <__alltraps>

c01031fe <vector236>:
.globl vector236
vector236:
  pushl $0
c01031fe:	6a 00                	push   $0x0
  pushl $236
c0103200:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0103205:	e9 50 f6 ff ff       	jmp    c010285a <__alltraps>

c010320a <vector237>:
.globl vector237
vector237:
  pushl $0
c010320a:	6a 00                	push   $0x0
  pushl $237
c010320c:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0103211:	e9 44 f6 ff ff       	jmp    c010285a <__alltraps>

c0103216 <vector238>:
.globl vector238
vector238:
  pushl $0
c0103216:	6a 00                	push   $0x0
  pushl $238
c0103218:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c010321d:	e9 38 f6 ff ff       	jmp    c010285a <__alltraps>

c0103222 <vector239>:
.globl vector239
vector239:
  pushl $0
c0103222:	6a 00                	push   $0x0
  pushl $239
c0103224:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0103229:	e9 2c f6 ff ff       	jmp    c010285a <__alltraps>

c010322e <vector240>:
.globl vector240
vector240:
  pushl $0
c010322e:	6a 00                	push   $0x0
  pushl $240
c0103230:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0103235:	e9 20 f6 ff ff       	jmp    c010285a <__alltraps>

c010323a <vector241>:
.globl vector241
vector241:
  pushl $0
c010323a:	6a 00                	push   $0x0
  pushl $241
c010323c:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0103241:	e9 14 f6 ff ff       	jmp    c010285a <__alltraps>

c0103246 <vector242>:
.globl vector242
vector242:
  pushl $0
c0103246:	6a 00                	push   $0x0
  pushl $242
c0103248:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c010324d:	e9 08 f6 ff ff       	jmp    c010285a <__alltraps>

c0103252 <vector243>:
.globl vector243
vector243:
  pushl $0
c0103252:	6a 00                	push   $0x0
  pushl $243
c0103254:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0103259:	e9 fc f5 ff ff       	jmp    c010285a <__alltraps>

c010325e <vector244>:
.globl vector244
vector244:
  pushl $0
c010325e:	6a 00                	push   $0x0
  pushl $244
c0103260:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0103265:	e9 f0 f5 ff ff       	jmp    c010285a <__alltraps>

c010326a <vector245>:
.globl vector245
vector245:
  pushl $0
c010326a:	6a 00                	push   $0x0
  pushl $245
c010326c:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0103271:	e9 e4 f5 ff ff       	jmp    c010285a <__alltraps>

c0103276 <vector246>:
.globl vector246
vector246:
  pushl $0
c0103276:	6a 00                	push   $0x0
  pushl $246
c0103278:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c010327d:	e9 d8 f5 ff ff       	jmp    c010285a <__alltraps>

c0103282 <vector247>:
.globl vector247
vector247:
  pushl $0
c0103282:	6a 00                	push   $0x0
  pushl $247
c0103284:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0103289:	e9 cc f5 ff ff       	jmp    c010285a <__alltraps>

c010328e <vector248>:
.globl vector248
vector248:
  pushl $0
c010328e:	6a 00                	push   $0x0
  pushl $248
c0103290:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0103295:	e9 c0 f5 ff ff       	jmp    c010285a <__alltraps>

c010329a <vector249>:
.globl vector249
vector249:
  pushl $0
c010329a:	6a 00                	push   $0x0
  pushl $249
c010329c:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c01032a1:	e9 b4 f5 ff ff       	jmp    c010285a <__alltraps>

c01032a6 <vector250>:
.globl vector250
vector250:
  pushl $0
c01032a6:	6a 00                	push   $0x0
  pushl $250
c01032a8:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01032ad:	e9 a8 f5 ff ff       	jmp    c010285a <__alltraps>

c01032b2 <vector251>:
.globl vector251
vector251:
  pushl $0
c01032b2:	6a 00                	push   $0x0
  pushl $251
c01032b4:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01032b9:	e9 9c f5 ff ff       	jmp    c010285a <__alltraps>

c01032be <vector252>:
.globl vector252
vector252:
  pushl $0
c01032be:	6a 00                	push   $0x0
  pushl $252
c01032c0:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01032c5:	e9 90 f5 ff ff       	jmp    c010285a <__alltraps>

c01032ca <vector253>:
.globl vector253
vector253:
  pushl $0
c01032ca:	6a 00                	push   $0x0
  pushl $253
c01032cc:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c01032d1:	e9 84 f5 ff ff       	jmp    c010285a <__alltraps>

c01032d6 <vector254>:
.globl vector254
vector254:
  pushl $0
c01032d6:	6a 00                	push   $0x0
  pushl $254
c01032d8:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c01032dd:	e9 78 f5 ff ff       	jmp    c010285a <__alltraps>

c01032e2 <vector255>:
.globl vector255
vector255:
  pushl $0
c01032e2:	6a 00                	push   $0x0
  pushl $255
c01032e4:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c01032e9:	e9 6c f5 ff ff       	jmp    c010285a <__alltraps>

c01032ee <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01032ee:	55                   	push   %ebp
c01032ef:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01032f1:	8b 15 a0 6f 12 c0    	mov    0xc0126fa0,%edx
c01032f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01032fa:	29 d0                	sub    %edx,%eax
c01032fc:	c1 f8 05             	sar    $0x5,%eax
}
c01032ff:	5d                   	pop    %ebp
c0103300:	c3                   	ret    

c0103301 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0103301:	55                   	push   %ebp
c0103302:	89 e5                	mov    %esp,%ebp
c0103304:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0103307:	8b 45 08             	mov    0x8(%ebp),%eax
c010330a:	89 04 24             	mov    %eax,(%esp)
c010330d:	e8 dc ff ff ff       	call   c01032ee <page2ppn>
c0103312:	c1 e0 0c             	shl    $0xc,%eax
}
c0103315:	89 ec                	mov    %ebp,%esp
c0103317:	5d                   	pop    %ebp
c0103318:	c3                   	ret    

c0103319 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0103319:	55                   	push   %ebp
c010331a:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010331c:	8b 45 08             	mov    0x8(%ebp),%eax
c010331f:	8b 00                	mov    (%eax),%eax
}
c0103321:	5d                   	pop    %ebp
c0103322:	c3                   	ret    

c0103323 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0103323:	55                   	push   %ebp
c0103324:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0103326:	8b 45 08             	mov    0x8(%ebp),%eax
c0103329:	8b 55 0c             	mov    0xc(%ebp),%edx
c010332c:	89 10                	mov    %edx,(%eax)
}
c010332e:	90                   	nop
c010332f:	5d                   	pop    %ebp
c0103330:	c3                   	ret    

c0103331 <default_init>:
//free_list本身不会对应Page结构
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0103331:	55                   	push   %ebp
c0103332:	89 e5                	mov    %esp,%ebp
c0103334:	83 ec 10             	sub    $0x10,%esp
c0103337:	c7 45 fc 84 6f 12 c0 	movl   $0xc0126f84,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010333e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103341:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0103344:	89 50 04             	mov    %edx,0x4(%eax)
c0103347:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010334a:	8b 50 04             	mov    0x4(%eax),%edx
c010334d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103350:	89 10                	mov    %edx,(%eax)
}
c0103352:	90                   	nop
    list_init(&free_list);
    nr_free = 0;
c0103353:	c7 05 8c 6f 12 c0 00 	movl   $0x0,0xc0126f8c
c010335a:	00 00 00 
}
c010335d:	90                   	nop
c010335e:	89 ec                	mov    %ebp,%esp
c0103360:	5d                   	pop    %ebp
c0103361:	c3                   	ret    

c0103362 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0103362:	55                   	push   %ebp
c0103363:	89 e5                	mov    %esp,%ebp
c0103365:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
c0103368:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010336c:	75 24                	jne    c0103392 <default_init_memmap+0x30>
c010336e:	c7 44 24 0c 70 9a 10 	movl   $0xc0109a70,0xc(%esp)
c0103375:	c0 
c0103376:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c010337d:	c0 
c010337e:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
c0103385:	00 
c0103386:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c010338d:	e8 7c d9 ff ff       	call   c0100d0e <__panic>
    struct Page *p = base;
c0103392:	8b 45 08             	mov    0x8(%ebp),%eax
c0103395:	89 45 f4             	mov    %eax,-0xc(%ebp)
    //相邻的page结构在内存上也是相邻的
    for (; p != base + n; p ++) {
c0103398:	e9 97 00 00 00       	jmp    c0103434 <default_init_memmap+0xd2>
        //检查是否被保留,是否有问题，
        assert(PageReserved(p));
c010339d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033a0:	83 c0 04             	add    $0x4,%eax
c01033a3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01033aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01033ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01033b0:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01033b3:	0f a3 10             	bt     %edx,(%eax)
c01033b6:	19 c0                	sbb    %eax,%eax
c01033b8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c01033bb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01033bf:	0f 95 c0             	setne  %al
c01033c2:	0f b6 c0             	movzbl %al,%eax
c01033c5:	85 c0                	test   %eax,%eax
c01033c7:	75 24                	jne    c01033ed <default_init_memmap+0x8b>
c01033c9:	c7 44 24 0c a1 9a 10 	movl   $0xc0109aa1,0xc(%esp)
c01033d0:	c0 
c01033d1:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c01033d8:	c0 
c01033d9:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
c01033e0:	00 
c01033e1:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c01033e8:	e8 21 d9 ff ff       	call   c0100d0e <__panic>
        p->flags = p->property = 0;
c01033ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033f0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c01033f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033fa:	8b 50 08             	mov    0x8(%eax),%edx
c01033fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103400:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c0103403:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010340a:	00 
c010340b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010340e:	89 04 24             	mov    %eax,(%esp)
c0103411:	e8 0d ff ff ff       	call   c0103323 <set_page_ref>
        //my_add
        SetPageProperty(p);
c0103416:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103419:	83 c0 04             	add    $0x4,%eax
c010341c:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c0103423:	89 45 e0             	mov    %eax,-0x20(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103426:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103429:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010342c:	0f ab 10             	bts    %edx,(%eax)
}
c010342f:	90                   	nop
    for (; p != base + n; p ++) {
c0103430:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0103434:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103437:	c1 e0 05             	shl    $0x5,%eax
c010343a:	89 c2                	mov    %eax,%edx
c010343c:	8b 45 08             	mov    0x8(%ebp),%eax
c010343f:	01 d0                	add    %edx,%eax
c0103441:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103444:	0f 85 53 ff ff ff    	jne    c010339d <default_init_memmap+0x3b>

    }
    base->property = n;
c010344a:	8b 45 08             	mov    0x8(%ebp),%eax
c010344d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103450:	89 50 08             	mov    %edx,0x8(%eax)
    //置位标志位代表可以分配
   //SetPageProperty(base);
    nr_free += n;
c0103453:	8b 15 8c 6f 12 c0    	mov    0xc0126f8c,%edx
c0103459:	8b 45 0c             	mov    0xc(%ebp),%eax
c010345c:	01 d0                	add    %edx,%eax
c010345e:	a3 8c 6f 12 c0       	mov    %eax,0xc0126f8c
    list_add(&free_list, &(base->page_link));
c0103463:	8b 45 08             	mov    0x8(%ebp),%eax
c0103466:	83 c0 0c             	add    $0xc,%eax
c0103469:	c7 45 dc 84 6f 12 c0 	movl   $0xc0126f84,-0x24(%ebp)
c0103470:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0103473:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103476:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0103479:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010347c:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c010347f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103482:	8b 40 04             	mov    0x4(%eax),%eax
c0103485:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103488:	89 55 cc             	mov    %edx,-0x34(%ebp)
c010348b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010348e:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0103491:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0103494:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103497:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010349a:	89 10                	mov    %edx,(%eax)
c010349c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010349f:	8b 10                	mov    (%eax),%edx
c01034a1:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01034a4:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01034a7:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01034aa:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01034ad:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01034b0:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01034b3:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01034b6:	89 10                	mov    %edx,(%eax)
}
c01034b8:	90                   	nop
}
c01034b9:	90                   	nop
}
c01034ba:	90                   	nop
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;
    list_add(&free_list, &(base->page_link));*/
}
c01034bb:	90                   	nop
c01034bc:	89 ec                	mov    %ebp,%esp
c01034be:	5d                   	pop    %ebp
c01034bf:	c3                   	ret    

c01034c0 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c01034c0:	55                   	push   %ebp
c01034c1:	89 e5                	mov    %esp,%ebp
c01034c3:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c01034c6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01034ca:	75 24                	jne    c01034f0 <default_alloc_pages+0x30>
c01034cc:	c7 44 24 0c 70 9a 10 	movl   $0xc0109a70,0xc(%esp)
c01034d3:	c0 
c01034d4:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c01034db:	c0 
c01034dc:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
c01034e3:	00 
c01034e4:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c01034eb:	e8 1e d8 ff ff       	call   c0100d0e <__panic>
    if (n > nr_free) {
c01034f0:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
c01034f5:	39 45 08             	cmp    %eax,0x8(%ebp)
c01034f8:	76 0a                	jbe    c0103504 <default_alloc_pages+0x44>
        return NULL;
c01034fa:	b8 00 00 00 00       	mov    $0x0,%eax
c01034ff:	e9 74 01 00 00       	jmp    c0103678 <default_alloc_pages+0x1b8>
    }
    struct Page *page = NULL;
c0103504:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c010350b:	c7 45 f0 84 6f 12 c0 	movl   $0xc0126f84,-0x10(%ebp)

    //遍历free_list
    while ((le = list_next(le)) != &free_list) {
c0103512:	eb 1c                	jmp    c0103530 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c0103514:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103517:	83 e8 0c             	sub    $0xc,%eax
c010351a:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (p->property >= n) {
c010351d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103520:	8b 40 08             	mov    0x8(%eax),%eax
c0103523:	39 45 08             	cmp    %eax,0x8(%ebp)
c0103526:	77 08                	ja     c0103530 <default_alloc_pages+0x70>
            page = p;
c0103528:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010352b:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c010352e:	eb 18                	jmp    c0103548 <default_alloc_pages+0x88>
c0103530:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103533:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c0103536:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103539:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c010353c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010353f:	81 7d f0 84 6f 12 c0 	cmpl   $0xc0126f84,-0x10(%ebp)
c0103546:	75 cc                	jne    c0103514 <default_alloc_pages+0x54>
        }
    }
    if (page != NULL) {
c0103548:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010354c:	0f 84 23 01 00 00    	je     c0103675 <default_alloc_pages+0x1b5>
        struct Page *temp=page;
c0103552:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103555:	89 45 ec             	mov    %eax,-0x14(%ebp)
        for(;temp!=page+n;temp++)
c0103558:	eb 1e                	jmp    c0103578 <default_alloc_pages+0xb8>
            ClearPageProperty(temp);
c010355a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010355d:	83 c0 04             	add    $0x4,%eax
c0103560:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
c0103567:	89 45 d8             	mov    %eax,-0x28(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010356a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010356d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103570:	0f b3 10             	btr    %edx,(%eax)
}
c0103573:	90                   	nop
        for(;temp!=page+n;temp++)
c0103574:	83 45 ec 20          	addl   $0x20,-0x14(%ebp)
c0103578:	8b 45 08             	mov    0x8(%ebp),%eax
c010357b:	c1 e0 05             	shl    $0x5,%eax
c010357e:	89 c2                	mov    %eax,%edx
c0103580:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103583:	01 d0                	add    %edx,%eax
c0103585:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0103588:	75 d0                	jne    c010355a <default_alloc_pages+0x9a>
        if (page->property > n) {
c010358a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010358d:	8b 40 08             	mov    0x8(%eax),%eax
c0103590:	39 45 08             	cmp    %eax,0x8(%ebp)
c0103593:	0f 83 88 00 00 00    	jae    c0103621 <default_alloc_pages+0x161>
            struct Page *p = page + n;
c0103599:	8b 45 08             	mov    0x8(%ebp),%eax
c010359c:	c1 e0 05             	shl    $0x5,%eax
c010359f:	89 c2                	mov    %eax,%edx
c01035a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035a4:	01 d0                	add    %edx,%eax
c01035a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            p->property = page->property - n;
c01035a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035ac:	8b 40 08             	mov    0x8(%eax),%eax
c01035af:	2b 45 08             	sub    0x8(%ebp),%eax
c01035b2:	89 c2                	mov    %eax,%edx
c01035b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01035b7:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
c01035ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01035bd:	83 c0 04             	add    $0x4,%eax
c01035c0:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c01035c7:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01035ca:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01035cd:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01035d0:	0f ab 10             	bts    %edx,(%eax)
}
c01035d3:	90                   	nop
            list_add_after(&(page->page_link), &(p->page_link));
c01035d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01035d7:	83 c0 0c             	add    $0xc,%eax
c01035da:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01035dd:	83 c2 0c             	add    $0xc,%edx
c01035e0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01035e3:	89 45 d0             	mov    %eax,-0x30(%ebp)
    __list_add(elm, listelm, listelm->next);
c01035e6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01035e9:	8b 40 04             	mov    0x4(%eax),%eax
c01035ec:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01035ef:	89 55 cc             	mov    %edx,-0x34(%ebp)
c01035f2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01035f5:	89 55 c8             	mov    %edx,-0x38(%ebp)
c01035f8:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    prev->next = next->prev = elm;
c01035fb:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01035fe:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103601:	89 10                	mov    %edx,(%eax)
c0103603:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103606:	8b 10                	mov    (%eax),%edx
c0103608:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010360b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010360e:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103611:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0103614:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103617:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010361a:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010361d:	89 10                	mov    %edx,(%eax)
}
c010361f:	90                   	nop
}
c0103620:	90                   	nop
        }
        list_del(&(page->page_link));
c0103621:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103624:	83 c0 0c             	add    $0xc,%eax
c0103627:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
c010362a:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010362d:	8b 40 04             	mov    0x4(%eax),%eax
c0103630:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0103633:	8b 12                	mov    (%edx),%edx
c0103635:	89 55 ac             	mov    %edx,-0x54(%ebp)
c0103638:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c010363b:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010363e:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0103641:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103644:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103647:	8b 55 ac             	mov    -0x54(%ebp),%edx
c010364a:	89 10                	mov    %edx,(%eax)
}
c010364c:	90                   	nop
}
c010364d:	90                   	nop
        nr_free -= n;
c010364e:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
c0103653:	2b 45 08             	sub    0x8(%ebp),%eax
c0103656:	a3 8c 6f 12 c0       	mov    %eax,0xc0126f8c
        ClearPageProperty(page);
c010365b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010365e:	83 c0 04             	add    $0x4,%eax
c0103661:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c0103668:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010366b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010366e:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0103671:	0f b3 10             	btr    %edx,(%eax)
}
c0103674:	90                   	nop
    }
    return page;
c0103675:	8b 45 f4             	mov    -0xc(%ebp),%eax
        list_del(&(page->page_link));
        nr_free -= n;
        ClearPageProperty(page);
    }
    return page;*/
}
c0103678:	89 ec                	mov    %ebp,%esp
c010367a:	5d                   	pop    %ebp
c010367b:	c3                   	ret    

c010367c <merge_backward>:

static bool merge_backward(struct  Page*base)
{
c010367c:	55                   	push   %ebp
c010367d:	89 e5                	mov    %esp,%ebp
c010367f:	83 ec 30             	sub    $0x30,%esp
    list_entry_t *le=list_next(&(base->page_link));
c0103682:	8b 45 08             	mov    0x8(%ebp),%eax
c0103685:	83 c0 0c             	add    $0xc,%eax
c0103688:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return listelm->next;
c010368b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010368e:	8b 40 04             	mov    0x4(%eax),%eax
c0103691:	89 45 fc             	mov    %eax,-0x4(%ebp)
    //判断是否为头节点
    if (le==&free_list)
c0103694:	81 7d fc 84 6f 12 c0 	cmpl   $0xc0126f84,-0x4(%ebp)
c010369b:	75 0a                	jne    c01036a7 <merge_backward+0x2b>
    return 0;
c010369d:	b8 00 00 00 00       	mov    $0x0,%eax
c01036a2:	e9 a5 00 00 00       	jmp    c010374c <merge_backward+0xd0>
    struct Page*p=le2page(le,page_link);
c01036a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01036aa:	83 e8 0c             	sub    $0xc,%eax
c01036ad:	89 45 f8             	mov    %eax,-0x8(%ebp)
    
    //判断是否为空闲块
    if(PageProperty(p)==0) return 0;
c01036b0:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01036b3:	83 c0 04             	add    $0x4,%eax
c01036b6:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c01036bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01036c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01036c3:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01036c6:	0f a3 10             	bt     %edx,(%eax)
c01036c9:	19 c0                	sbb    %eax,%eax
c01036cb:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c01036ce:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01036d2:	0f 95 c0             	setne  %al
c01036d5:	0f b6 c0             	movzbl %al,%eax
c01036d8:	85 c0                	test   %eax,%eax
c01036da:	75 07                	jne    c01036e3 <merge_backward+0x67>
c01036dc:	b8 00 00 00 00       	mov    $0x0,%eax
c01036e1:	eb 69                	jmp    c010374c <merge_backward+0xd0>
    //判断地址是否连续
    if(base+base->property==p)
c01036e3:	8b 45 08             	mov    0x8(%ebp),%eax
c01036e6:	8b 40 08             	mov    0x8(%eax),%eax
c01036e9:	c1 e0 05             	shl    $0x5,%eax
c01036ec:	89 c2                	mov    %eax,%edx
c01036ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01036f1:	01 d0                	add    %edx,%eax
c01036f3:	39 45 f8             	cmp    %eax,-0x8(%ebp)
c01036f6:	75 4f                	jne    c0103747 <merge_backward+0xcb>
    {
        base->property+=p->property;
c01036f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01036fb:	8b 50 08             	mov    0x8(%eax),%edx
c01036fe:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0103701:	8b 40 08             	mov    0x8(%eax),%eax
c0103704:	01 c2                	add    %eax,%edx
c0103706:	8b 45 08             	mov    0x8(%ebp),%eax
c0103709:	89 50 08             	mov    %edx,0x8(%eax)
        p->property=0;
c010370c:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010370f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0103716:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103719:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    __list_del(listelm->prev, listelm->next);
c010371c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010371f:	8b 40 04             	mov    0x4(%eax),%eax
c0103722:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103725:	8b 12                	mov    (%edx),%edx
c0103727:	89 55 e0             	mov    %edx,-0x20(%ebp)
c010372a:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next;
c010372d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103730:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103733:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103736:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103739:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010373c:	89 10                	mov    %edx,(%eax)
}
c010373e:	90                   	nop
}
c010373f:	90                   	nop
        list_del(le);
        return 1;
c0103740:	b8 01 00 00 00       	mov    $0x1,%eax
c0103745:	eb 05                	jmp    c010374c <merge_backward+0xd0>
        
    }
    else
    {
        return 0;
c0103747:	b8 00 00 00 00       	mov    $0x0,%eax
    }

}
c010374c:	89 ec                	mov    %ebp,%esp
c010374e:	5d                   	pop    %ebp
c010374f:	c3                   	ret    

c0103750 <merge_beforeward>:
static bool merge_beforeward(struct Page*base)
{
c0103750:	55                   	push   %ebp
c0103751:	89 e5                	mov    %esp,%ebp
c0103753:	83 ec 30             	sub    $0x30,%esp
    list_entry_t *le=list_prev(&(base->page_link));
c0103756:	8b 45 08             	mov    0x8(%ebp),%eax
c0103759:	83 c0 0c             	add    $0xc,%eax
c010375c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return listelm->prev;
c010375f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103762:	8b 00                	mov    (%eax),%eax
c0103764:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (le==&free_list)
c0103767:	81 7d fc 84 6f 12 c0 	cmpl   $0xc0126f84,-0x4(%ebp)
c010376e:	75 0a                	jne    c010377a <merge_beforeward+0x2a>
    return 0;
c0103770:	b8 00 00 00 00       	mov    $0x0,%eax
c0103775:	e9 ae 00 00 00       	jmp    c0103828 <merge_beforeward+0xd8>
    struct Page*p=le2page(le,page_link);
c010377a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010377d:	83 e8 0c             	sub    $0xc,%eax
c0103780:	89 45 f8             	mov    %eax,-0x8(%ebp)

    //判断是否为空闲块
    if(PageProperty(p)==0) return 0;
c0103783:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0103786:	83 c0 04             	add    $0x4,%eax
c0103789:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0103790:	89 45 ec             	mov    %eax,-0x14(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103793:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103796:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103799:	0f a3 10             	bt     %edx,(%eax)
c010379c:	19 c0                	sbb    %eax,%eax
c010379e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c01037a1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01037a5:	0f 95 c0             	setne  %al
c01037a8:	0f b6 c0             	movzbl %al,%eax
c01037ab:	85 c0                	test   %eax,%eax
c01037ad:	75 07                	jne    c01037b6 <merge_beforeward+0x66>
c01037af:	b8 00 00 00 00       	mov    $0x0,%eax
c01037b4:	eb 72                	jmp    c0103828 <merge_beforeward+0xd8>
    //判断地址是否连续
    if(p+p->property==base)
c01037b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01037b9:	8b 40 08             	mov    0x8(%eax),%eax
c01037bc:	c1 e0 05             	shl    $0x5,%eax
c01037bf:	89 c2                	mov    %eax,%edx
c01037c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01037c4:	01 d0                	add    %edx,%eax
c01037c6:	39 45 08             	cmp    %eax,0x8(%ebp)
c01037c9:	75 58                	jne    c0103823 <merge_beforeward+0xd3>
    {
        p->property+=base->property;
c01037cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01037ce:	8b 50 08             	mov    0x8(%eax),%edx
c01037d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01037d4:	8b 40 08             	mov    0x8(%eax),%eax
c01037d7:	01 c2                	add    %eax,%edx
c01037d9:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01037dc:	89 50 08             	mov    %edx,0x8(%eax)
        base->property=0;
c01037df:	8b 45 08             	mov    0x8(%ebp),%eax
c01037e2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        list_del(&(base->page_link));
c01037e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01037ec:	83 c0 0c             	add    $0xc,%eax
c01037ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    __list_del(listelm->prev, listelm->next);
c01037f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01037f5:	8b 40 04             	mov    0x4(%eax),%eax
c01037f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01037fb:	8b 12                	mov    (%edx),%edx
c01037fd:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0103800:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next;
c0103803:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103806:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103809:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010380c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010380f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103812:	89 10                	mov    %edx,(%eax)
}
c0103814:	90                   	nop
}
c0103815:	90                   	nop
        base=p;
c0103816:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0103819:	89 45 08             	mov    %eax,0x8(%ebp)
        return 1;   
c010381c:	b8 01 00 00 00       	mov    $0x1,%eax
c0103821:	eb 05                	jmp    c0103828 <merge_beforeward+0xd8>
    }
    else
    {
        return 0;
c0103823:	b8 00 00 00 00       	mov    $0x0,%eax
    }
    

}
c0103828:	89 ec                	mov    %ebp,%esp
c010382a:	5d                   	pop    %ebp
c010382b:	c3                   	ret    

c010382c <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c010382c:	55                   	push   %ebp
c010382d:	89 e5                	mov    %esp,%ebp
c010382f:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0103832:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0103836:	75 24                	jne    c010385c <default_free_pages+0x30>
c0103838:	c7 44 24 0c 70 9a 10 	movl   $0xc0109a70,0xc(%esp)
c010383f:	c0 
c0103840:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c0103847:	c0 
c0103848:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c010384f:	00 
c0103850:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c0103857:	e8 b2 d4 ff ff       	call   c0100d0e <__panic>
    struct Page *p = base;
c010385c:	8b 45 08             	mov    0x8(%ebp),%eax
c010385f:	89 45 f4             	mov    %eax,-0xc(%ebp)

    for (; p != base + n; p ++) {
c0103862:	e9 ad 00 00 00       	jmp    c0103914 <default_free_pages+0xe8>
        
        //需要满足不是给内核的且不是空闲的
        assert(!PageReserved(p) && !PageProperty(p));
c0103867:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010386a:	83 c0 04             	add    $0x4,%eax
c010386d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0103874:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103877:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010387a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010387d:	0f a3 10             	bt     %edx,(%eax)
c0103880:	19 c0                	sbb    %eax,%eax
c0103882:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0103885:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103889:	0f 95 c0             	setne  %al
c010388c:	0f b6 c0             	movzbl %al,%eax
c010388f:	85 c0                	test   %eax,%eax
c0103891:	75 2c                	jne    c01038bf <default_free_pages+0x93>
c0103893:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103896:	83 c0 04             	add    $0x4,%eax
c0103899:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01038a0:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01038a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01038a6:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01038a9:	0f a3 10             	bt     %edx,(%eax)
c01038ac:	19 c0                	sbb    %eax,%eax
c01038ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c01038b1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01038b5:	0f 95 c0             	setne  %al
c01038b8:	0f b6 c0             	movzbl %al,%eax
c01038bb:	85 c0                	test   %eax,%eax
c01038bd:	74 24                	je     c01038e3 <default_free_pages+0xb7>
c01038bf:	c7 44 24 0c b4 9a 10 	movl   $0xc0109ab4,0xc(%esp)
c01038c6:	c0 
c01038c7:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c01038ce:	c0 
c01038cf:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
c01038d6:	00 
c01038d7:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c01038de:	e8 2b d4 ff ff       	call   c0100d0e <__panic>
        //p->flags = 0;
        SetPageProperty(p);
c01038e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038e6:	83 c0 04             	add    $0x4,%eax
c01038e9:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c01038f0:	89 45 d0             	mov    %eax,-0x30(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01038f3:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01038f6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01038f9:	0f ab 10             	bts    %edx,(%eax)
}
c01038fc:	90                   	nop
        set_page_ref(p, 0);
c01038fd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103904:	00 
c0103905:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103908:	89 04 24             	mov    %eax,(%esp)
c010390b:	e8 13 fa ff ff       	call   c0103323 <set_page_ref>
    for (; p != base + n; p ++) {
c0103910:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0103914:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103917:	c1 e0 05             	shl    $0x5,%eax
c010391a:	89 c2                	mov    %eax,%edx
c010391c:	8b 45 08             	mov    0x8(%ebp),%eax
c010391f:	01 d0                	add    %edx,%eax
c0103921:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103924:	0f 85 3d ff ff ff    	jne    c0103867 <default_free_pages+0x3b>
    }

    base->property = n;
c010392a:	8b 45 08             	mov    0x8(%ebp),%eax
c010392d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103930:	89 50 08             	mov    %edx,0x8(%eax)
c0103933:	c7 45 cc 84 6f 12 c0 	movl   $0xc0126f84,-0x34(%ebp)
    return listelm->next;
c010393a:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010393d:	8b 40 04             	mov    0x4(%eax),%eax
    //SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
c0103940:	89 45 f0             	mov    %eax,-0x10(%ebp)
    
    for(;le!=&free_list && le<&(base->page_link);le=list_next(le));
c0103943:	eb 0f                	jmp    c0103954 <default_free_pages+0x128>
c0103945:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103948:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010394b:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010394e:	8b 40 04             	mov    0x4(%eax),%eax
c0103951:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103954:	81 7d f0 84 6f 12 c0 	cmpl   $0xc0126f84,-0x10(%ebp)
c010395b:	74 0b                	je     c0103968 <default_free_pages+0x13c>
c010395d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103960:	83 c0 0c             	add    $0xc,%eax
c0103963:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0103966:	72 dd                	jb     c0103945 <default_free_pages+0x119>

     nr_free += n;
c0103968:	8b 15 8c 6f 12 c0    	mov    0xc0126f8c,%edx
c010396e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103971:	01 d0                	add    %edx,%eax
c0103973:	a3 8c 6f 12 c0       	mov    %eax,0xc0126f8c
    list_add_before(le,&base->page_link);
c0103978:	8b 45 08             	mov    0x8(%ebp),%eax
c010397b:	8d 50 0c             	lea    0xc(%eax),%edx
c010397e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103981:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0103984:	89 55 c0             	mov    %edx,-0x40(%ebp)
    __list_add(elm, listelm->prev, listelm);
c0103987:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010398a:	8b 00                	mov    (%eax),%eax
c010398c:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010398f:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0103992:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0103995:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103998:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    prev->next = next->prev = elm;
c010399b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010399e:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01039a1:	89 10                	mov    %edx,(%eax)
c01039a3:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01039a6:	8b 10                	mov    (%eax),%edx
c01039a8:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01039ab:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01039ae:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01039b1:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01039b4:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01039b7:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01039ba:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01039bd:	89 10                	mov    %edx,(%eax)
}
c01039bf:	90                   	nop
}
c01039c0:	90                   	nop
    while(merge_backward(base));
c01039c1:	90                   	nop
c01039c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01039c5:	89 04 24             	mov    %eax,(%esp)
c01039c8:	e8 af fc ff ff       	call   c010367c <merge_backward>
c01039cd:	85 c0                	test   %eax,%eax
c01039cf:	75 f1                	jne    c01039c2 <default_free_pages+0x196>
    while(merge_beforeward(base));
c01039d1:	90                   	nop
c01039d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01039d5:	89 04 24             	mov    %eax,(%esp)
c01039d8:	e8 73 fd ff ff       	call   c0103750 <merge_beforeward>
c01039dd:	85 c0                	test   %eax,%eax
c01039df:	75 f1                	jne    c01039d2 <default_free_pages+0x1a6>
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));*/


}
c01039e1:	90                   	nop
c01039e2:	90                   	nop
c01039e3:	89 ec                	mov    %ebp,%esp
c01039e5:	5d                   	pop    %ebp
c01039e6:	c3                   	ret    

c01039e7 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c01039e7:	55                   	push   %ebp
c01039e8:	89 e5                	mov    %esp,%ebp
    return nr_free;
c01039ea:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
}
c01039ef:	5d                   	pop    %ebp
c01039f0:	c3                   	ret    

c01039f1 <basic_check>:

static void
basic_check(void) {
c01039f1:	55                   	push   %ebp
c01039f2:	89 e5                	mov    %esp,%ebp
c01039f4:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c01039f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01039fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a01:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a04:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a07:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0103a0a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103a11:	e8 2a 0f 00 00       	call   c0104940 <alloc_pages>
c0103a16:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103a19:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103a1d:	75 24                	jne    c0103a43 <basic_check+0x52>
c0103a1f:	c7 44 24 0c d9 9a 10 	movl   $0xc0109ad9,0xc(%esp)
c0103a26:	c0 
c0103a27:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c0103a2e:	c0 
c0103a2f:	c7 44 24 04 49 01 00 	movl   $0x149,0x4(%esp)
c0103a36:	00 
c0103a37:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c0103a3e:	e8 cb d2 ff ff       	call   c0100d0e <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103a43:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103a4a:	e8 f1 0e 00 00       	call   c0104940 <alloc_pages>
c0103a4f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a52:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103a56:	75 24                	jne    c0103a7c <basic_check+0x8b>
c0103a58:	c7 44 24 0c f5 9a 10 	movl   $0xc0109af5,0xc(%esp)
c0103a5f:	c0 
c0103a60:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c0103a67:	c0 
c0103a68:	c7 44 24 04 4a 01 00 	movl   $0x14a,0x4(%esp)
c0103a6f:	00 
c0103a70:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c0103a77:	e8 92 d2 ff ff       	call   c0100d0e <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103a7c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103a83:	e8 b8 0e 00 00       	call   c0104940 <alloc_pages>
c0103a88:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103a8b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103a8f:	75 24                	jne    c0103ab5 <basic_check+0xc4>
c0103a91:	c7 44 24 0c 11 9b 10 	movl   $0xc0109b11,0xc(%esp)
c0103a98:	c0 
c0103a99:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c0103aa0:	c0 
c0103aa1:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
c0103aa8:	00 
c0103aa9:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c0103ab0:	e8 59 d2 ff ff       	call   c0100d0e <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0103ab5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103ab8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103abb:	74 10                	je     c0103acd <basic_check+0xdc>
c0103abd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103ac0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103ac3:	74 08                	je     c0103acd <basic_check+0xdc>
c0103ac5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103ac8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103acb:	75 24                	jne    c0103af1 <basic_check+0x100>
c0103acd:	c7 44 24 0c 30 9b 10 	movl   $0xc0109b30,0xc(%esp)
c0103ad4:	c0 
c0103ad5:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c0103adc:	c0 
c0103add:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
c0103ae4:	00 
c0103ae5:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c0103aec:	e8 1d d2 ff ff       	call   c0100d0e <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0103af1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103af4:	89 04 24             	mov    %eax,(%esp)
c0103af7:	e8 1d f8 ff ff       	call   c0103319 <page_ref>
c0103afc:	85 c0                	test   %eax,%eax
c0103afe:	75 1e                	jne    c0103b1e <basic_check+0x12d>
c0103b00:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b03:	89 04 24             	mov    %eax,(%esp)
c0103b06:	e8 0e f8 ff ff       	call   c0103319 <page_ref>
c0103b0b:	85 c0                	test   %eax,%eax
c0103b0d:	75 0f                	jne    c0103b1e <basic_check+0x12d>
c0103b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b12:	89 04 24             	mov    %eax,(%esp)
c0103b15:	e8 ff f7 ff ff       	call   c0103319 <page_ref>
c0103b1a:	85 c0                	test   %eax,%eax
c0103b1c:	74 24                	je     c0103b42 <basic_check+0x151>
c0103b1e:	c7 44 24 0c 54 9b 10 	movl   $0xc0109b54,0xc(%esp)
c0103b25:	c0 
c0103b26:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c0103b2d:	c0 
c0103b2e:	c7 44 24 04 4e 01 00 	movl   $0x14e,0x4(%esp)
c0103b35:	00 
c0103b36:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c0103b3d:	e8 cc d1 ff ff       	call   c0100d0e <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0103b42:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b45:	89 04 24             	mov    %eax,(%esp)
c0103b48:	e8 b4 f7 ff ff       	call   c0103301 <page2pa>
c0103b4d:	8b 15 a4 6f 12 c0    	mov    0xc0126fa4,%edx
c0103b53:	c1 e2 0c             	shl    $0xc,%edx
c0103b56:	39 d0                	cmp    %edx,%eax
c0103b58:	72 24                	jb     c0103b7e <basic_check+0x18d>
c0103b5a:	c7 44 24 0c 90 9b 10 	movl   $0xc0109b90,0xc(%esp)
c0103b61:	c0 
c0103b62:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c0103b69:	c0 
c0103b6a:	c7 44 24 04 50 01 00 	movl   $0x150,0x4(%esp)
c0103b71:	00 
c0103b72:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c0103b79:	e8 90 d1 ff ff       	call   c0100d0e <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0103b7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b81:	89 04 24             	mov    %eax,(%esp)
c0103b84:	e8 78 f7 ff ff       	call   c0103301 <page2pa>
c0103b89:	8b 15 a4 6f 12 c0    	mov    0xc0126fa4,%edx
c0103b8f:	c1 e2 0c             	shl    $0xc,%edx
c0103b92:	39 d0                	cmp    %edx,%eax
c0103b94:	72 24                	jb     c0103bba <basic_check+0x1c9>
c0103b96:	c7 44 24 0c ad 9b 10 	movl   $0xc0109bad,0xc(%esp)
c0103b9d:	c0 
c0103b9e:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c0103ba5:	c0 
c0103ba6:	c7 44 24 04 51 01 00 	movl   $0x151,0x4(%esp)
c0103bad:	00 
c0103bae:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c0103bb5:	e8 54 d1 ff ff       	call   c0100d0e <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0103bba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103bbd:	89 04 24             	mov    %eax,(%esp)
c0103bc0:	e8 3c f7 ff ff       	call   c0103301 <page2pa>
c0103bc5:	8b 15 a4 6f 12 c0    	mov    0xc0126fa4,%edx
c0103bcb:	c1 e2 0c             	shl    $0xc,%edx
c0103bce:	39 d0                	cmp    %edx,%eax
c0103bd0:	72 24                	jb     c0103bf6 <basic_check+0x205>
c0103bd2:	c7 44 24 0c ca 9b 10 	movl   $0xc0109bca,0xc(%esp)
c0103bd9:	c0 
c0103bda:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c0103be1:	c0 
c0103be2:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
c0103be9:	00 
c0103bea:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c0103bf1:	e8 18 d1 ff ff       	call   c0100d0e <__panic>

    list_entry_t free_list_store = free_list;
c0103bf6:	a1 84 6f 12 c0       	mov    0xc0126f84,%eax
c0103bfb:	8b 15 88 6f 12 c0    	mov    0xc0126f88,%edx
c0103c01:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103c04:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103c07:	c7 45 dc 84 6f 12 c0 	movl   $0xc0126f84,-0x24(%ebp)
    elm->prev = elm->next = elm;
c0103c0e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103c11:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103c14:	89 50 04             	mov    %edx,0x4(%eax)
c0103c17:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103c1a:	8b 50 04             	mov    0x4(%eax),%edx
c0103c1d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103c20:	89 10                	mov    %edx,(%eax)
}
c0103c22:	90                   	nop
c0103c23:	c7 45 e0 84 6f 12 c0 	movl   $0xc0126f84,-0x20(%ebp)
    return list->next == list;
c0103c2a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103c2d:	8b 40 04             	mov    0x4(%eax),%eax
c0103c30:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0103c33:	0f 94 c0             	sete   %al
c0103c36:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103c39:	85 c0                	test   %eax,%eax
c0103c3b:	75 24                	jne    c0103c61 <basic_check+0x270>
c0103c3d:	c7 44 24 0c e7 9b 10 	movl   $0xc0109be7,0xc(%esp)
c0103c44:	c0 
c0103c45:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c0103c4c:	c0 
c0103c4d:	c7 44 24 04 56 01 00 	movl   $0x156,0x4(%esp)
c0103c54:	00 
c0103c55:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c0103c5c:	e8 ad d0 ff ff       	call   c0100d0e <__panic>

    unsigned int nr_free_store = nr_free;
c0103c61:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
c0103c66:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0103c69:	c7 05 8c 6f 12 c0 00 	movl   $0x0,0xc0126f8c
c0103c70:	00 00 00 

    assert(alloc_page() == NULL);
c0103c73:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103c7a:	e8 c1 0c 00 00       	call   c0104940 <alloc_pages>
c0103c7f:	85 c0                	test   %eax,%eax
c0103c81:	74 24                	je     c0103ca7 <basic_check+0x2b6>
c0103c83:	c7 44 24 0c fe 9b 10 	movl   $0xc0109bfe,0xc(%esp)
c0103c8a:	c0 
c0103c8b:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c0103c92:	c0 
c0103c93:	c7 44 24 04 5b 01 00 	movl   $0x15b,0x4(%esp)
c0103c9a:	00 
c0103c9b:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c0103ca2:	e8 67 d0 ff ff       	call   c0100d0e <__panic>

    free_page(p0);
c0103ca7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103cae:	00 
c0103caf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103cb2:	89 04 24             	mov    %eax,(%esp)
c0103cb5:	e8 f3 0c 00 00       	call   c01049ad <free_pages>
    free_page(p1);
c0103cba:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103cc1:	00 
c0103cc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103cc5:	89 04 24             	mov    %eax,(%esp)
c0103cc8:	e8 e0 0c 00 00       	call   c01049ad <free_pages>
    free_page(p2);
c0103ccd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103cd4:	00 
c0103cd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103cd8:	89 04 24             	mov    %eax,(%esp)
c0103cdb:	e8 cd 0c 00 00       	call   c01049ad <free_pages>
    assert(nr_free == 3);
c0103ce0:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
c0103ce5:	83 f8 03             	cmp    $0x3,%eax
c0103ce8:	74 24                	je     c0103d0e <basic_check+0x31d>
c0103cea:	c7 44 24 0c 13 9c 10 	movl   $0xc0109c13,0xc(%esp)
c0103cf1:	c0 
c0103cf2:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c0103cf9:	c0 
c0103cfa:	c7 44 24 04 60 01 00 	movl   $0x160,0x4(%esp)
c0103d01:	00 
c0103d02:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c0103d09:	e8 00 d0 ff ff       	call   c0100d0e <__panic>

    assert((p0 = alloc_page()) != NULL);
c0103d0e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103d15:	e8 26 0c 00 00       	call   c0104940 <alloc_pages>
c0103d1a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103d1d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103d21:	75 24                	jne    c0103d47 <basic_check+0x356>
c0103d23:	c7 44 24 0c d9 9a 10 	movl   $0xc0109ad9,0xc(%esp)
c0103d2a:	c0 
c0103d2b:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c0103d32:	c0 
c0103d33:	c7 44 24 04 62 01 00 	movl   $0x162,0x4(%esp)
c0103d3a:	00 
c0103d3b:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c0103d42:	e8 c7 cf ff ff       	call   c0100d0e <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103d47:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103d4e:	e8 ed 0b 00 00       	call   c0104940 <alloc_pages>
c0103d53:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103d56:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103d5a:	75 24                	jne    c0103d80 <basic_check+0x38f>
c0103d5c:	c7 44 24 0c f5 9a 10 	movl   $0xc0109af5,0xc(%esp)
c0103d63:	c0 
c0103d64:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c0103d6b:	c0 
c0103d6c:	c7 44 24 04 63 01 00 	movl   $0x163,0x4(%esp)
c0103d73:	00 
c0103d74:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c0103d7b:	e8 8e cf ff ff       	call   c0100d0e <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103d80:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103d87:	e8 b4 0b 00 00       	call   c0104940 <alloc_pages>
c0103d8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103d8f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103d93:	75 24                	jne    c0103db9 <basic_check+0x3c8>
c0103d95:	c7 44 24 0c 11 9b 10 	movl   $0xc0109b11,0xc(%esp)
c0103d9c:	c0 
c0103d9d:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c0103da4:	c0 
c0103da5:	c7 44 24 04 64 01 00 	movl   $0x164,0x4(%esp)
c0103dac:	00 
c0103dad:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c0103db4:	e8 55 cf ff ff       	call   c0100d0e <__panic>

    assert(alloc_page() == NULL);
c0103db9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103dc0:	e8 7b 0b 00 00       	call   c0104940 <alloc_pages>
c0103dc5:	85 c0                	test   %eax,%eax
c0103dc7:	74 24                	je     c0103ded <basic_check+0x3fc>
c0103dc9:	c7 44 24 0c fe 9b 10 	movl   $0xc0109bfe,0xc(%esp)
c0103dd0:	c0 
c0103dd1:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c0103dd8:	c0 
c0103dd9:	c7 44 24 04 66 01 00 	movl   $0x166,0x4(%esp)
c0103de0:	00 
c0103de1:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c0103de8:	e8 21 cf ff ff       	call   c0100d0e <__panic>

    free_page(p0);
c0103ded:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103df4:	00 
c0103df5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103df8:	89 04 24             	mov    %eax,(%esp)
c0103dfb:	e8 ad 0b 00 00       	call   c01049ad <free_pages>
c0103e00:	c7 45 d8 84 6f 12 c0 	movl   $0xc0126f84,-0x28(%ebp)
c0103e07:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103e0a:	8b 40 04             	mov    0x4(%eax),%eax
c0103e0d:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0103e10:	0f 94 c0             	sete   %al
c0103e13:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0103e16:	85 c0                	test   %eax,%eax
c0103e18:	74 24                	je     c0103e3e <basic_check+0x44d>
c0103e1a:	c7 44 24 0c 20 9c 10 	movl   $0xc0109c20,0xc(%esp)
c0103e21:	c0 
c0103e22:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c0103e29:	c0 
c0103e2a:	c7 44 24 04 69 01 00 	movl   $0x169,0x4(%esp)
c0103e31:	00 
c0103e32:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c0103e39:	e8 d0 ce ff ff       	call   c0100d0e <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0103e3e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103e45:	e8 f6 0a 00 00       	call   c0104940 <alloc_pages>
c0103e4a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103e4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103e50:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103e53:	74 24                	je     c0103e79 <basic_check+0x488>
c0103e55:	c7 44 24 0c 38 9c 10 	movl   $0xc0109c38,0xc(%esp)
c0103e5c:	c0 
c0103e5d:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c0103e64:	c0 
c0103e65:	c7 44 24 04 6c 01 00 	movl   $0x16c,0x4(%esp)
c0103e6c:	00 
c0103e6d:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c0103e74:	e8 95 ce ff ff       	call   c0100d0e <__panic>
    assert(alloc_page() == NULL);
c0103e79:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103e80:	e8 bb 0a 00 00       	call   c0104940 <alloc_pages>
c0103e85:	85 c0                	test   %eax,%eax
c0103e87:	74 24                	je     c0103ead <basic_check+0x4bc>
c0103e89:	c7 44 24 0c fe 9b 10 	movl   $0xc0109bfe,0xc(%esp)
c0103e90:	c0 
c0103e91:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c0103e98:	c0 
c0103e99:	c7 44 24 04 6d 01 00 	movl   $0x16d,0x4(%esp)
c0103ea0:	00 
c0103ea1:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c0103ea8:	e8 61 ce ff ff       	call   c0100d0e <__panic>

    assert(nr_free == 0);
c0103ead:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
c0103eb2:	85 c0                	test   %eax,%eax
c0103eb4:	74 24                	je     c0103eda <basic_check+0x4e9>
c0103eb6:	c7 44 24 0c 51 9c 10 	movl   $0xc0109c51,0xc(%esp)
c0103ebd:	c0 
c0103ebe:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c0103ec5:	c0 
c0103ec6:	c7 44 24 04 6f 01 00 	movl   $0x16f,0x4(%esp)
c0103ecd:	00 
c0103ece:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c0103ed5:	e8 34 ce ff ff       	call   c0100d0e <__panic>
    free_list = free_list_store;
c0103eda:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103edd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103ee0:	a3 84 6f 12 c0       	mov    %eax,0xc0126f84
c0103ee5:	89 15 88 6f 12 c0    	mov    %edx,0xc0126f88
    nr_free = nr_free_store;
c0103eeb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103eee:	a3 8c 6f 12 c0       	mov    %eax,0xc0126f8c

    free_page(p);
c0103ef3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103efa:	00 
c0103efb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103efe:	89 04 24             	mov    %eax,(%esp)
c0103f01:	e8 a7 0a 00 00       	call   c01049ad <free_pages>
    free_page(p1);
c0103f06:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f0d:	00 
c0103f0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f11:	89 04 24             	mov    %eax,(%esp)
c0103f14:	e8 94 0a 00 00       	call   c01049ad <free_pages>
    free_page(p2);
c0103f19:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f20:	00 
c0103f21:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f24:	89 04 24             	mov    %eax,(%esp)
c0103f27:	e8 81 0a 00 00       	call   c01049ad <free_pages>
}
c0103f2c:	90                   	nop
c0103f2d:	89 ec                	mov    %ebp,%esp
c0103f2f:	5d                   	pop    %ebp
c0103f30:	c3                   	ret    

c0103f31 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0103f31:	55                   	push   %ebp
c0103f32:	89 e5                	mov    %esp,%ebp
c0103f34:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0103f3a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103f41:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0103f48:	c7 45 ec 84 6f 12 c0 	movl   $0xc0126f84,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0103f4f:	eb 6a                	jmp    c0103fbb <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c0103f51:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103f54:	83 e8 0c             	sub    $0xc,%eax
c0103f57:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c0103f5a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103f5d:	83 c0 04             	add    $0x4,%eax
c0103f60:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0103f67:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103f6a:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103f6d:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103f70:	0f a3 10             	bt     %edx,(%eax)
c0103f73:	19 c0                	sbb    %eax,%eax
c0103f75:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0103f78:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0103f7c:	0f 95 c0             	setne  %al
c0103f7f:	0f b6 c0             	movzbl %al,%eax
c0103f82:	85 c0                	test   %eax,%eax
c0103f84:	75 24                	jne    c0103faa <default_check+0x79>
c0103f86:	c7 44 24 0c 5e 9c 10 	movl   $0xc0109c5e,0xc(%esp)
c0103f8d:	c0 
c0103f8e:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c0103f95:	c0 
c0103f96:	c7 44 24 04 80 01 00 	movl   $0x180,0x4(%esp)
c0103f9d:	00 
c0103f9e:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c0103fa5:	e8 64 cd ff ff       	call   c0100d0e <__panic>
        count ++, total += p->property;
c0103faa:	ff 45 f4             	incl   -0xc(%ebp)
c0103fad:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103fb0:	8b 50 08             	mov    0x8(%eax),%edx
c0103fb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103fb6:	01 d0                	add    %edx,%eax
c0103fb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103fbb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103fbe:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c0103fc1:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103fc4:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0103fc7:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103fca:	81 7d ec 84 6f 12 c0 	cmpl   $0xc0126f84,-0x14(%ebp)
c0103fd1:	0f 85 7a ff ff ff    	jne    c0103f51 <default_check+0x20>
    }
    assert(total == nr_free_pages());
c0103fd7:	e8 06 0a 00 00       	call   c01049e2 <nr_free_pages>
c0103fdc:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103fdf:	39 d0                	cmp    %edx,%eax
c0103fe1:	74 24                	je     c0104007 <default_check+0xd6>
c0103fe3:	c7 44 24 0c 6e 9c 10 	movl   $0xc0109c6e,0xc(%esp)
c0103fea:	c0 
c0103feb:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c0103ff2:	c0 
c0103ff3:	c7 44 24 04 83 01 00 	movl   $0x183,0x4(%esp)
c0103ffa:	00 
c0103ffb:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c0104002:	e8 07 cd ff ff       	call   c0100d0e <__panic>

    basic_check();
c0104007:	e8 e5 f9 ff ff       	call   c01039f1 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c010400c:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0104013:	e8 28 09 00 00       	call   c0104940 <alloc_pages>
c0104018:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c010401b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010401f:	75 24                	jne    c0104045 <default_check+0x114>
c0104021:	c7 44 24 0c 87 9c 10 	movl   $0xc0109c87,0xc(%esp)
c0104028:	c0 
c0104029:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c0104030:	c0 
c0104031:	c7 44 24 04 88 01 00 	movl   $0x188,0x4(%esp)
c0104038:	00 
c0104039:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c0104040:	e8 c9 cc ff ff       	call   c0100d0e <__panic>
    assert(!PageProperty(p0));
c0104045:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104048:	83 c0 04             	add    $0x4,%eax
c010404b:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0104052:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104055:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104058:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010405b:	0f a3 10             	bt     %edx,(%eax)
c010405e:	19 c0                	sbb    %eax,%eax
c0104060:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0104063:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0104067:	0f 95 c0             	setne  %al
c010406a:	0f b6 c0             	movzbl %al,%eax
c010406d:	85 c0                	test   %eax,%eax
c010406f:	74 24                	je     c0104095 <default_check+0x164>
c0104071:	c7 44 24 0c 92 9c 10 	movl   $0xc0109c92,0xc(%esp)
c0104078:	c0 
c0104079:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c0104080:	c0 
c0104081:	c7 44 24 04 89 01 00 	movl   $0x189,0x4(%esp)
c0104088:	00 
c0104089:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c0104090:	e8 79 cc ff ff       	call   c0100d0e <__panic>

    list_entry_t free_list_store = free_list;
c0104095:	a1 84 6f 12 c0       	mov    0xc0126f84,%eax
c010409a:	8b 15 88 6f 12 c0    	mov    0xc0126f88,%edx
c01040a0:	89 45 80             	mov    %eax,-0x80(%ebp)
c01040a3:	89 55 84             	mov    %edx,-0x7c(%ebp)
c01040a6:	c7 45 b0 84 6f 12 c0 	movl   $0xc0126f84,-0x50(%ebp)
    elm->prev = elm->next = elm;
c01040ad:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01040b0:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01040b3:	89 50 04             	mov    %edx,0x4(%eax)
c01040b6:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01040b9:	8b 50 04             	mov    0x4(%eax),%edx
c01040bc:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01040bf:	89 10                	mov    %edx,(%eax)
}
c01040c1:	90                   	nop
c01040c2:	c7 45 b4 84 6f 12 c0 	movl   $0xc0126f84,-0x4c(%ebp)
    return list->next == list;
c01040c9:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01040cc:	8b 40 04             	mov    0x4(%eax),%eax
c01040cf:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c01040d2:	0f 94 c0             	sete   %al
c01040d5:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c01040d8:	85 c0                	test   %eax,%eax
c01040da:	75 24                	jne    c0104100 <default_check+0x1cf>
c01040dc:	c7 44 24 0c e7 9b 10 	movl   $0xc0109be7,0xc(%esp)
c01040e3:	c0 
c01040e4:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c01040eb:	c0 
c01040ec:	c7 44 24 04 8d 01 00 	movl   $0x18d,0x4(%esp)
c01040f3:	00 
c01040f4:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c01040fb:	e8 0e cc ff ff       	call   c0100d0e <__panic>
    assert(alloc_page() == NULL);
c0104100:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104107:	e8 34 08 00 00       	call   c0104940 <alloc_pages>
c010410c:	85 c0                	test   %eax,%eax
c010410e:	74 24                	je     c0104134 <default_check+0x203>
c0104110:	c7 44 24 0c fe 9b 10 	movl   $0xc0109bfe,0xc(%esp)
c0104117:	c0 
c0104118:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c010411f:	c0 
c0104120:	c7 44 24 04 8e 01 00 	movl   $0x18e,0x4(%esp)
c0104127:	00 
c0104128:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c010412f:	e8 da cb ff ff       	call   c0100d0e <__panic>

    unsigned int nr_free_store = nr_free;
c0104134:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
c0104139:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c010413c:	c7 05 8c 6f 12 c0 00 	movl   $0x0,0xc0126f8c
c0104143:	00 00 00 

    free_pages(p0 + 2, 3);
c0104146:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104149:	83 c0 40             	add    $0x40,%eax
c010414c:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0104153:	00 
c0104154:	89 04 24             	mov    %eax,(%esp)
c0104157:	e8 51 08 00 00       	call   c01049ad <free_pages>
    assert(alloc_pages(4) == NULL);
c010415c:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0104163:	e8 d8 07 00 00       	call   c0104940 <alloc_pages>
c0104168:	85 c0                	test   %eax,%eax
c010416a:	74 24                	je     c0104190 <default_check+0x25f>
c010416c:	c7 44 24 0c a4 9c 10 	movl   $0xc0109ca4,0xc(%esp)
c0104173:	c0 
c0104174:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c010417b:	c0 
c010417c:	c7 44 24 04 94 01 00 	movl   $0x194,0x4(%esp)
c0104183:	00 
c0104184:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c010418b:	e8 7e cb ff ff       	call   c0100d0e <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0104190:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104193:	83 c0 40             	add    $0x40,%eax
c0104196:	83 c0 04             	add    $0x4,%eax
c0104199:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c01041a0:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01041a3:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01041a6:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01041a9:	0f a3 10             	bt     %edx,(%eax)
c01041ac:	19 c0                	sbb    %eax,%eax
c01041ae:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c01041b1:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c01041b5:	0f 95 c0             	setne  %al
c01041b8:	0f b6 c0             	movzbl %al,%eax
c01041bb:	85 c0                	test   %eax,%eax
c01041bd:	74 0e                	je     c01041cd <default_check+0x29c>
c01041bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01041c2:	83 c0 40             	add    $0x40,%eax
c01041c5:	8b 40 08             	mov    0x8(%eax),%eax
c01041c8:	83 f8 03             	cmp    $0x3,%eax
c01041cb:	74 24                	je     c01041f1 <default_check+0x2c0>
c01041cd:	c7 44 24 0c bc 9c 10 	movl   $0xc0109cbc,0xc(%esp)
c01041d4:	c0 
c01041d5:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c01041dc:	c0 
c01041dd:	c7 44 24 04 95 01 00 	movl   $0x195,0x4(%esp)
c01041e4:	00 
c01041e5:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c01041ec:	e8 1d cb ff ff       	call   c0100d0e <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c01041f1:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c01041f8:	e8 43 07 00 00       	call   c0104940 <alloc_pages>
c01041fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104200:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0104204:	75 24                	jne    c010422a <default_check+0x2f9>
c0104206:	c7 44 24 0c e8 9c 10 	movl   $0xc0109ce8,0xc(%esp)
c010420d:	c0 
c010420e:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c0104215:	c0 
c0104216:	c7 44 24 04 96 01 00 	movl   $0x196,0x4(%esp)
c010421d:	00 
c010421e:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c0104225:	e8 e4 ca ff ff       	call   c0100d0e <__panic>
    assert(alloc_page() == NULL);
c010422a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104231:	e8 0a 07 00 00       	call   c0104940 <alloc_pages>
c0104236:	85 c0                	test   %eax,%eax
c0104238:	74 24                	je     c010425e <default_check+0x32d>
c010423a:	c7 44 24 0c fe 9b 10 	movl   $0xc0109bfe,0xc(%esp)
c0104241:	c0 
c0104242:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c0104249:	c0 
c010424a:	c7 44 24 04 97 01 00 	movl   $0x197,0x4(%esp)
c0104251:	00 
c0104252:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c0104259:	e8 b0 ca ff ff       	call   c0100d0e <__panic>
    assert(p0 + 2 == p1);
c010425e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104261:	83 c0 40             	add    $0x40,%eax
c0104264:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0104267:	74 24                	je     c010428d <default_check+0x35c>
c0104269:	c7 44 24 0c 06 9d 10 	movl   $0xc0109d06,0xc(%esp)
c0104270:	c0 
c0104271:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c0104278:	c0 
c0104279:	c7 44 24 04 98 01 00 	movl   $0x198,0x4(%esp)
c0104280:	00 
c0104281:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c0104288:	e8 81 ca ff ff       	call   c0100d0e <__panic>

    p2 = p0 + 1;
c010428d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104290:	83 c0 20             	add    $0x20,%eax
c0104293:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c0104296:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010429d:	00 
c010429e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01042a1:	89 04 24             	mov    %eax,(%esp)
c01042a4:	e8 04 07 00 00       	call   c01049ad <free_pages>
    free_pages(p1, 3);
c01042a9:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01042b0:	00 
c01042b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01042b4:	89 04 24             	mov    %eax,(%esp)
c01042b7:	e8 f1 06 00 00       	call   c01049ad <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c01042bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01042bf:	83 c0 04             	add    $0x4,%eax
c01042c2:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c01042c9:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01042cc:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01042cf:	8b 55 a0             	mov    -0x60(%ebp),%edx
c01042d2:	0f a3 10             	bt     %edx,(%eax)
c01042d5:	19 c0                	sbb    %eax,%eax
c01042d7:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c01042da:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c01042de:	0f 95 c0             	setne  %al
c01042e1:	0f b6 c0             	movzbl %al,%eax
c01042e4:	85 c0                	test   %eax,%eax
c01042e6:	74 0b                	je     c01042f3 <default_check+0x3c2>
c01042e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01042eb:	8b 40 08             	mov    0x8(%eax),%eax
c01042ee:	83 f8 01             	cmp    $0x1,%eax
c01042f1:	74 24                	je     c0104317 <default_check+0x3e6>
c01042f3:	c7 44 24 0c 14 9d 10 	movl   $0xc0109d14,0xc(%esp)
c01042fa:	c0 
c01042fb:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c0104302:	c0 
c0104303:	c7 44 24 04 9d 01 00 	movl   $0x19d,0x4(%esp)
c010430a:	00 
c010430b:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c0104312:	e8 f7 c9 ff ff       	call   c0100d0e <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0104317:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010431a:	83 c0 04             	add    $0x4,%eax
c010431d:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0104324:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104327:	8b 45 90             	mov    -0x70(%ebp),%eax
c010432a:	8b 55 94             	mov    -0x6c(%ebp),%edx
c010432d:	0f a3 10             	bt     %edx,(%eax)
c0104330:	19 c0                	sbb    %eax,%eax
c0104332:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0104335:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0104339:	0f 95 c0             	setne  %al
c010433c:	0f b6 c0             	movzbl %al,%eax
c010433f:	85 c0                	test   %eax,%eax
c0104341:	74 0b                	je     c010434e <default_check+0x41d>
c0104343:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104346:	8b 40 08             	mov    0x8(%eax),%eax
c0104349:	83 f8 03             	cmp    $0x3,%eax
c010434c:	74 24                	je     c0104372 <default_check+0x441>
c010434e:	c7 44 24 0c 3c 9d 10 	movl   $0xc0109d3c,0xc(%esp)
c0104355:	c0 
c0104356:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c010435d:	c0 
c010435e:	c7 44 24 04 9e 01 00 	movl   $0x19e,0x4(%esp)
c0104365:	00 
c0104366:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c010436d:	e8 9c c9 ff ff       	call   c0100d0e <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0104372:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104379:	e8 c2 05 00 00       	call   c0104940 <alloc_pages>
c010437e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104381:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104384:	83 e8 20             	sub    $0x20,%eax
c0104387:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c010438a:	74 24                	je     c01043b0 <default_check+0x47f>
c010438c:	c7 44 24 0c 62 9d 10 	movl   $0xc0109d62,0xc(%esp)
c0104393:	c0 
c0104394:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c010439b:	c0 
c010439c:	c7 44 24 04 a0 01 00 	movl   $0x1a0,0x4(%esp)
c01043a3:	00 
c01043a4:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c01043ab:	e8 5e c9 ff ff       	call   c0100d0e <__panic>
    free_page(p0);
c01043b0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01043b7:	00 
c01043b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01043bb:	89 04 24             	mov    %eax,(%esp)
c01043be:	e8 ea 05 00 00       	call   c01049ad <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c01043c3:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c01043ca:	e8 71 05 00 00       	call   c0104940 <alloc_pages>
c01043cf:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01043d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01043d5:	83 c0 20             	add    $0x20,%eax
c01043d8:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01043db:	74 24                	je     c0104401 <default_check+0x4d0>
c01043dd:	c7 44 24 0c 80 9d 10 	movl   $0xc0109d80,0xc(%esp)
c01043e4:	c0 
c01043e5:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c01043ec:	c0 
c01043ed:	c7 44 24 04 a2 01 00 	movl   $0x1a2,0x4(%esp)
c01043f4:	00 
c01043f5:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c01043fc:	e8 0d c9 ff ff       	call   c0100d0e <__panic>

    free_pages(p0, 2);
c0104401:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0104408:	00 
c0104409:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010440c:	89 04 24             	mov    %eax,(%esp)
c010440f:	e8 99 05 00 00       	call   c01049ad <free_pages>
    free_page(p2);
c0104414:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010441b:	00 
c010441c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010441f:	89 04 24             	mov    %eax,(%esp)
c0104422:	e8 86 05 00 00       	call   c01049ad <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0104427:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c010442e:	e8 0d 05 00 00       	call   c0104940 <alloc_pages>
c0104433:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104436:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010443a:	75 24                	jne    c0104460 <default_check+0x52f>
c010443c:	c7 44 24 0c a0 9d 10 	movl   $0xc0109da0,0xc(%esp)
c0104443:	c0 
c0104444:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c010444b:	c0 
c010444c:	c7 44 24 04 a7 01 00 	movl   $0x1a7,0x4(%esp)
c0104453:	00 
c0104454:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c010445b:	e8 ae c8 ff ff       	call   c0100d0e <__panic>
    assert(alloc_page() == NULL);
c0104460:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104467:	e8 d4 04 00 00       	call   c0104940 <alloc_pages>
c010446c:	85 c0                	test   %eax,%eax
c010446e:	74 24                	je     c0104494 <default_check+0x563>
c0104470:	c7 44 24 0c fe 9b 10 	movl   $0xc0109bfe,0xc(%esp)
c0104477:	c0 
c0104478:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c010447f:	c0 
c0104480:	c7 44 24 04 a8 01 00 	movl   $0x1a8,0x4(%esp)
c0104487:	00 
c0104488:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c010448f:	e8 7a c8 ff ff       	call   c0100d0e <__panic>

    assert(nr_free == 0);
c0104494:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
c0104499:	85 c0                	test   %eax,%eax
c010449b:	74 24                	je     c01044c1 <default_check+0x590>
c010449d:	c7 44 24 0c 51 9c 10 	movl   $0xc0109c51,0xc(%esp)
c01044a4:	c0 
c01044a5:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c01044ac:	c0 
c01044ad:	c7 44 24 04 aa 01 00 	movl   $0x1aa,0x4(%esp)
c01044b4:	00 
c01044b5:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c01044bc:	e8 4d c8 ff ff       	call   c0100d0e <__panic>
    nr_free = nr_free_store;
c01044c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01044c4:	a3 8c 6f 12 c0       	mov    %eax,0xc0126f8c

    free_list = free_list_store;
c01044c9:	8b 45 80             	mov    -0x80(%ebp),%eax
c01044cc:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01044cf:	a3 84 6f 12 c0       	mov    %eax,0xc0126f84
c01044d4:	89 15 88 6f 12 c0    	mov    %edx,0xc0126f88
    free_pages(p0, 5);
c01044da:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c01044e1:	00 
c01044e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01044e5:	89 04 24             	mov    %eax,(%esp)
c01044e8:	e8 c0 04 00 00       	call   c01049ad <free_pages>

    le = &free_list;
c01044ed:	c7 45 ec 84 6f 12 c0 	movl   $0xc0126f84,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01044f4:	eb 5a                	jmp    c0104550 <default_check+0x61f>
        assert(le->next->prev == le && le->prev->next == le);
c01044f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01044f9:	8b 40 04             	mov    0x4(%eax),%eax
c01044fc:	8b 00                	mov    (%eax),%eax
c01044fe:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0104501:	75 0d                	jne    c0104510 <default_check+0x5df>
c0104503:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104506:	8b 00                	mov    (%eax),%eax
c0104508:	8b 40 04             	mov    0x4(%eax),%eax
c010450b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c010450e:	74 24                	je     c0104534 <default_check+0x603>
c0104510:	c7 44 24 0c c0 9d 10 	movl   $0xc0109dc0,0xc(%esp)
c0104517:	c0 
c0104518:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c010451f:	c0 
c0104520:	c7 44 24 04 b2 01 00 	movl   $0x1b2,0x4(%esp)
c0104527:	00 
c0104528:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c010452f:	e8 da c7 ff ff       	call   c0100d0e <__panic>
        struct Page *p = le2page(le, page_link);
c0104534:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104537:	83 e8 0c             	sub    $0xc,%eax
c010453a:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
c010453d:	ff 4d f4             	decl   -0xc(%ebp)
c0104540:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104543:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104546:	8b 48 08             	mov    0x8(%eax),%ecx
c0104549:	89 d0                	mov    %edx,%eax
c010454b:	29 c8                	sub    %ecx,%eax
c010454d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104550:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104553:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c0104556:	8b 45 88             	mov    -0x78(%ebp),%eax
c0104559:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c010455c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010455f:	81 7d ec 84 6f 12 c0 	cmpl   $0xc0126f84,-0x14(%ebp)
c0104566:	75 8e                	jne    c01044f6 <default_check+0x5c5>
    }
    assert(count == 0);
c0104568:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010456c:	74 24                	je     c0104592 <default_check+0x661>
c010456e:	c7 44 24 0c ed 9d 10 	movl   $0xc0109ded,0xc(%esp)
c0104575:	c0 
c0104576:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c010457d:	c0 
c010457e:	c7 44 24 04 b6 01 00 	movl   $0x1b6,0x4(%esp)
c0104585:	00 
c0104586:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c010458d:	e8 7c c7 ff ff       	call   c0100d0e <__panic>
    assert(total == 0);
c0104592:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104596:	74 24                	je     c01045bc <default_check+0x68b>
c0104598:	c7 44 24 0c f8 9d 10 	movl   $0xc0109df8,0xc(%esp)
c010459f:	c0 
c01045a0:	c7 44 24 08 76 9a 10 	movl   $0xc0109a76,0x8(%esp)
c01045a7:	c0 
c01045a8:	c7 44 24 04 b7 01 00 	movl   $0x1b7,0x4(%esp)
c01045af:	00 
c01045b0:	c7 04 24 8b 9a 10 c0 	movl   $0xc0109a8b,(%esp)
c01045b7:	e8 52 c7 ff ff       	call   c0100d0e <__panic>
}
c01045bc:	90                   	nop
c01045bd:	89 ec                	mov    %ebp,%esp
c01045bf:	5d                   	pop    %ebp
c01045c0:	c3                   	ret    

c01045c1 <page2ppn>:
page2ppn(struct Page *page) {
c01045c1:	55                   	push   %ebp
c01045c2:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01045c4:	8b 15 a0 6f 12 c0    	mov    0xc0126fa0,%edx
c01045ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01045cd:	29 d0                	sub    %edx,%eax
c01045cf:	c1 f8 05             	sar    $0x5,%eax
}
c01045d2:	5d                   	pop    %ebp
c01045d3:	c3                   	ret    

c01045d4 <page2pa>:
page2pa(struct Page *page) {
c01045d4:	55                   	push   %ebp
c01045d5:	89 e5                	mov    %esp,%ebp
c01045d7:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01045da:	8b 45 08             	mov    0x8(%ebp),%eax
c01045dd:	89 04 24             	mov    %eax,(%esp)
c01045e0:	e8 dc ff ff ff       	call   c01045c1 <page2ppn>
c01045e5:	c1 e0 0c             	shl    $0xc,%eax
}
c01045e8:	89 ec                	mov    %ebp,%esp
c01045ea:	5d                   	pop    %ebp
c01045eb:	c3                   	ret    

c01045ec <pa2page>:
pa2page(uintptr_t pa) {
c01045ec:	55                   	push   %ebp
c01045ed:	89 e5                	mov    %esp,%ebp
c01045ef:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01045f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01045f5:	c1 e8 0c             	shr    $0xc,%eax
c01045f8:	89 c2                	mov    %eax,%edx
c01045fa:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c01045ff:	39 c2                	cmp    %eax,%edx
c0104601:	72 1c                	jb     c010461f <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0104603:	c7 44 24 08 34 9e 10 	movl   $0xc0109e34,0x8(%esp)
c010460a:	c0 
c010460b:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c0104612:	00 
c0104613:	c7 04 24 53 9e 10 c0 	movl   $0xc0109e53,(%esp)
c010461a:	e8 ef c6 ff ff       	call   c0100d0e <__panic>
    return &pages[PPN(pa)];
c010461f:	8b 15 a0 6f 12 c0    	mov    0xc0126fa0,%edx
c0104625:	8b 45 08             	mov    0x8(%ebp),%eax
c0104628:	c1 e8 0c             	shr    $0xc,%eax
c010462b:	c1 e0 05             	shl    $0x5,%eax
c010462e:	01 d0                	add    %edx,%eax
}
c0104630:	89 ec                	mov    %ebp,%esp
c0104632:	5d                   	pop    %ebp
c0104633:	c3                   	ret    

c0104634 <page2kva>:
page2kva(struct Page *page) {
c0104634:	55                   	push   %ebp
c0104635:	89 e5                	mov    %esp,%ebp
c0104637:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c010463a:	8b 45 08             	mov    0x8(%ebp),%eax
c010463d:	89 04 24             	mov    %eax,(%esp)
c0104640:	e8 8f ff ff ff       	call   c01045d4 <page2pa>
c0104645:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104648:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010464b:	c1 e8 0c             	shr    $0xc,%eax
c010464e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104651:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c0104656:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104659:	72 23                	jb     c010467e <page2kva+0x4a>
c010465b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010465e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104662:	c7 44 24 08 64 9e 10 	movl   $0xc0109e64,0x8(%esp)
c0104669:	c0 
c010466a:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c0104671:	00 
c0104672:	c7 04 24 53 9e 10 c0 	movl   $0xc0109e53,(%esp)
c0104679:	e8 90 c6 ff ff       	call   c0100d0e <__panic>
c010467e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104681:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0104686:	89 ec                	mov    %ebp,%esp
c0104688:	5d                   	pop    %ebp
c0104689:	c3                   	ret    

c010468a <kva2page>:
kva2page(void *kva) {
c010468a:	55                   	push   %ebp
c010468b:	89 e5                	mov    %esp,%ebp
c010468d:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c0104690:	8b 45 08             	mov    0x8(%ebp),%eax
c0104693:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104696:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010469d:	77 23                	ja     c01046c2 <kva2page+0x38>
c010469f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01046a6:	c7 44 24 08 88 9e 10 	movl   $0xc0109e88,0x8(%esp)
c01046ad:	c0 
c01046ae:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c01046b5:	00 
c01046b6:	c7 04 24 53 9e 10 c0 	movl   $0xc0109e53,(%esp)
c01046bd:	e8 4c c6 ff ff       	call   c0100d0e <__panic>
c01046c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046c5:	05 00 00 00 40       	add    $0x40000000,%eax
c01046ca:	89 04 24             	mov    %eax,(%esp)
c01046cd:	e8 1a ff ff ff       	call   c01045ec <pa2page>
}
c01046d2:	89 ec                	mov    %ebp,%esp
c01046d4:	5d                   	pop    %ebp
c01046d5:	c3                   	ret    

c01046d6 <pte2page>:
pte2page(pte_t pte) {
c01046d6:	55                   	push   %ebp
c01046d7:	89 e5                	mov    %esp,%ebp
c01046d9:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c01046dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01046df:	83 e0 01             	and    $0x1,%eax
c01046e2:	85 c0                	test   %eax,%eax
c01046e4:	75 1c                	jne    c0104702 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c01046e6:	c7 44 24 08 ac 9e 10 	movl   $0xc0109eac,0x8(%esp)
c01046ed:	c0 
c01046ee:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c01046f5:	00 
c01046f6:	c7 04 24 53 9e 10 c0 	movl   $0xc0109e53,(%esp)
c01046fd:	e8 0c c6 ff ff       	call   c0100d0e <__panic>
    return pa2page(PTE_ADDR(pte));
c0104702:	8b 45 08             	mov    0x8(%ebp),%eax
c0104705:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010470a:	89 04 24             	mov    %eax,(%esp)
c010470d:	e8 da fe ff ff       	call   c01045ec <pa2page>
}
c0104712:	89 ec                	mov    %ebp,%esp
c0104714:	5d                   	pop    %ebp
c0104715:	c3                   	ret    

c0104716 <pde2page>:
pde2page(pde_t pde) {
c0104716:	55                   	push   %ebp
c0104717:	89 e5                	mov    %esp,%ebp
c0104719:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c010471c:	8b 45 08             	mov    0x8(%ebp),%eax
c010471f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104724:	89 04 24             	mov    %eax,(%esp)
c0104727:	e8 c0 fe ff ff       	call   c01045ec <pa2page>
}
c010472c:	89 ec                	mov    %ebp,%esp
c010472e:	5d                   	pop    %ebp
c010472f:	c3                   	ret    

c0104730 <page_ref>:
page_ref(struct Page *page) {
c0104730:	55                   	push   %ebp
c0104731:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0104733:	8b 45 08             	mov    0x8(%ebp),%eax
c0104736:	8b 00                	mov    (%eax),%eax
}
c0104738:	5d                   	pop    %ebp
c0104739:	c3                   	ret    

c010473a <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c010473a:	55                   	push   %ebp
c010473b:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c010473d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104740:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104743:	89 10                	mov    %edx,(%eax)
}
c0104745:	90                   	nop
c0104746:	5d                   	pop    %ebp
c0104747:	c3                   	ret    

c0104748 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0104748:	55                   	push   %ebp
c0104749:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c010474b:	8b 45 08             	mov    0x8(%ebp),%eax
c010474e:	8b 00                	mov    (%eax),%eax
c0104750:	8d 50 01             	lea    0x1(%eax),%edx
c0104753:	8b 45 08             	mov    0x8(%ebp),%eax
c0104756:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0104758:	8b 45 08             	mov    0x8(%ebp),%eax
c010475b:	8b 00                	mov    (%eax),%eax
}
c010475d:	5d                   	pop    %ebp
c010475e:	c3                   	ret    

c010475f <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c010475f:	55                   	push   %ebp
c0104760:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0104762:	8b 45 08             	mov    0x8(%ebp),%eax
c0104765:	8b 00                	mov    (%eax),%eax
c0104767:	8d 50 ff             	lea    -0x1(%eax),%edx
c010476a:	8b 45 08             	mov    0x8(%ebp),%eax
c010476d:	89 10                	mov    %edx,(%eax)
    return page->ref;
c010476f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104772:	8b 00                	mov    (%eax),%eax
}
c0104774:	5d                   	pop    %ebp
c0104775:	c3                   	ret    

c0104776 <__intr_save>:
__intr_save(void) {
c0104776:	55                   	push   %ebp
c0104777:	89 e5                	mov    %esp,%ebp
c0104779:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010477c:	9c                   	pushf  
c010477d:	58                   	pop    %eax
c010477e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0104781:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0104784:	25 00 02 00 00       	and    $0x200,%eax
c0104789:	85 c0                	test   %eax,%eax
c010478b:	74 0c                	je     c0104799 <__intr_save+0x23>
        intr_disable();
c010478d:	e8 32 d8 ff ff       	call   c0101fc4 <intr_disable>
        return 1;
c0104792:	b8 01 00 00 00       	mov    $0x1,%eax
c0104797:	eb 05                	jmp    c010479e <__intr_save+0x28>
    return 0;
c0104799:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010479e:	89 ec                	mov    %ebp,%esp
c01047a0:	5d                   	pop    %ebp
c01047a1:	c3                   	ret    

c01047a2 <__intr_restore>:
__intr_restore(bool flag) {
c01047a2:	55                   	push   %ebp
c01047a3:	89 e5                	mov    %esp,%ebp
c01047a5:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01047a8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01047ac:	74 05                	je     c01047b3 <__intr_restore+0x11>
        intr_enable();
c01047ae:	e8 09 d8 ff ff       	call   c0101fbc <intr_enable>
}
c01047b3:	90                   	nop
c01047b4:	89 ec                	mov    %ebp,%esp
c01047b6:	5d                   	pop    %ebp
c01047b7:	c3                   	ret    

c01047b8 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c01047b8:	55                   	push   %ebp
c01047b9:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c01047bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01047be:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c01047c1:	b8 23 00 00 00       	mov    $0x23,%eax
c01047c6:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c01047c8:	b8 23 00 00 00       	mov    $0x23,%eax
c01047cd:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c01047cf:	b8 10 00 00 00       	mov    $0x10,%eax
c01047d4:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c01047d6:	b8 10 00 00 00       	mov    $0x10,%eax
c01047db:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c01047dd:	b8 10 00 00 00       	mov    $0x10,%eax
c01047e2:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c01047e4:	ea eb 47 10 c0 08 00 	ljmp   $0x8,$0xc01047eb
}
c01047eb:	90                   	nop
c01047ec:	5d                   	pop    %ebp
c01047ed:	c3                   	ret    

c01047ee <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c01047ee:	55                   	push   %ebp
c01047ef:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c01047f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01047f4:	a3 c4 6f 12 c0       	mov    %eax,0xc0126fc4
}
c01047f9:	90                   	nop
c01047fa:	5d                   	pop    %ebp
c01047fb:	c3                   	ret    

c01047fc <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c01047fc:	55                   	push   %ebp
c01047fd:	89 e5                	mov    %esp,%ebp
c01047ff:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0104802:	b8 00 30 12 c0       	mov    $0xc0123000,%eax
c0104807:	89 04 24             	mov    %eax,(%esp)
c010480a:	e8 df ff ff ff       	call   c01047ee <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c010480f:	66 c7 05 c8 6f 12 c0 	movw   $0x10,0xc0126fc8
c0104816:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0104818:	66 c7 05 28 3a 12 c0 	movw   $0x68,0xc0123a28
c010481f:	68 00 
c0104821:	b8 c0 6f 12 c0       	mov    $0xc0126fc0,%eax
c0104826:	0f b7 c0             	movzwl %ax,%eax
c0104829:	66 a3 2a 3a 12 c0    	mov    %ax,0xc0123a2a
c010482f:	b8 c0 6f 12 c0       	mov    $0xc0126fc0,%eax
c0104834:	c1 e8 10             	shr    $0x10,%eax
c0104837:	a2 2c 3a 12 c0       	mov    %al,0xc0123a2c
c010483c:	0f b6 05 2d 3a 12 c0 	movzbl 0xc0123a2d,%eax
c0104843:	24 f0                	and    $0xf0,%al
c0104845:	0c 09                	or     $0x9,%al
c0104847:	a2 2d 3a 12 c0       	mov    %al,0xc0123a2d
c010484c:	0f b6 05 2d 3a 12 c0 	movzbl 0xc0123a2d,%eax
c0104853:	24 ef                	and    $0xef,%al
c0104855:	a2 2d 3a 12 c0       	mov    %al,0xc0123a2d
c010485a:	0f b6 05 2d 3a 12 c0 	movzbl 0xc0123a2d,%eax
c0104861:	24 9f                	and    $0x9f,%al
c0104863:	a2 2d 3a 12 c0       	mov    %al,0xc0123a2d
c0104868:	0f b6 05 2d 3a 12 c0 	movzbl 0xc0123a2d,%eax
c010486f:	0c 80                	or     $0x80,%al
c0104871:	a2 2d 3a 12 c0       	mov    %al,0xc0123a2d
c0104876:	0f b6 05 2e 3a 12 c0 	movzbl 0xc0123a2e,%eax
c010487d:	24 f0                	and    $0xf0,%al
c010487f:	a2 2e 3a 12 c0       	mov    %al,0xc0123a2e
c0104884:	0f b6 05 2e 3a 12 c0 	movzbl 0xc0123a2e,%eax
c010488b:	24 ef                	and    $0xef,%al
c010488d:	a2 2e 3a 12 c0       	mov    %al,0xc0123a2e
c0104892:	0f b6 05 2e 3a 12 c0 	movzbl 0xc0123a2e,%eax
c0104899:	24 df                	and    $0xdf,%al
c010489b:	a2 2e 3a 12 c0       	mov    %al,0xc0123a2e
c01048a0:	0f b6 05 2e 3a 12 c0 	movzbl 0xc0123a2e,%eax
c01048a7:	0c 40                	or     $0x40,%al
c01048a9:	a2 2e 3a 12 c0       	mov    %al,0xc0123a2e
c01048ae:	0f b6 05 2e 3a 12 c0 	movzbl 0xc0123a2e,%eax
c01048b5:	24 7f                	and    $0x7f,%al
c01048b7:	a2 2e 3a 12 c0       	mov    %al,0xc0123a2e
c01048bc:	b8 c0 6f 12 c0       	mov    $0xc0126fc0,%eax
c01048c1:	c1 e8 18             	shr    $0x18,%eax
c01048c4:	a2 2f 3a 12 c0       	mov    %al,0xc0123a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c01048c9:	c7 04 24 30 3a 12 c0 	movl   $0xc0123a30,(%esp)
c01048d0:	e8 e3 fe ff ff       	call   c01047b8 <lgdt>
c01048d5:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c01048db:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c01048df:	0f 00 d8             	ltr    %ax
}
c01048e2:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
c01048e3:	90                   	nop
c01048e4:	89 ec                	mov    %ebp,%esp
c01048e6:	5d                   	pop    %ebp
c01048e7:	c3                   	ret    

c01048e8 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c01048e8:	55                   	push   %ebp
c01048e9:	89 e5                	mov    %esp,%ebp
c01048eb:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c01048ee:	c7 05 ac 6f 12 c0 18 	movl   $0xc0109e18,0xc0126fac
c01048f5:	9e 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c01048f8:	a1 ac 6f 12 c0       	mov    0xc0126fac,%eax
c01048fd:	8b 00                	mov    (%eax),%eax
c01048ff:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104903:	c7 04 24 d8 9e 10 c0 	movl   $0xc0109ed8,(%esp)
c010490a:	e8 56 ba ff ff       	call   c0100365 <cprintf>
    pmm_manager->init();
c010490f:	a1 ac 6f 12 c0       	mov    0xc0126fac,%eax
c0104914:	8b 40 04             	mov    0x4(%eax),%eax
c0104917:	ff d0                	call   *%eax
}
c0104919:	90                   	nop
c010491a:	89 ec                	mov    %ebp,%esp
c010491c:	5d                   	pop    %ebp
c010491d:	c3                   	ret    

c010491e <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c010491e:	55                   	push   %ebp
c010491f:	89 e5                	mov    %esp,%ebp
c0104921:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0104924:	a1 ac 6f 12 c0       	mov    0xc0126fac,%eax
c0104929:	8b 40 08             	mov    0x8(%eax),%eax
c010492c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010492f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104933:	8b 55 08             	mov    0x8(%ebp),%edx
c0104936:	89 14 24             	mov    %edx,(%esp)
c0104939:	ff d0                	call   *%eax
}
c010493b:	90                   	nop
c010493c:	89 ec                	mov    %ebp,%esp
c010493e:	5d                   	pop    %ebp
c010493f:	c3                   	ret    

c0104940 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0104940:	55                   	push   %ebp
c0104941:	89 e5                	mov    %esp,%ebp
c0104943:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0104946:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c010494d:	e8 24 fe ff ff       	call   c0104776 <__intr_save>
c0104952:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c0104955:	a1 ac 6f 12 c0       	mov    0xc0126fac,%eax
c010495a:	8b 40 0c             	mov    0xc(%eax),%eax
c010495d:	8b 55 08             	mov    0x8(%ebp),%edx
c0104960:	89 14 24             	mov    %edx,(%esp)
c0104963:	ff d0                	call   *%eax
c0104965:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c0104968:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010496b:	89 04 24             	mov    %eax,(%esp)
c010496e:	e8 2f fe ff ff       	call   c01047a2 <__intr_restore>

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c0104973:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104977:	75 2d                	jne    c01049a6 <alloc_pages+0x66>
c0104979:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c010497d:	77 27                	ja     c01049a6 <alloc_pages+0x66>
c010497f:	a1 44 70 12 c0       	mov    0xc0127044,%eax
c0104984:	85 c0                	test   %eax,%eax
c0104986:	74 1e                	je     c01049a6 <alloc_pages+0x66>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c0104988:	8b 55 08             	mov    0x8(%ebp),%edx
c010498b:	a1 0c 71 12 c0       	mov    0xc012710c,%eax
c0104990:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104997:	00 
c0104998:	89 54 24 04          	mov    %edx,0x4(%esp)
c010499c:	89 04 24             	mov    %eax,(%esp)
c010499f:	e8 63 1a 00 00       	call   c0106407 <swap_out>
    {
c01049a4:	eb a7                	jmp    c010494d <alloc_pages+0xd>
    }
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c01049a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01049a9:	89 ec                	mov    %ebp,%esp
c01049ab:	5d                   	pop    %ebp
c01049ac:	c3                   	ret    

c01049ad <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c01049ad:	55                   	push   %ebp
c01049ae:	89 e5                	mov    %esp,%ebp
c01049b0:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c01049b3:	e8 be fd ff ff       	call   c0104776 <__intr_save>
c01049b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c01049bb:	a1 ac 6f 12 c0       	mov    0xc0126fac,%eax
c01049c0:	8b 40 10             	mov    0x10(%eax),%eax
c01049c3:	8b 55 0c             	mov    0xc(%ebp),%edx
c01049c6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01049ca:	8b 55 08             	mov    0x8(%ebp),%edx
c01049cd:	89 14 24             	mov    %edx,(%esp)
c01049d0:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c01049d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049d5:	89 04 24             	mov    %eax,(%esp)
c01049d8:	e8 c5 fd ff ff       	call   c01047a2 <__intr_restore>
}
c01049dd:	90                   	nop
c01049de:	89 ec                	mov    %ebp,%esp
c01049e0:	5d                   	pop    %ebp
c01049e1:	c3                   	ret    

c01049e2 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c01049e2:	55                   	push   %ebp
c01049e3:	89 e5                	mov    %esp,%ebp
c01049e5:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c01049e8:	e8 89 fd ff ff       	call   c0104776 <__intr_save>
c01049ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c01049f0:	a1 ac 6f 12 c0       	mov    0xc0126fac,%eax
c01049f5:	8b 40 14             	mov    0x14(%eax),%eax
c01049f8:	ff d0                	call   *%eax
c01049fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c01049fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a00:	89 04 24             	mov    %eax,(%esp)
c0104a03:	e8 9a fd ff ff       	call   c01047a2 <__intr_restore>
    return ret;
c0104a08:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0104a0b:	89 ec                	mov    %ebp,%esp
c0104a0d:	5d                   	pop    %ebp
c0104a0e:	c3                   	ret    

c0104a0f <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0104a0f:	55                   	push   %ebp
c0104a10:	89 e5                	mov    %esp,%ebp
c0104a12:	57                   	push   %edi
c0104a13:	56                   	push   %esi
c0104a14:	53                   	push   %ebx
c0104a15:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0104a1b:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0104a22:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0104a29:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0104a30:	c7 04 24 ef 9e 10 c0 	movl   $0xc0109eef,(%esp)
c0104a37:	e8 29 b9 ff ff       	call   c0100365 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0104a3c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104a43:	e9 0c 01 00 00       	jmp    c0104b54 <page_init+0x145>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0104a48:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104a4b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104a4e:	89 d0                	mov    %edx,%eax
c0104a50:	c1 e0 02             	shl    $0x2,%eax
c0104a53:	01 d0                	add    %edx,%eax
c0104a55:	c1 e0 02             	shl    $0x2,%eax
c0104a58:	01 c8                	add    %ecx,%eax
c0104a5a:	8b 50 08             	mov    0x8(%eax),%edx
c0104a5d:	8b 40 04             	mov    0x4(%eax),%eax
c0104a60:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0104a63:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0104a66:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104a69:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104a6c:	89 d0                	mov    %edx,%eax
c0104a6e:	c1 e0 02             	shl    $0x2,%eax
c0104a71:	01 d0                	add    %edx,%eax
c0104a73:	c1 e0 02             	shl    $0x2,%eax
c0104a76:	01 c8                	add    %ecx,%eax
c0104a78:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104a7b:	8b 58 10             	mov    0x10(%eax),%ebx
c0104a7e:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104a81:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0104a84:	01 c8                	add    %ecx,%eax
c0104a86:	11 da                	adc    %ebx,%edx
c0104a88:	89 45 98             	mov    %eax,-0x68(%ebp)
c0104a8b:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0104a8e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104a91:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104a94:	89 d0                	mov    %edx,%eax
c0104a96:	c1 e0 02             	shl    $0x2,%eax
c0104a99:	01 d0                	add    %edx,%eax
c0104a9b:	c1 e0 02             	shl    $0x2,%eax
c0104a9e:	01 c8                	add    %ecx,%eax
c0104aa0:	83 c0 14             	add    $0x14,%eax
c0104aa3:	8b 00                	mov    (%eax),%eax
c0104aa5:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c0104aab:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104aae:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0104ab1:	83 c0 ff             	add    $0xffffffff,%eax
c0104ab4:	83 d2 ff             	adc    $0xffffffff,%edx
c0104ab7:	89 c6                	mov    %eax,%esi
c0104ab9:	89 d7                	mov    %edx,%edi
c0104abb:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104abe:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104ac1:	89 d0                	mov    %edx,%eax
c0104ac3:	c1 e0 02             	shl    $0x2,%eax
c0104ac6:	01 d0                	add    %edx,%eax
c0104ac8:	c1 e0 02             	shl    $0x2,%eax
c0104acb:	01 c8                	add    %ecx,%eax
c0104acd:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104ad0:	8b 58 10             	mov    0x10(%eax),%ebx
c0104ad3:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0104ad9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c0104add:	89 74 24 14          	mov    %esi,0x14(%esp)
c0104ae1:	89 7c 24 18          	mov    %edi,0x18(%esp)
c0104ae5:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104ae8:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0104aeb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104aef:	89 54 24 10          	mov    %edx,0x10(%esp)
c0104af3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0104af7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0104afb:	c7 04 24 fc 9e 10 c0 	movl   $0xc0109efc,(%esp)
c0104b02:	e8 5e b8 ff ff       	call   c0100365 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0104b07:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104b0a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104b0d:	89 d0                	mov    %edx,%eax
c0104b0f:	c1 e0 02             	shl    $0x2,%eax
c0104b12:	01 d0                	add    %edx,%eax
c0104b14:	c1 e0 02             	shl    $0x2,%eax
c0104b17:	01 c8                	add    %ecx,%eax
c0104b19:	83 c0 14             	add    $0x14,%eax
c0104b1c:	8b 00                	mov    (%eax),%eax
c0104b1e:	83 f8 01             	cmp    $0x1,%eax
c0104b21:	75 2e                	jne    c0104b51 <page_init+0x142>
            if (maxpa < end && begin < KMEMSIZE) {
c0104b23:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104b26:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104b29:	3b 45 98             	cmp    -0x68(%ebp),%eax
c0104b2c:	89 d0                	mov    %edx,%eax
c0104b2e:	1b 45 9c             	sbb    -0x64(%ebp),%eax
c0104b31:	73 1e                	jae    c0104b51 <page_init+0x142>
c0104b33:	ba ff ff ff 37       	mov    $0x37ffffff,%edx
c0104b38:	b8 00 00 00 00       	mov    $0x0,%eax
c0104b3d:	3b 55 a0             	cmp    -0x60(%ebp),%edx
c0104b40:	1b 45 a4             	sbb    -0x5c(%ebp),%eax
c0104b43:	72 0c                	jb     c0104b51 <page_init+0x142>
                maxpa = end;
c0104b45:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104b48:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0104b4b:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104b4e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c0104b51:	ff 45 dc             	incl   -0x24(%ebp)
c0104b54:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104b57:	8b 00                	mov    (%eax),%eax
c0104b59:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0104b5c:	0f 8c e6 fe ff ff    	jl     c0104a48 <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0104b62:	ba 00 00 00 38       	mov    $0x38000000,%edx
c0104b67:	b8 00 00 00 00       	mov    $0x0,%eax
c0104b6c:	3b 55 e0             	cmp    -0x20(%ebp),%edx
c0104b6f:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
c0104b72:	73 0e                	jae    c0104b82 <page_init+0x173>
        maxpa = KMEMSIZE;
c0104b74:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0104b7b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0104b82:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104b85:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104b88:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0104b8c:	c1 ea 0c             	shr    $0xc,%edx
c0104b8f:	a3 a4 6f 12 c0       	mov    %eax,0xc0126fa4
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0104b94:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c0104b9b:	b8 14 71 12 c0       	mov    $0xc0127114,%eax
c0104ba0:	8d 50 ff             	lea    -0x1(%eax),%edx
c0104ba3:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104ba6:	01 d0                	add    %edx,%eax
c0104ba8:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0104bab:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104bae:	ba 00 00 00 00       	mov    $0x0,%edx
c0104bb3:	f7 75 c0             	divl   -0x40(%ebp)
c0104bb6:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104bb9:	29 d0                	sub    %edx,%eax
c0104bbb:	a3 a0 6f 12 c0       	mov    %eax,0xc0126fa0

    for (i = 0; i < npage; i ++) {
c0104bc0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104bc7:	eb 28                	jmp    c0104bf1 <page_init+0x1e2>
        SetPageReserved(pages + i);
c0104bc9:	8b 15 a0 6f 12 c0    	mov    0xc0126fa0,%edx
c0104bcf:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104bd2:	c1 e0 05             	shl    $0x5,%eax
c0104bd5:	01 d0                	add    %edx,%eax
c0104bd7:	83 c0 04             	add    $0x4,%eax
c0104bda:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c0104be1:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104be4:	8b 45 90             	mov    -0x70(%ebp),%eax
c0104be7:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0104bea:	0f ab 10             	bts    %edx,(%eax)
}
c0104bed:	90                   	nop
    for (i = 0; i < npage; i ++) {
c0104bee:	ff 45 dc             	incl   -0x24(%ebp)
c0104bf1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104bf4:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c0104bf9:	39 c2                	cmp    %eax,%edx
c0104bfb:	72 cc                	jb     c0104bc9 <page_init+0x1ba>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0104bfd:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c0104c02:	c1 e0 05             	shl    $0x5,%eax
c0104c05:	89 c2                	mov    %eax,%edx
c0104c07:	a1 a0 6f 12 c0       	mov    0xc0126fa0,%eax
c0104c0c:	01 d0                	add    %edx,%eax
c0104c0e:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0104c11:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c0104c18:	77 23                	ja     c0104c3d <page_init+0x22e>
c0104c1a:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104c1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104c21:	c7 44 24 08 88 9e 10 	movl   $0xc0109e88,0x8(%esp)
c0104c28:	c0 
c0104c29:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c0104c30:	00 
c0104c31:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0104c38:	e8 d1 c0 ff ff       	call   c0100d0e <__panic>
c0104c3d:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104c40:	05 00 00 00 40       	add    $0x40000000,%eax
c0104c45:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0104c48:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104c4f:	e9 53 01 00 00       	jmp    c0104da7 <page_init+0x398>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0104c54:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104c57:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104c5a:	89 d0                	mov    %edx,%eax
c0104c5c:	c1 e0 02             	shl    $0x2,%eax
c0104c5f:	01 d0                	add    %edx,%eax
c0104c61:	c1 e0 02             	shl    $0x2,%eax
c0104c64:	01 c8                	add    %ecx,%eax
c0104c66:	8b 50 08             	mov    0x8(%eax),%edx
c0104c69:	8b 40 04             	mov    0x4(%eax),%eax
c0104c6c:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104c6f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104c72:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104c75:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104c78:	89 d0                	mov    %edx,%eax
c0104c7a:	c1 e0 02             	shl    $0x2,%eax
c0104c7d:	01 d0                	add    %edx,%eax
c0104c7f:	c1 e0 02             	shl    $0x2,%eax
c0104c82:	01 c8                	add    %ecx,%eax
c0104c84:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104c87:	8b 58 10             	mov    0x10(%eax),%ebx
c0104c8a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104c8d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104c90:	01 c8                	add    %ecx,%eax
c0104c92:	11 da                	adc    %ebx,%edx
c0104c94:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104c97:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0104c9a:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104c9d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104ca0:	89 d0                	mov    %edx,%eax
c0104ca2:	c1 e0 02             	shl    $0x2,%eax
c0104ca5:	01 d0                	add    %edx,%eax
c0104ca7:	c1 e0 02             	shl    $0x2,%eax
c0104caa:	01 c8                	add    %ecx,%eax
c0104cac:	83 c0 14             	add    $0x14,%eax
c0104caf:	8b 00                	mov    (%eax),%eax
c0104cb1:	83 f8 01             	cmp    $0x1,%eax
c0104cb4:	0f 85 ea 00 00 00    	jne    c0104da4 <page_init+0x395>
            if (begin < freemem) {
c0104cba:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104cbd:	ba 00 00 00 00       	mov    $0x0,%edx
c0104cc2:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0104cc5:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0104cc8:	19 d1                	sbb    %edx,%ecx
c0104cca:	73 0d                	jae    c0104cd9 <page_init+0x2ca>
                begin = freemem;
c0104ccc:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104ccf:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104cd2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0104cd9:	ba 00 00 00 38       	mov    $0x38000000,%edx
c0104cde:	b8 00 00 00 00       	mov    $0x0,%eax
c0104ce3:	3b 55 c8             	cmp    -0x38(%ebp),%edx
c0104ce6:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0104ce9:	73 0e                	jae    c0104cf9 <page_init+0x2ea>
                end = KMEMSIZE;
c0104ceb:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0104cf2:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0104cf9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104cfc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104cff:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104d02:	89 d0                	mov    %edx,%eax
c0104d04:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0104d07:	0f 83 97 00 00 00    	jae    c0104da4 <page_init+0x395>
                begin = ROUNDUP(begin, PGSIZE);
c0104d0d:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c0104d14:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104d17:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104d1a:	01 d0                	add    %edx,%eax
c0104d1c:	48                   	dec    %eax
c0104d1d:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0104d20:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104d23:	ba 00 00 00 00       	mov    $0x0,%edx
c0104d28:	f7 75 b0             	divl   -0x50(%ebp)
c0104d2b:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104d2e:	29 d0                	sub    %edx,%eax
c0104d30:	ba 00 00 00 00       	mov    $0x0,%edx
c0104d35:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104d38:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0104d3b:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104d3e:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0104d41:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104d44:	ba 00 00 00 00       	mov    $0x0,%edx
c0104d49:	89 c7                	mov    %eax,%edi
c0104d4b:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c0104d51:	89 7d 80             	mov    %edi,-0x80(%ebp)
c0104d54:	89 d0                	mov    %edx,%eax
c0104d56:	83 e0 00             	and    $0x0,%eax
c0104d59:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0104d5c:	8b 45 80             	mov    -0x80(%ebp),%eax
c0104d5f:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104d62:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104d65:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c0104d68:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104d6b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104d6e:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104d71:	89 d0                	mov    %edx,%eax
c0104d73:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0104d76:	73 2c                	jae    c0104da4 <page_init+0x395>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0104d78:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104d7b:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104d7e:	2b 45 d0             	sub    -0x30(%ebp),%eax
c0104d81:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c0104d84:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0104d88:	c1 ea 0c             	shr    $0xc,%edx
c0104d8b:	89 c3                	mov    %eax,%ebx
c0104d8d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104d90:	89 04 24             	mov    %eax,(%esp)
c0104d93:	e8 54 f8 ff ff       	call   c01045ec <pa2page>
c0104d98:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104d9c:	89 04 24             	mov    %eax,(%esp)
c0104d9f:	e8 7a fb ff ff       	call   c010491e <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c0104da4:	ff 45 dc             	incl   -0x24(%ebp)
c0104da7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104daa:	8b 00                	mov    (%eax),%eax
c0104dac:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0104daf:	0f 8c 9f fe ff ff    	jl     c0104c54 <page_init+0x245>
                }
            }
        }
    }
}
c0104db5:	90                   	nop
c0104db6:	90                   	nop
c0104db7:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0104dbd:	5b                   	pop    %ebx
c0104dbe:	5e                   	pop    %esi
c0104dbf:	5f                   	pop    %edi
c0104dc0:	5d                   	pop    %ebp
c0104dc1:	c3                   	ret    

c0104dc2 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0104dc2:	55                   	push   %ebp
c0104dc3:	89 e5                	mov    %esp,%ebp
c0104dc5:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0104dc8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104dcb:	33 45 14             	xor    0x14(%ebp),%eax
c0104dce:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104dd3:	85 c0                	test   %eax,%eax
c0104dd5:	74 24                	je     c0104dfb <boot_map_segment+0x39>
c0104dd7:	c7 44 24 0c 3a 9f 10 	movl   $0xc0109f3a,0xc(%esp)
c0104dde:	c0 
c0104ddf:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c0104de6:	c0 
c0104de7:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
c0104dee:	00 
c0104def:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0104df6:	e8 13 bf ff ff       	call   c0100d0e <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0104dfb:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0104e02:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104e05:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104e0a:	89 c2                	mov    %eax,%edx
c0104e0c:	8b 45 10             	mov    0x10(%ebp),%eax
c0104e0f:	01 c2                	add    %eax,%edx
c0104e11:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e14:	01 d0                	add    %edx,%eax
c0104e16:	48                   	dec    %eax
c0104e17:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104e1a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e1d:	ba 00 00 00 00       	mov    $0x0,%edx
c0104e22:	f7 75 f0             	divl   -0x10(%ebp)
c0104e25:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e28:	29 d0                	sub    %edx,%eax
c0104e2a:	c1 e8 0c             	shr    $0xc,%eax
c0104e2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0104e30:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104e33:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104e36:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104e39:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104e3e:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0104e41:	8b 45 14             	mov    0x14(%ebp),%eax
c0104e44:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104e47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104e4a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104e4f:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0104e52:	eb 68                	jmp    c0104ebc <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0104e54:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0104e5b:	00 
c0104e5c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104e5f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104e63:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e66:	89 04 24             	mov    %eax,(%esp)
c0104e69:	e8 88 01 00 00       	call   c0104ff6 <get_pte>
c0104e6e:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0104e71:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0104e75:	75 24                	jne    c0104e9b <boot_map_segment+0xd9>
c0104e77:	c7 44 24 0c 66 9f 10 	movl   $0xc0109f66,0xc(%esp)
c0104e7e:	c0 
c0104e7f:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c0104e86:	c0 
c0104e87:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c0104e8e:	00 
c0104e8f:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0104e96:	e8 73 be ff ff       	call   c0100d0e <__panic>
        *ptep = pa | PTE_P | perm;
c0104e9b:	8b 45 14             	mov    0x14(%ebp),%eax
c0104e9e:	0b 45 18             	or     0x18(%ebp),%eax
c0104ea1:	83 c8 01             	or     $0x1,%eax
c0104ea4:	89 c2                	mov    %eax,%edx
c0104ea6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104ea9:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0104eab:	ff 4d f4             	decl   -0xc(%ebp)
c0104eae:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0104eb5:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0104ebc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104ec0:	75 92                	jne    c0104e54 <boot_map_segment+0x92>
    }
}
c0104ec2:	90                   	nop
c0104ec3:	90                   	nop
c0104ec4:	89 ec                	mov    %ebp,%esp
c0104ec6:	5d                   	pop    %ebp
c0104ec7:	c3                   	ret    

c0104ec8 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0104ec8:	55                   	push   %ebp
c0104ec9:	89 e5                	mov    %esp,%ebp
c0104ecb:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0104ece:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104ed5:	e8 66 fa ff ff       	call   c0104940 <alloc_pages>
c0104eda:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0104edd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104ee1:	75 1c                	jne    c0104eff <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0104ee3:	c7 44 24 08 73 9f 10 	movl   $0xc0109f73,0x8(%esp)
c0104eea:	c0 
c0104eeb:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c0104ef2:	00 
c0104ef3:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0104efa:	e8 0f be ff ff       	call   c0100d0e <__panic>
    }
    return page2kva(p);
c0104eff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f02:	89 04 24             	mov    %eax,(%esp)
c0104f05:	e8 2a f7 ff ff       	call   c0104634 <page2kva>
}
c0104f0a:	89 ec                	mov    %ebp,%esp
c0104f0c:	5d                   	pop    %ebp
c0104f0d:	c3                   	ret    

c0104f0e <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0104f0e:	55                   	push   %ebp
c0104f0f:	89 e5                	mov    %esp,%ebp
c0104f11:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0104f14:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0104f19:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104f1c:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0104f23:	77 23                	ja     c0104f48 <pmm_init+0x3a>
c0104f25:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f28:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104f2c:	c7 44 24 08 88 9e 10 	movl   $0xc0109e88,0x8(%esp)
c0104f33:	c0 
c0104f34:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
c0104f3b:	00 
c0104f3c:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0104f43:	e8 c6 bd ff ff       	call   c0100d0e <__panic>
c0104f48:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f4b:	05 00 00 00 40       	add    $0x40000000,%eax
c0104f50:	a3 a8 6f 12 c0       	mov    %eax,0xc0126fa8
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0104f55:	e8 8e f9 ff ff       	call   c01048e8 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0104f5a:	e8 b0 fa ff ff       	call   c0104a0f <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0104f5f:	e8 1e 05 00 00       	call   c0105482 <check_alloc_page>

    check_pgdir();
c0104f64:	e8 3a 05 00 00       	call   c01054a3 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0104f69:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0104f6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104f71:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0104f78:	77 23                	ja     c0104f9d <pmm_init+0x8f>
c0104f7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f7d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104f81:	c7 44 24 08 88 9e 10 	movl   $0xc0109e88,0x8(%esp)
c0104f88:	c0 
c0104f89:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
c0104f90:	00 
c0104f91:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0104f98:	e8 71 bd ff ff       	call   c0100d0e <__panic>
c0104f9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104fa0:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0104fa6:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0104fab:	05 ac 0f 00 00       	add    $0xfac,%eax
c0104fb0:	83 ca 03             	or     $0x3,%edx
c0104fb3:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0104fb5:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0104fba:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0104fc1:	00 
c0104fc2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104fc9:	00 
c0104fca:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0104fd1:	38 
c0104fd2:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0104fd9:	c0 
c0104fda:	89 04 24             	mov    %eax,(%esp)
c0104fdd:	e8 e0 fd ff ff       	call   c0104dc2 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0104fe2:	e8 15 f8 ff ff       	call   c01047fc <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0104fe7:	e8 55 0b 00 00       	call   c0105b41 <check_boot_pgdir>

    print_pgdir();
c0104fec:	e8 d2 0f 00 00       	call   c0105fc3 <print_pgdir>

}
c0104ff1:	90                   	nop
c0104ff2:	89 ec                	mov    %ebp,%esp
c0104ff4:	5d                   	pop    %ebp
c0104ff5:	c3                   	ret    

c0104ff6 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0104ff6:	55                   	push   %ebp
c0104ff7:	89 e5                	mov    %esp,%ebp
c0104ff9:	83 ec 38             	sub    $0x38,%esp
    }
    return NULL;          // (8) return page table entry
#endif

    
    pde_t *pdep=pgdir+PDX(la);
c0104ffc:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104fff:	c1 e8 16             	shr    $0x16,%eax
c0105002:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105009:	8b 45 08             	mov    0x8(%ebp),%eax
c010500c:	01 d0                	add    %edx,%eax
c010500e:	89 45 f4             	mov    %eax,-0xc(%ebp)

    pte_t *ptep=((pte_t*)KADDR(*pdep& ~0xfff))+PTX(la);
c0105011:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105014:	8b 00                	mov    (%eax),%eax
c0105016:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010501b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010501e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105021:	c1 e8 0c             	shr    $0xc,%eax
c0105024:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105027:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c010502c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c010502f:	72 23                	jb     c0105054 <get_pte+0x5e>
c0105031:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105034:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105038:	c7 44 24 08 64 9e 10 	movl   $0xc0109e64,0x8(%esp)
c010503f:	c0 
c0105040:	c7 44 24 04 7b 01 00 	movl   $0x17b,0x4(%esp)
c0105047:	00 
c0105048:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c010504f:	e8 ba bc ff ff       	call   c0100d0e <__panic>
c0105054:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105057:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010505c:	89 c2                	mov    %eax,%edx
c010505e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105061:	c1 e8 0c             	shr    $0xc,%eax
c0105064:	25 ff 03 00 00       	and    $0x3ff,%eax
c0105069:	c1 e0 02             	shl    $0x2,%eax
c010506c:	01 d0                	add    %edx,%eax
c010506e:	89 45 e8             	mov    %eax,-0x18(%ebp)

    if(*pdep & PTE_P) return ptep;
c0105071:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105074:	8b 00                	mov    (%eax),%eax
c0105076:	83 e0 01             	and    $0x1,%eax
c0105079:	85 c0                	test   %eax,%eax
c010507b:	74 08                	je     c0105085 <get_pte+0x8f>
c010507d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105080:	e9 dd 00 00 00       	jmp    c0105162 <get_pte+0x16c>
    
    if (!create) return NULL;
c0105085:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105089:	75 0a                	jne    c0105095 <get_pte+0x9f>
c010508b:	b8 00 00 00 00       	mov    $0x0,%eax
c0105090:	e9 cd 00 00 00       	jmp    c0105162 <get_pte+0x16c>

   struct Page *p=alloc_page();
c0105095:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010509c:	e8 9f f8 ff ff       	call   c0104940 <alloc_pages>
c01050a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
   if(p==NULL) return NULL;
c01050a4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01050a8:	75 0a                	jne    c01050b4 <get_pte+0xbe>
c01050aa:	b8 00 00 00 00       	mov    $0x0,%eax
c01050af:	e9 ae 00 00 00       	jmp    c0105162 <get_pte+0x16c>

   set_page_ref(p,1);
c01050b4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01050bb:	00 
c01050bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01050bf:	89 04 24             	mov    %eax,(%esp)
c01050c2:	e8 73 f6 ff ff       	call   c010473a <set_page_ref>

   ptep= KADDR(page2pa(p));
c01050c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01050ca:	89 04 24             	mov    %eax,(%esp)
c01050cd:	e8 02 f5 ff ff       	call   c01045d4 <page2pa>
c01050d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01050d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01050d8:	c1 e8 0c             	shr    $0xc,%eax
c01050db:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01050de:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c01050e3:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01050e6:	72 23                	jb     c010510b <get_pte+0x115>
c01050e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01050eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01050ef:	c7 44 24 08 64 9e 10 	movl   $0xc0109e64,0x8(%esp)
c01050f6:	c0 
c01050f7:	c7 44 24 04 86 01 00 	movl   $0x186,0x4(%esp)
c01050fe:	00 
c01050ff:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0105106:	e8 03 bc ff ff       	call   c0100d0e <__panic>
c010510b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010510e:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105113:	89 45 e8             	mov    %eax,-0x18(%ebp)

   memset(ptep,0,PGSIZE);
c0105116:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c010511d:	00 
c010511e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105125:	00 
c0105126:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105129:	89 04 24             	mov    %eax,(%esp)
c010512c:	e8 b4 3e 00 00       	call   c0108fe5 <memset>

   //更改原来的页目录项
   *pdep=(page2pa(p)&~0xfff)|PTE_U|PTE_P|PTE_W;
c0105131:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105134:	89 04 24             	mov    %eax,(%esp)
c0105137:	e8 98 f4 ff ff       	call   c01045d4 <page2pa>
c010513c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105141:	83 c8 07             	or     $0x7,%eax
c0105144:	89 c2                	mov    %eax,%edx
c0105146:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105149:	89 10                	mov    %edx,(%eax)

   return ptep+PTX(la);
c010514b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010514e:	c1 e8 0c             	shr    $0xc,%eax
c0105151:	25 ff 03 00 00       	and    $0x3ff,%eax
c0105156:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010515d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105160:	01 d0                	add    %edx,%eax
        *pdep = pa | PTE_U | PTE_W | PTE_P;
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];*/


}
c0105162:	89 ec                	mov    %ebp,%esp
c0105164:	5d                   	pop    %ebp
c0105165:	c3                   	ret    

c0105166 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0105166:	55                   	push   %ebp
c0105167:	89 e5                	mov    %esp,%ebp
c0105169:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c010516c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105173:	00 
c0105174:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105177:	89 44 24 04          	mov    %eax,0x4(%esp)
c010517b:	8b 45 08             	mov    0x8(%ebp),%eax
c010517e:	89 04 24             	mov    %eax,(%esp)
c0105181:	e8 70 fe ff ff       	call   c0104ff6 <get_pte>
c0105186:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0105189:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010518d:	74 08                	je     c0105197 <get_page+0x31>
        *ptep_store = ptep;
c010518f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105192:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105195:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0105197:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010519b:	74 1b                	je     c01051b8 <get_page+0x52>
c010519d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051a0:	8b 00                	mov    (%eax),%eax
c01051a2:	83 e0 01             	and    $0x1,%eax
c01051a5:	85 c0                	test   %eax,%eax
c01051a7:	74 0f                	je     c01051b8 <get_page+0x52>
        return pte2page(*ptep);
c01051a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051ac:	8b 00                	mov    (%eax),%eax
c01051ae:	89 04 24             	mov    %eax,(%esp)
c01051b1:	e8 20 f5 ff ff       	call   c01046d6 <pte2page>
c01051b6:	eb 05                	jmp    c01051bd <get_page+0x57>
    }
    return NULL;
c01051b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01051bd:	89 ec                	mov    %ebp,%esp
c01051bf:	5d                   	pop    %ebp
c01051c0:	c3                   	ret    

c01051c1 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c01051c1:	55                   	push   %ebp
c01051c2:	89 e5                	mov    %esp,%ebp
c01051c4:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    assert(*ptep & PTE_P);
c01051c7:	8b 45 10             	mov    0x10(%ebp),%eax
c01051ca:	8b 00                	mov    (%eax),%eax
c01051cc:	83 e0 01             	and    $0x1,%eax
c01051cf:	85 c0                	test   %eax,%eax
c01051d1:	75 24                	jne    c01051f7 <page_remove_pte+0x36>
c01051d3:	c7 44 24 0c 8c 9f 10 	movl   $0xc0109f8c,0xc(%esp)
c01051da:	c0 
c01051db:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c01051e2:	c0 
c01051e3:	c7 44 24 04 ca 01 00 	movl   $0x1ca,0x4(%esp)
c01051ea:	00 
c01051eb:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c01051f2:	e8 17 bb ff ff       	call   c0100d0e <__panic>
    struct Page *p=pte2page(*ptep);
c01051f7:	8b 45 10             	mov    0x10(%ebp),%eax
c01051fa:	8b 00                	mov    (%eax),%eax
c01051fc:	89 04 24             	mov    %eax,(%esp)
c01051ff:	e8 d2 f4 ff ff       	call   c01046d6 <pte2page>
c0105204:	89 45 f4             	mov    %eax,-0xc(%ebp)
    page_ref_dec(p);
c0105207:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010520a:	89 04 24             	mov    %eax,(%esp)
c010520d:	e8 4d f5 ff ff       	call   c010475f <page_ref_dec>
    if(p->ref==0)
c0105212:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105215:	8b 00                	mov    (%eax),%eax
c0105217:	85 c0                	test   %eax,%eax
c0105219:	75 13                	jne    c010522e <page_remove_pte+0x6d>
    {
        free_page(p);
c010521b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105222:	00 
c0105223:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105226:	89 04 24             	mov    %eax,(%esp)
c0105229:	e8 7f f7 ff ff       	call   c01049ad <free_pages>
    }
    *ptep&=~(PTE_P);
c010522e:	8b 45 10             	mov    0x10(%ebp),%eax
c0105231:	8b 00                	mov    (%eax),%eax
c0105233:	83 e0 fe             	and    $0xfffffffe,%eax
c0105236:	89 c2                	mov    %eax,%edx
c0105238:	8b 45 10             	mov    0x10(%ebp),%eax
c010523b:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir,la);
c010523d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105240:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105244:	8b 45 08             	mov    0x8(%ebp),%eax
c0105247:	89 04 24             	mov    %eax,(%esp)
c010524a:	e8 07 01 00 00       	call   c0105356 <tlb_invalidate>
        *ptep = 0;
        tlb_invalidate(pgdir, la);
    }*/


}
c010524f:	90                   	nop
c0105250:	89 ec                	mov    %ebp,%esp
c0105252:	5d                   	pop    %ebp
c0105253:	c3                   	ret    

c0105254 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0105254:	55                   	push   %ebp
c0105255:	89 e5                	mov    %esp,%ebp
c0105257:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c010525a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105261:	00 
c0105262:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105265:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105269:	8b 45 08             	mov    0x8(%ebp),%eax
c010526c:	89 04 24             	mov    %eax,(%esp)
c010526f:	e8 82 fd ff ff       	call   c0104ff6 <get_pte>
c0105274:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0105277:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010527b:	74 19                	je     c0105296 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c010527d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105280:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105284:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105287:	89 44 24 04          	mov    %eax,0x4(%esp)
c010528b:	8b 45 08             	mov    0x8(%ebp),%eax
c010528e:	89 04 24             	mov    %eax,(%esp)
c0105291:	e8 2b ff ff ff       	call   c01051c1 <page_remove_pte>
    }
}
c0105296:	90                   	nop
c0105297:	89 ec                	mov    %ebp,%esp
c0105299:	5d                   	pop    %ebp
c010529a:	c3                   	ret    

c010529b <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c010529b:	55                   	push   %ebp
c010529c:	89 e5                	mov    %esp,%ebp
c010529e:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c01052a1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01052a8:	00 
c01052a9:	8b 45 10             	mov    0x10(%ebp),%eax
c01052ac:	89 44 24 04          	mov    %eax,0x4(%esp)
c01052b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01052b3:	89 04 24             	mov    %eax,(%esp)
c01052b6:	e8 3b fd ff ff       	call   c0104ff6 <get_pte>
c01052bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c01052be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01052c2:	75 0a                	jne    c01052ce <page_insert+0x33>
        return -E_NO_MEM;
c01052c4:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01052c9:	e9 84 00 00 00       	jmp    c0105352 <page_insert+0xb7>
    }
    //对应物理页的引用次数+1
    page_ref_inc(page);
c01052ce:	8b 45 0c             	mov    0xc(%ebp),%eax
c01052d1:	89 04 24             	mov    %eax,(%esp)
c01052d4:	e8 6f f4 ff ff       	call   c0104748 <page_ref_inc>
    if (*ptep & PTE_P) {
c01052d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052dc:	8b 00                	mov    (%eax),%eax
c01052de:	83 e0 01             	and    $0x1,%eax
c01052e1:	85 c0                	test   %eax,%eax
c01052e3:	74 3e                	je     c0105323 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c01052e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052e8:	8b 00                	mov    (%eax),%eax
c01052ea:	89 04 24             	mov    %eax,(%esp)
c01052ed:	e8 e4 f3 ff ff       	call   c01046d6 <pte2page>
c01052f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c01052f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01052f8:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01052fb:	75 0d                	jne    c010530a <page_insert+0x6f>
            page_ref_dec(page);
c01052fd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105300:	89 04 24             	mov    %eax,(%esp)
c0105303:	e8 57 f4 ff ff       	call   c010475f <page_ref_dec>
c0105308:	eb 19                	jmp    c0105323 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c010530a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010530d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105311:	8b 45 10             	mov    0x10(%ebp),%eax
c0105314:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105318:	8b 45 08             	mov    0x8(%ebp),%eax
c010531b:	89 04 24             	mov    %eax,(%esp)
c010531e:	e8 9e fe ff ff       	call   c01051c1 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0105323:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105326:	89 04 24             	mov    %eax,(%esp)
c0105329:	e8 a6 f2 ff ff       	call   c01045d4 <page2pa>
c010532e:	0b 45 14             	or     0x14(%ebp),%eax
c0105331:	83 c8 01             	or     $0x1,%eax
c0105334:	89 c2                	mov    %eax,%edx
c0105336:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105339:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c010533b:	8b 45 10             	mov    0x10(%ebp),%eax
c010533e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105342:	8b 45 08             	mov    0x8(%ebp),%eax
c0105345:	89 04 24             	mov    %eax,(%esp)
c0105348:	e8 09 00 00 00       	call   c0105356 <tlb_invalidate>
    return 0;
c010534d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105352:	89 ec                	mov    %ebp,%esp
c0105354:	5d                   	pop    %ebp
c0105355:	c3                   	ret    

c0105356 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0105356:	55                   	push   %ebp
c0105357:	89 e5                	mov    %esp,%ebp
c0105359:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c010535c:	0f 20 d8             	mov    %cr3,%eax
c010535f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0105362:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c0105365:	8b 45 08             	mov    0x8(%ebp),%eax
c0105368:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010536b:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0105372:	77 23                	ja     c0105397 <tlb_invalidate+0x41>
c0105374:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105377:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010537b:	c7 44 24 08 88 9e 10 	movl   $0xc0109e88,0x8(%esp)
c0105382:	c0 
c0105383:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
c010538a:	00 
c010538b:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0105392:	e8 77 b9 ff ff       	call   c0100d0e <__panic>
c0105397:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010539a:	05 00 00 00 40       	add    $0x40000000,%eax
c010539f:	39 d0                	cmp    %edx,%eax
c01053a1:	75 0d                	jne    c01053b0 <tlb_invalidate+0x5a>
        invlpg((void *)la);
c01053a3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01053a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c01053a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01053ac:	0f 01 38             	invlpg (%eax)
}
c01053af:	90                   	nop
    }
}
c01053b0:	90                   	nop
c01053b1:	89 ec                	mov    %ebp,%esp
c01053b3:	5d                   	pop    %ebp
c01053b4:	c3                   	ret    

c01053b5 <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c01053b5:	55                   	push   %ebp
c01053b6:	89 e5                	mov    %esp,%ebp
c01053b8:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c01053bb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01053c2:	e8 79 f5 ff ff       	call   c0104940 <alloc_pages>
c01053c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c01053ca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01053ce:	0f 84 a7 00 00 00    	je     c010547b <pgdir_alloc_page+0xc6>
        if (page_insert(pgdir, page, la, perm) != 0) {
c01053d4:	8b 45 10             	mov    0x10(%ebp),%eax
c01053d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01053db:	8b 45 0c             	mov    0xc(%ebp),%eax
c01053de:	89 44 24 08          	mov    %eax,0x8(%esp)
c01053e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053e5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01053e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01053ec:	89 04 24             	mov    %eax,(%esp)
c01053ef:	e8 a7 fe ff ff       	call   c010529b <page_insert>
c01053f4:	85 c0                	test   %eax,%eax
c01053f6:	74 1a                	je     c0105412 <pgdir_alloc_page+0x5d>
            free_page(page);
c01053f8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01053ff:	00 
c0105400:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105403:	89 04 24             	mov    %eax,(%esp)
c0105406:	e8 a2 f5 ff ff       	call   c01049ad <free_pages>
            return NULL;
c010540b:	b8 00 00 00 00       	mov    $0x0,%eax
c0105410:	eb 6c                	jmp    c010547e <pgdir_alloc_page+0xc9>
        }
        if (swap_init_ok){
c0105412:	a1 44 70 12 c0       	mov    0xc0127044,%eax
c0105417:	85 c0                	test   %eax,%eax
c0105419:	74 60                	je     c010547b <pgdir_alloc_page+0xc6>
            swap_map_swappable(check_mm_struct, la, page, 0);
c010541b:	a1 0c 71 12 c0       	mov    0xc012710c,%eax
c0105420:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105427:	00 
c0105428:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010542b:	89 54 24 08          	mov    %edx,0x8(%esp)
c010542f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105432:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105436:	89 04 24             	mov    %eax,(%esp)
c0105439:	e8 79 0f 00 00       	call   c01063b7 <swap_map_swappable>
            page->pra_vaddr=la;
c010543e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105441:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105444:	89 50 1c             	mov    %edx,0x1c(%eax)
            assert(page_ref(page) == 1);
c0105447:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010544a:	89 04 24             	mov    %eax,(%esp)
c010544d:	e8 de f2 ff ff       	call   c0104730 <page_ref>
c0105452:	83 f8 01             	cmp    $0x1,%eax
c0105455:	74 24                	je     c010547b <pgdir_alloc_page+0xc6>
c0105457:	c7 44 24 0c 9a 9f 10 	movl   $0xc0109f9a,0xc(%esp)
c010545e:	c0 
c010545f:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c0105466:	c0 
c0105467:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
c010546e:	00 
c010546f:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0105476:	e8 93 b8 ff ff       	call   c0100d0e <__panic>
            //cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x, pra_link_next %x in pgdir_alloc_page\n", (page-pages), page->pra_vaddr,page->pra_page_link.prev, page->pra_page_link.next);
        }

    }

    return page;
c010547b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010547e:	89 ec                	mov    %ebp,%esp
c0105480:	5d                   	pop    %ebp
c0105481:	c3                   	ret    

c0105482 <check_alloc_page>:

static void
check_alloc_page(void) {
c0105482:	55                   	push   %ebp
c0105483:	89 e5                	mov    %esp,%ebp
c0105485:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c0105488:	a1 ac 6f 12 c0       	mov    0xc0126fac,%eax
c010548d:	8b 40 18             	mov    0x18(%eax),%eax
c0105490:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0105492:	c7 04 24 b0 9f 10 c0 	movl   $0xc0109fb0,(%esp)
c0105499:	e8 c7 ae ff ff       	call   c0100365 <cprintf>
}
c010549e:	90                   	nop
c010549f:	89 ec                	mov    %ebp,%esp
c01054a1:	5d                   	pop    %ebp
c01054a2:	c3                   	ret    

c01054a3 <check_pgdir>:

static void
check_pgdir(void) {
c01054a3:	55                   	push   %ebp
c01054a4:	89 e5                	mov    %esp,%ebp
c01054a6:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c01054a9:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c01054ae:	3d 00 80 03 00       	cmp    $0x38000,%eax
c01054b3:	76 24                	jbe    c01054d9 <check_pgdir+0x36>
c01054b5:	c7 44 24 0c cf 9f 10 	movl   $0xc0109fcf,0xc(%esp)
c01054bc:	c0 
c01054bd:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c01054c4:	c0 
c01054c5:	c7 44 24 04 2e 02 00 	movl   $0x22e,0x4(%esp)
c01054cc:	00 
c01054cd:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c01054d4:	e8 35 b8 ff ff       	call   c0100d0e <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c01054d9:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c01054de:	85 c0                	test   %eax,%eax
c01054e0:	74 0e                	je     c01054f0 <check_pgdir+0x4d>
c01054e2:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c01054e7:	25 ff 0f 00 00       	and    $0xfff,%eax
c01054ec:	85 c0                	test   %eax,%eax
c01054ee:	74 24                	je     c0105514 <check_pgdir+0x71>
c01054f0:	c7 44 24 0c ec 9f 10 	movl   $0xc0109fec,0xc(%esp)
c01054f7:	c0 
c01054f8:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c01054ff:	c0 
c0105500:	c7 44 24 04 2f 02 00 	movl   $0x22f,0x4(%esp)
c0105507:	00 
c0105508:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c010550f:	e8 fa b7 ff ff       	call   c0100d0e <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0105514:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105519:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105520:	00 
c0105521:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105528:	00 
c0105529:	89 04 24             	mov    %eax,(%esp)
c010552c:	e8 35 fc ff ff       	call   c0105166 <get_page>
c0105531:	85 c0                	test   %eax,%eax
c0105533:	74 24                	je     c0105559 <check_pgdir+0xb6>
c0105535:	c7 44 24 0c 24 a0 10 	movl   $0xc010a024,0xc(%esp)
c010553c:	c0 
c010553d:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c0105544:	c0 
c0105545:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
c010554c:	00 
c010554d:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0105554:	e8 b5 b7 ff ff       	call   c0100d0e <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0105559:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105560:	e8 db f3 ff ff       	call   c0104940 <alloc_pages>
c0105565:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0105568:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c010556d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105574:	00 
c0105575:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010557c:	00 
c010557d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105580:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105584:	89 04 24             	mov    %eax,(%esp)
c0105587:	e8 0f fd ff ff       	call   c010529b <page_insert>
c010558c:	85 c0                	test   %eax,%eax
c010558e:	74 24                	je     c01055b4 <check_pgdir+0x111>
c0105590:	c7 44 24 0c 4c a0 10 	movl   $0xc010a04c,0xc(%esp)
c0105597:	c0 
c0105598:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c010559f:	c0 
c01055a0:	c7 44 24 04 34 02 00 	movl   $0x234,0x4(%esp)
c01055a7:	00 
c01055a8:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c01055af:	e8 5a b7 ff ff       	call   c0100d0e <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c01055b4:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c01055b9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01055c0:	00 
c01055c1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01055c8:	00 
c01055c9:	89 04 24             	mov    %eax,(%esp)
c01055cc:	e8 25 fa ff ff       	call   c0104ff6 <get_pte>
c01055d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01055d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01055d8:	75 24                	jne    c01055fe <check_pgdir+0x15b>
c01055da:	c7 44 24 0c 78 a0 10 	movl   $0xc010a078,0xc(%esp)
c01055e1:	c0 
c01055e2:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c01055e9:	c0 
c01055ea:	c7 44 24 04 37 02 00 	movl   $0x237,0x4(%esp)
c01055f1:	00 
c01055f2:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c01055f9:	e8 10 b7 ff ff       	call   c0100d0e <__panic>
    assert(pte2page(*ptep) == p1);
c01055fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105601:	8b 00                	mov    (%eax),%eax
c0105603:	89 04 24             	mov    %eax,(%esp)
c0105606:	e8 cb f0 ff ff       	call   c01046d6 <pte2page>
c010560b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010560e:	74 24                	je     c0105634 <check_pgdir+0x191>
c0105610:	c7 44 24 0c a5 a0 10 	movl   $0xc010a0a5,0xc(%esp)
c0105617:	c0 
c0105618:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c010561f:	c0 
c0105620:	c7 44 24 04 38 02 00 	movl   $0x238,0x4(%esp)
c0105627:	00 
c0105628:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c010562f:	e8 da b6 ff ff       	call   c0100d0e <__panic>
    assert(page_ref(p1) == 1);
c0105634:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105637:	89 04 24             	mov    %eax,(%esp)
c010563a:	e8 f1 f0 ff ff       	call   c0104730 <page_ref>
c010563f:	83 f8 01             	cmp    $0x1,%eax
c0105642:	74 24                	je     c0105668 <check_pgdir+0x1c5>
c0105644:	c7 44 24 0c bb a0 10 	movl   $0xc010a0bb,0xc(%esp)
c010564b:	c0 
c010564c:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c0105653:	c0 
c0105654:	c7 44 24 04 39 02 00 	movl   $0x239,0x4(%esp)
c010565b:	00 
c010565c:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0105663:	e8 a6 b6 ff ff       	call   c0100d0e <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0105668:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c010566d:	8b 00                	mov    (%eax),%eax
c010566f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105674:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105677:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010567a:	c1 e8 0c             	shr    $0xc,%eax
c010567d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105680:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c0105685:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0105688:	72 23                	jb     c01056ad <check_pgdir+0x20a>
c010568a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010568d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105691:	c7 44 24 08 64 9e 10 	movl   $0xc0109e64,0x8(%esp)
c0105698:	c0 
c0105699:	c7 44 24 04 3b 02 00 	movl   $0x23b,0x4(%esp)
c01056a0:	00 
c01056a1:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c01056a8:	e8 61 b6 ff ff       	call   c0100d0e <__panic>
c01056ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01056b0:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01056b5:	83 c0 04             	add    $0x4,%eax
c01056b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c01056bb:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c01056c0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01056c7:	00 
c01056c8:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01056cf:	00 
c01056d0:	89 04 24             	mov    %eax,(%esp)
c01056d3:	e8 1e f9 ff ff       	call   c0104ff6 <get_pte>
c01056d8:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01056db:	74 24                	je     c0105701 <check_pgdir+0x25e>
c01056dd:	c7 44 24 0c d0 a0 10 	movl   $0xc010a0d0,0xc(%esp)
c01056e4:	c0 
c01056e5:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c01056ec:	c0 
c01056ed:	c7 44 24 04 3c 02 00 	movl   $0x23c,0x4(%esp)
c01056f4:	00 
c01056f5:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c01056fc:	e8 0d b6 ff ff       	call   c0100d0e <__panic>

    p2 = alloc_page();
c0105701:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105708:	e8 33 f2 ff ff       	call   c0104940 <alloc_pages>
c010570d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0105710:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105715:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c010571c:	00 
c010571d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105724:	00 
c0105725:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105728:	89 54 24 04          	mov    %edx,0x4(%esp)
c010572c:	89 04 24             	mov    %eax,(%esp)
c010572f:	e8 67 fb ff ff       	call   c010529b <page_insert>
c0105734:	85 c0                	test   %eax,%eax
c0105736:	74 24                	je     c010575c <check_pgdir+0x2b9>
c0105738:	c7 44 24 0c f8 a0 10 	movl   $0xc010a0f8,0xc(%esp)
c010573f:	c0 
c0105740:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c0105747:	c0 
c0105748:	c7 44 24 04 3f 02 00 	movl   $0x23f,0x4(%esp)
c010574f:	00 
c0105750:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0105757:	e8 b2 b5 ff ff       	call   c0100d0e <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c010575c:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105761:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105768:	00 
c0105769:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105770:	00 
c0105771:	89 04 24             	mov    %eax,(%esp)
c0105774:	e8 7d f8 ff ff       	call   c0104ff6 <get_pte>
c0105779:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010577c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105780:	75 24                	jne    c01057a6 <check_pgdir+0x303>
c0105782:	c7 44 24 0c 30 a1 10 	movl   $0xc010a130,0xc(%esp)
c0105789:	c0 
c010578a:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c0105791:	c0 
c0105792:	c7 44 24 04 40 02 00 	movl   $0x240,0x4(%esp)
c0105799:	00 
c010579a:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c01057a1:	e8 68 b5 ff ff       	call   c0100d0e <__panic>
    assert(*ptep & PTE_U);
c01057a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057a9:	8b 00                	mov    (%eax),%eax
c01057ab:	83 e0 04             	and    $0x4,%eax
c01057ae:	85 c0                	test   %eax,%eax
c01057b0:	75 24                	jne    c01057d6 <check_pgdir+0x333>
c01057b2:	c7 44 24 0c 60 a1 10 	movl   $0xc010a160,0xc(%esp)
c01057b9:	c0 
c01057ba:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c01057c1:	c0 
c01057c2:	c7 44 24 04 41 02 00 	movl   $0x241,0x4(%esp)
c01057c9:	00 
c01057ca:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c01057d1:	e8 38 b5 ff ff       	call   c0100d0e <__panic>
    assert(*ptep & PTE_W);
c01057d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057d9:	8b 00                	mov    (%eax),%eax
c01057db:	83 e0 02             	and    $0x2,%eax
c01057de:	85 c0                	test   %eax,%eax
c01057e0:	75 24                	jne    c0105806 <check_pgdir+0x363>
c01057e2:	c7 44 24 0c 6e a1 10 	movl   $0xc010a16e,0xc(%esp)
c01057e9:	c0 
c01057ea:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c01057f1:	c0 
c01057f2:	c7 44 24 04 42 02 00 	movl   $0x242,0x4(%esp)
c01057f9:	00 
c01057fa:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0105801:	e8 08 b5 ff ff       	call   c0100d0e <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0105806:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c010580b:	8b 00                	mov    (%eax),%eax
c010580d:	83 e0 04             	and    $0x4,%eax
c0105810:	85 c0                	test   %eax,%eax
c0105812:	75 24                	jne    c0105838 <check_pgdir+0x395>
c0105814:	c7 44 24 0c 7c a1 10 	movl   $0xc010a17c,0xc(%esp)
c010581b:	c0 
c010581c:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c0105823:	c0 
c0105824:	c7 44 24 04 43 02 00 	movl   $0x243,0x4(%esp)
c010582b:	00 
c010582c:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0105833:	e8 d6 b4 ff ff       	call   c0100d0e <__panic>
    assert(page_ref(p2) == 1);
c0105838:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010583b:	89 04 24             	mov    %eax,(%esp)
c010583e:	e8 ed ee ff ff       	call   c0104730 <page_ref>
c0105843:	83 f8 01             	cmp    $0x1,%eax
c0105846:	74 24                	je     c010586c <check_pgdir+0x3c9>
c0105848:	c7 44 24 0c 92 a1 10 	movl   $0xc010a192,0xc(%esp)
c010584f:	c0 
c0105850:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c0105857:	c0 
c0105858:	c7 44 24 04 44 02 00 	movl   $0x244,0x4(%esp)
c010585f:	00 
c0105860:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0105867:	e8 a2 b4 ff ff       	call   c0100d0e <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c010586c:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105871:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105878:	00 
c0105879:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105880:	00 
c0105881:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105884:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105888:	89 04 24             	mov    %eax,(%esp)
c010588b:	e8 0b fa ff ff       	call   c010529b <page_insert>
c0105890:	85 c0                	test   %eax,%eax
c0105892:	74 24                	je     c01058b8 <check_pgdir+0x415>
c0105894:	c7 44 24 0c a4 a1 10 	movl   $0xc010a1a4,0xc(%esp)
c010589b:	c0 
c010589c:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c01058a3:	c0 
c01058a4:	c7 44 24 04 46 02 00 	movl   $0x246,0x4(%esp)
c01058ab:	00 
c01058ac:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c01058b3:	e8 56 b4 ff ff       	call   c0100d0e <__panic>
    assert(page_ref(p1) == 2);
c01058b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058bb:	89 04 24             	mov    %eax,(%esp)
c01058be:	e8 6d ee ff ff       	call   c0104730 <page_ref>
c01058c3:	83 f8 02             	cmp    $0x2,%eax
c01058c6:	74 24                	je     c01058ec <check_pgdir+0x449>
c01058c8:	c7 44 24 0c d0 a1 10 	movl   $0xc010a1d0,0xc(%esp)
c01058cf:	c0 
c01058d0:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c01058d7:	c0 
c01058d8:	c7 44 24 04 47 02 00 	movl   $0x247,0x4(%esp)
c01058df:	00 
c01058e0:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c01058e7:	e8 22 b4 ff ff       	call   c0100d0e <__panic>
    assert(page_ref(p2) == 0);
c01058ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01058ef:	89 04 24             	mov    %eax,(%esp)
c01058f2:	e8 39 ee ff ff       	call   c0104730 <page_ref>
c01058f7:	85 c0                	test   %eax,%eax
c01058f9:	74 24                	je     c010591f <check_pgdir+0x47c>
c01058fb:	c7 44 24 0c e2 a1 10 	movl   $0xc010a1e2,0xc(%esp)
c0105902:	c0 
c0105903:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c010590a:	c0 
c010590b:	c7 44 24 04 48 02 00 	movl   $0x248,0x4(%esp)
c0105912:	00 
c0105913:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c010591a:	e8 ef b3 ff ff       	call   c0100d0e <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c010591f:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105924:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010592b:	00 
c010592c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105933:	00 
c0105934:	89 04 24             	mov    %eax,(%esp)
c0105937:	e8 ba f6 ff ff       	call   c0104ff6 <get_pte>
c010593c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010593f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105943:	75 24                	jne    c0105969 <check_pgdir+0x4c6>
c0105945:	c7 44 24 0c 30 a1 10 	movl   $0xc010a130,0xc(%esp)
c010594c:	c0 
c010594d:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c0105954:	c0 
c0105955:	c7 44 24 04 49 02 00 	movl   $0x249,0x4(%esp)
c010595c:	00 
c010595d:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0105964:	e8 a5 b3 ff ff       	call   c0100d0e <__panic>
    assert(pte2page(*ptep) == p1);
c0105969:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010596c:	8b 00                	mov    (%eax),%eax
c010596e:	89 04 24             	mov    %eax,(%esp)
c0105971:	e8 60 ed ff ff       	call   c01046d6 <pte2page>
c0105976:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0105979:	74 24                	je     c010599f <check_pgdir+0x4fc>
c010597b:	c7 44 24 0c a5 a0 10 	movl   $0xc010a0a5,0xc(%esp)
c0105982:	c0 
c0105983:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c010598a:	c0 
c010598b:	c7 44 24 04 4a 02 00 	movl   $0x24a,0x4(%esp)
c0105992:	00 
c0105993:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c010599a:	e8 6f b3 ff ff       	call   c0100d0e <__panic>
    assert((*ptep & PTE_U) == 0);
c010599f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059a2:	8b 00                	mov    (%eax),%eax
c01059a4:	83 e0 04             	and    $0x4,%eax
c01059a7:	85 c0                	test   %eax,%eax
c01059a9:	74 24                	je     c01059cf <check_pgdir+0x52c>
c01059ab:	c7 44 24 0c f4 a1 10 	movl   $0xc010a1f4,0xc(%esp)
c01059b2:	c0 
c01059b3:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c01059ba:	c0 
c01059bb:	c7 44 24 04 4b 02 00 	movl   $0x24b,0x4(%esp)
c01059c2:	00 
c01059c3:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c01059ca:	e8 3f b3 ff ff       	call   c0100d0e <__panic>

    page_remove(boot_pgdir, 0x0);
c01059cf:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c01059d4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01059db:	00 
c01059dc:	89 04 24             	mov    %eax,(%esp)
c01059df:	e8 70 f8 ff ff       	call   c0105254 <page_remove>
    assert(page_ref(p1) == 1);
c01059e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059e7:	89 04 24             	mov    %eax,(%esp)
c01059ea:	e8 41 ed ff ff       	call   c0104730 <page_ref>
c01059ef:	83 f8 01             	cmp    $0x1,%eax
c01059f2:	74 24                	je     c0105a18 <check_pgdir+0x575>
c01059f4:	c7 44 24 0c bb a0 10 	movl   $0xc010a0bb,0xc(%esp)
c01059fb:	c0 
c01059fc:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c0105a03:	c0 
c0105a04:	c7 44 24 04 4e 02 00 	movl   $0x24e,0x4(%esp)
c0105a0b:	00 
c0105a0c:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0105a13:	e8 f6 b2 ff ff       	call   c0100d0e <__panic>
    assert(page_ref(p2) == 0);
c0105a18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105a1b:	89 04 24             	mov    %eax,(%esp)
c0105a1e:	e8 0d ed ff ff       	call   c0104730 <page_ref>
c0105a23:	85 c0                	test   %eax,%eax
c0105a25:	74 24                	je     c0105a4b <check_pgdir+0x5a8>
c0105a27:	c7 44 24 0c e2 a1 10 	movl   $0xc010a1e2,0xc(%esp)
c0105a2e:	c0 
c0105a2f:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c0105a36:	c0 
c0105a37:	c7 44 24 04 4f 02 00 	movl   $0x24f,0x4(%esp)
c0105a3e:	00 
c0105a3f:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0105a46:	e8 c3 b2 ff ff       	call   c0100d0e <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0105a4b:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105a50:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105a57:	00 
c0105a58:	89 04 24             	mov    %eax,(%esp)
c0105a5b:	e8 f4 f7 ff ff       	call   c0105254 <page_remove>
    assert(page_ref(p1) == 0);
c0105a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a63:	89 04 24             	mov    %eax,(%esp)
c0105a66:	e8 c5 ec ff ff       	call   c0104730 <page_ref>
c0105a6b:	85 c0                	test   %eax,%eax
c0105a6d:	74 24                	je     c0105a93 <check_pgdir+0x5f0>
c0105a6f:	c7 44 24 0c 09 a2 10 	movl   $0xc010a209,0xc(%esp)
c0105a76:	c0 
c0105a77:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c0105a7e:	c0 
c0105a7f:	c7 44 24 04 52 02 00 	movl   $0x252,0x4(%esp)
c0105a86:	00 
c0105a87:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0105a8e:	e8 7b b2 ff ff       	call   c0100d0e <__panic>
    assert(page_ref(p2) == 0);
c0105a93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105a96:	89 04 24             	mov    %eax,(%esp)
c0105a99:	e8 92 ec ff ff       	call   c0104730 <page_ref>
c0105a9e:	85 c0                	test   %eax,%eax
c0105aa0:	74 24                	je     c0105ac6 <check_pgdir+0x623>
c0105aa2:	c7 44 24 0c e2 a1 10 	movl   $0xc010a1e2,0xc(%esp)
c0105aa9:	c0 
c0105aaa:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c0105ab1:	c0 
c0105ab2:	c7 44 24 04 53 02 00 	movl   $0x253,0x4(%esp)
c0105ab9:	00 
c0105aba:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0105ac1:	e8 48 b2 ff ff       	call   c0100d0e <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0105ac6:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105acb:	8b 00                	mov    (%eax),%eax
c0105acd:	89 04 24             	mov    %eax,(%esp)
c0105ad0:	e8 41 ec ff ff       	call   c0104716 <pde2page>
c0105ad5:	89 04 24             	mov    %eax,(%esp)
c0105ad8:	e8 53 ec ff ff       	call   c0104730 <page_ref>
c0105add:	83 f8 01             	cmp    $0x1,%eax
c0105ae0:	74 24                	je     c0105b06 <check_pgdir+0x663>
c0105ae2:	c7 44 24 0c 1c a2 10 	movl   $0xc010a21c,0xc(%esp)
c0105ae9:	c0 
c0105aea:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c0105af1:	c0 
c0105af2:	c7 44 24 04 55 02 00 	movl   $0x255,0x4(%esp)
c0105af9:	00 
c0105afa:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0105b01:	e8 08 b2 ff ff       	call   c0100d0e <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0105b06:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105b0b:	8b 00                	mov    (%eax),%eax
c0105b0d:	89 04 24             	mov    %eax,(%esp)
c0105b10:	e8 01 ec ff ff       	call   c0104716 <pde2page>
c0105b15:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105b1c:	00 
c0105b1d:	89 04 24             	mov    %eax,(%esp)
c0105b20:	e8 88 ee ff ff       	call   c01049ad <free_pages>
    boot_pgdir[0] = 0;
c0105b25:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105b2a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0105b30:	c7 04 24 43 a2 10 c0 	movl   $0xc010a243,(%esp)
c0105b37:	e8 29 a8 ff ff       	call   c0100365 <cprintf>
}
c0105b3c:	90                   	nop
c0105b3d:	89 ec                	mov    %ebp,%esp
c0105b3f:	5d                   	pop    %ebp
c0105b40:	c3                   	ret    

c0105b41 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0105b41:	55                   	push   %ebp
c0105b42:	89 e5                	mov    %esp,%ebp
c0105b44:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0105b47:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105b4e:	e9 ca 00 00 00       	jmp    c0105c1d <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0105b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b56:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105b59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105b5c:	c1 e8 0c             	shr    $0xc,%eax
c0105b5f:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105b62:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c0105b67:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0105b6a:	72 23                	jb     c0105b8f <check_boot_pgdir+0x4e>
c0105b6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105b6f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105b73:	c7 44 24 08 64 9e 10 	movl   $0xc0109e64,0x8(%esp)
c0105b7a:	c0 
c0105b7b:	c7 44 24 04 61 02 00 	movl   $0x261,0x4(%esp)
c0105b82:	00 
c0105b83:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0105b8a:	e8 7f b1 ff ff       	call   c0100d0e <__panic>
c0105b8f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105b92:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105b97:	89 c2                	mov    %eax,%edx
c0105b99:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105b9e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105ba5:	00 
c0105ba6:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105baa:	89 04 24             	mov    %eax,(%esp)
c0105bad:	e8 44 f4 ff ff       	call   c0104ff6 <get_pte>
c0105bb2:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105bb5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105bb9:	75 24                	jne    c0105bdf <check_boot_pgdir+0x9e>
c0105bbb:	c7 44 24 0c 60 a2 10 	movl   $0xc010a260,0xc(%esp)
c0105bc2:	c0 
c0105bc3:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c0105bca:	c0 
c0105bcb:	c7 44 24 04 61 02 00 	movl   $0x261,0x4(%esp)
c0105bd2:	00 
c0105bd3:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0105bda:	e8 2f b1 ff ff       	call   c0100d0e <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0105bdf:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105be2:	8b 00                	mov    (%eax),%eax
c0105be4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105be9:	89 c2                	mov    %eax,%edx
c0105beb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105bee:	39 c2                	cmp    %eax,%edx
c0105bf0:	74 24                	je     c0105c16 <check_boot_pgdir+0xd5>
c0105bf2:	c7 44 24 0c 9d a2 10 	movl   $0xc010a29d,0xc(%esp)
c0105bf9:	c0 
c0105bfa:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c0105c01:	c0 
c0105c02:	c7 44 24 04 62 02 00 	movl   $0x262,0x4(%esp)
c0105c09:	00 
c0105c0a:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0105c11:	e8 f8 b0 ff ff       	call   c0100d0e <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c0105c16:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0105c1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105c20:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c0105c25:	39 c2                	cmp    %eax,%edx
c0105c27:	0f 82 26 ff ff ff    	jb     c0105b53 <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0105c2d:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105c32:	05 ac 0f 00 00       	add    $0xfac,%eax
c0105c37:	8b 00                	mov    (%eax),%eax
c0105c39:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105c3e:	89 c2                	mov    %eax,%edx
c0105c40:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105c45:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105c48:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0105c4f:	77 23                	ja     c0105c74 <check_boot_pgdir+0x133>
c0105c51:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c54:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105c58:	c7 44 24 08 88 9e 10 	movl   $0xc0109e88,0x8(%esp)
c0105c5f:	c0 
c0105c60:	c7 44 24 04 65 02 00 	movl   $0x265,0x4(%esp)
c0105c67:	00 
c0105c68:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0105c6f:	e8 9a b0 ff ff       	call   c0100d0e <__panic>
c0105c74:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c77:	05 00 00 00 40       	add    $0x40000000,%eax
c0105c7c:	39 d0                	cmp    %edx,%eax
c0105c7e:	74 24                	je     c0105ca4 <check_boot_pgdir+0x163>
c0105c80:	c7 44 24 0c b4 a2 10 	movl   $0xc010a2b4,0xc(%esp)
c0105c87:	c0 
c0105c88:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c0105c8f:	c0 
c0105c90:	c7 44 24 04 65 02 00 	movl   $0x265,0x4(%esp)
c0105c97:	00 
c0105c98:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0105c9f:	e8 6a b0 ff ff       	call   c0100d0e <__panic>

    assert(boot_pgdir[0] == 0);
c0105ca4:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105ca9:	8b 00                	mov    (%eax),%eax
c0105cab:	85 c0                	test   %eax,%eax
c0105cad:	74 24                	je     c0105cd3 <check_boot_pgdir+0x192>
c0105caf:	c7 44 24 0c e8 a2 10 	movl   $0xc010a2e8,0xc(%esp)
c0105cb6:	c0 
c0105cb7:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c0105cbe:	c0 
c0105cbf:	c7 44 24 04 67 02 00 	movl   $0x267,0x4(%esp)
c0105cc6:	00 
c0105cc7:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0105cce:	e8 3b b0 ff ff       	call   c0100d0e <__panic>

    struct Page *p;
    p = alloc_page();
c0105cd3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105cda:	e8 61 ec ff ff       	call   c0104940 <alloc_pages>
c0105cdf:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0105ce2:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105ce7:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0105cee:	00 
c0105cef:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0105cf6:	00 
c0105cf7:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105cfa:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105cfe:	89 04 24             	mov    %eax,(%esp)
c0105d01:	e8 95 f5 ff ff       	call   c010529b <page_insert>
c0105d06:	85 c0                	test   %eax,%eax
c0105d08:	74 24                	je     c0105d2e <check_boot_pgdir+0x1ed>
c0105d0a:	c7 44 24 0c fc a2 10 	movl   $0xc010a2fc,0xc(%esp)
c0105d11:	c0 
c0105d12:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c0105d19:	c0 
c0105d1a:	c7 44 24 04 6b 02 00 	movl   $0x26b,0x4(%esp)
c0105d21:	00 
c0105d22:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0105d29:	e8 e0 af ff ff       	call   c0100d0e <__panic>
    assert(page_ref(p) == 1);
c0105d2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105d31:	89 04 24             	mov    %eax,(%esp)
c0105d34:	e8 f7 e9 ff ff       	call   c0104730 <page_ref>
c0105d39:	83 f8 01             	cmp    $0x1,%eax
c0105d3c:	74 24                	je     c0105d62 <check_boot_pgdir+0x221>
c0105d3e:	c7 44 24 0c 2a a3 10 	movl   $0xc010a32a,0xc(%esp)
c0105d45:	c0 
c0105d46:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c0105d4d:	c0 
c0105d4e:	c7 44 24 04 6c 02 00 	movl   $0x26c,0x4(%esp)
c0105d55:	00 
c0105d56:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0105d5d:	e8 ac af ff ff       	call   c0100d0e <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0105d62:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105d67:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0105d6e:	00 
c0105d6f:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0105d76:	00 
c0105d77:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105d7a:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105d7e:	89 04 24             	mov    %eax,(%esp)
c0105d81:	e8 15 f5 ff ff       	call   c010529b <page_insert>
c0105d86:	85 c0                	test   %eax,%eax
c0105d88:	74 24                	je     c0105dae <check_boot_pgdir+0x26d>
c0105d8a:	c7 44 24 0c 3c a3 10 	movl   $0xc010a33c,0xc(%esp)
c0105d91:	c0 
c0105d92:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c0105d99:	c0 
c0105d9a:	c7 44 24 04 6d 02 00 	movl   $0x26d,0x4(%esp)
c0105da1:	00 
c0105da2:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0105da9:	e8 60 af ff ff       	call   c0100d0e <__panic>
    assert(page_ref(p) == 2);
c0105dae:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105db1:	89 04 24             	mov    %eax,(%esp)
c0105db4:	e8 77 e9 ff ff       	call   c0104730 <page_ref>
c0105db9:	83 f8 02             	cmp    $0x2,%eax
c0105dbc:	74 24                	je     c0105de2 <check_boot_pgdir+0x2a1>
c0105dbe:	c7 44 24 0c 73 a3 10 	movl   $0xc010a373,0xc(%esp)
c0105dc5:	c0 
c0105dc6:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c0105dcd:	c0 
c0105dce:	c7 44 24 04 6e 02 00 	movl   $0x26e,0x4(%esp)
c0105dd5:	00 
c0105dd6:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0105ddd:	e8 2c af ff ff       	call   c0100d0e <__panic>

    const char *str = "ucore: Hello world!!";
c0105de2:	c7 45 e8 84 a3 10 c0 	movl   $0xc010a384,-0x18(%ebp)
    strcpy((void *)0x100, str);
c0105de9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105dec:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105df0:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105df7:	e8 19 2f 00 00       	call   c0108d15 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0105dfc:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0105e03:	00 
c0105e04:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105e0b:	e8 7d 2f 00 00       	call   c0108d8d <strcmp>
c0105e10:	85 c0                	test   %eax,%eax
c0105e12:	74 24                	je     c0105e38 <check_boot_pgdir+0x2f7>
c0105e14:	c7 44 24 0c 9c a3 10 	movl   $0xc010a39c,0xc(%esp)
c0105e1b:	c0 
c0105e1c:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c0105e23:	c0 
c0105e24:	c7 44 24 04 72 02 00 	movl   $0x272,0x4(%esp)
c0105e2b:	00 
c0105e2c:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0105e33:	e8 d6 ae ff ff       	call   c0100d0e <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0105e38:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e3b:	89 04 24             	mov    %eax,(%esp)
c0105e3e:	e8 f1 e7 ff ff       	call   c0104634 <page2kva>
c0105e43:	05 00 01 00 00       	add    $0x100,%eax
c0105e48:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0105e4b:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105e52:	e8 64 2e 00 00       	call   c0108cbb <strlen>
c0105e57:	85 c0                	test   %eax,%eax
c0105e59:	74 24                	je     c0105e7f <check_boot_pgdir+0x33e>
c0105e5b:	c7 44 24 0c d4 a3 10 	movl   $0xc010a3d4,0xc(%esp)
c0105e62:	c0 
c0105e63:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c0105e6a:	c0 
c0105e6b:	c7 44 24 04 75 02 00 	movl   $0x275,0x4(%esp)
c0105e72:	00 
c0105e73:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0105e7a:	e8 8f ae ff ff       	call   c0100d0e <__panic>

    free_page(p);
c0105e7f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105e86:	00 
c0105e87:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e8a:	89 04 24             	mov    %eax,(%esp)
c0105e8d:	e8 1b eb ff ff       	call   c01049ad <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0105e92:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105e97:	8b 00                	mov    (%eax),%eax
c0105e99:	89 04 24             	mov    %eax,(%esp)
c0105e9c:	e8 75 e8 ff ff       	call   c0104716 <pde2page>
c0105ea1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105ea8:	00 
c0105ea9:	89 04 24             	mov    %eax,(%esp)
c0105eac:	e8 fc ea ff ff       	call   c01049ad <free_pages>
    boot_pgdir[0] = 0;
c0105eb1:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105eb6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0105ebc:	c7 04 24 f8 a3 10 c0 	movl   $0xc010a3f8,(%esp)
c0105ec3:	e8 9d a4 ff ff       	call   c0100365 <cprintf>
}
c0105ec8:	90                   	nop
c0105ec9:	89 ec                	mov    %ebp,%esp
c0105ecb:	5d                   	pop    %ebp
c0105ecc:	c3                   	ret    

c0105ecd <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0105ecd:	55                   	push   %ebp
c0105ece:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0105ed0:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ed3:	83 e0 04             	and    $0x4,%eax
c0105ed6:	85 c0                	test   %eax,%eax
c0105ed8:	74 04                	je     c0105ede <perm2str+0x11>
c0105eda:	b0 75                	mov    $0x75,%al
c0105edc:	eb 02                	jmp    c0105ee0 <perm2str+0x13>
c0105ede:	b0 2d                	mov    $0x2d,%al
c0105ee0:	a2 28 70 12 c0       	mov    %al,0xc0127028
    str[1] = 'r';
c0105ee5:	c6 05 29 70 12 c0 72 	movb   $0x72,0xc0127029
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0105eec:	8b 45 08             	mov    0x8(%ebp),%eax
c0105eef:	83 e0 02             	and    $0x2,%eax
c0105ef2:	85 c0                	test   %eax,%eax
c0105ef4:	74 04                	je     c0105efa <perm2str+0x2d>
c0105ef6:	b0 77                	mov    $0x77,%al
c0105ef8:	eb 02                	jmp    c0105efc <perm2str+0x2f>
c0105efa:	b0 2d                	mov    $0x2d,%al
c0105efc:	a2 2a 70 12 c0       	mov    %al,0xc012702a
    str[3] = '\0';
c0105f01:	c6 05 2b 70 12 c0 00 	movb   $0x0,0xc012702b
    return str;
c0105f08:	b8 28 70 12 c0       	mov    $0xc0127028,%eax
}
c0105f0d:	5d                   	pop    %ebp
c0105f0e:	c3                   	ret    

c0105f0f <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0105f0f:	55                   	push   %ebp
c0105f10:	89 e5                	mov    %esp,%ebp
c0105f12:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0105f15:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f18:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105f1b:	72 0d                	jb     c0105f2a <get_pgtable_items+0x1b>
        return 0;
c0105f1d:	b8 00 00 00 00       	mov    $0x0,%eax
c0105f22:	e9 98 00 00 00       	jmp    c0105fbf <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c0105f27:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c0105f2a:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f2d:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105f30:	73 18                	jae    c0105f4a <get_pgtable_items+0x3b>
c0105f32:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f35:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105f3c:	8b 45 14             	mov    0x14(%ebp),%eax
c0105f3f:	01 d0                	add    %edx,%eax
c0105f41:	8b 00                	mov    (%eax),%eax
c0105f43:	83 e0 01             	and    $0x1,%eax
c0105f46:	85 c0                	test   %eax,%eax
c0105f48:	74 dd                	je     c0105f27 <get_pgtable_items+0x18>
    }
    if (start < right) {
c0105f4a:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f4d:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105f50:	73 68                	jae    c0105fba <get_pgtable_items+0xab>
        if (left_store != NULL) {
c0105f52:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0105f56:	74 08                	je     c0105f60 <get_pgtable_items+0x51>
            *left_store = start;
c0105f58:	8b 45 18             	mov    0x18(%ebp),%eax
c0105f5b:	8b 55 10             	mov    0x10(%ebp),%edx
c0105f5e:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0105f60:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f63:	8d 50 01             	lea    0x1(%eax),%edx
c0105f66:	89 55 10             	mov    %edx,0x10(%ebp)
c0105f69:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105f70:	8b 45 14             	mov    0x14(%ebp),%eax
c0105f73:	01 d0                	add    %edx,%eax
c0105f75:	8b 00                	mov    (%eax),%eax
c0105f77:	83 e0 07             	and    $0x7,%eax
c0105f7a:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0105f7d:	eb 03                	jmp    c0105f82 <get_pgtable_items+0x73>
            start ++;
c0105f7f:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0105f82:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f85:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105f88:	73 1d                	jae    c0105fa7 <get_pgtable_items+0x98>
c0105f8a:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f8d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105f94:	8b 45 14             	mov    0x14(%ebp),%eax
c0105f97:	01 d0                	add    %edx,%eax
c0105f99:	8b 00                	mov    (%eax),%eax
c0105f9b:	83 e0 07             	and    $0x7,%eax
c0105f9e:	89 c2                	mov    %eax,%edx
c0105fa0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105fa3:	39 c2                	cmp    %eax,%edx
c0105fa5:	74 d8                	je     c0105f7f <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
c0105fa7:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105fab:	74 08                	je     c0105fb5 <get_pgtable_items+0xa6>
            *right_store = start;
c0105fad:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105fb0:	8b 55 10             	mov    0x10(%ebp),%edx
c0105fb3:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0105fb5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105fb8:	eb 05                	jmp    c0105fbf <get_pgtable_items+0xb0>
    }
    return 0;
c0105fba:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105fbf:	89 ec                	mov    %ebp,%esp
c0105fc1:	5d                   	pop    %ebp
c0105fc2:	c3                   	ret    

c0105fc3 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0105fc3:	55                   	push   %ebp
c0105fc4:	89 e5                	mov    %esp,%ebp
c0105fc6:	57                   	push   %edi
c0105fc7:	56                   	push   %esi
c0105fc8:	53                   	push   %ebx
c0105fc9:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0105fcc:	c7 04 24 18 a4 10 c0 	movl   $0xc010a418,(%esp)
c0105fd3:	e8 8d a3 ff ff       	call   c0100365 <cprintf>
    size_t left, right = 0, perm;
c0105fd8:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0105fdf:	e9 f2 00 00 00       	jmp    c01060d6 <print_pgdir+0x113>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0105fe4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105fe7:	89 04 24             	mov    %eax,(%esp)
c0105fea:	e8 de fe ff ff       	call   c0105ecd <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0105fef:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105ff2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0105ff5:	29 ca                	sub    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0105ff7:	89 d6                	mov    %edx,%esi
c0105ff9:	c1 e6 16             	shl    $0x16,%esi
c0105ffc:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105fff:	89 d3                	mov    %edx,%ebx
c0106001:	c1 e3 16             	shl    $0x16,%ebx
c0106004:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106007:	89 d1                	mov    %edx,%ecx
c0106009:	c1 e1 16             	shl    $0x16,%ecx
c010600c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010600f:	8b 7d e0             	mov    -0x20(%ebp),%edi
c0106012:	29 fa                	sub    %edi,%edx
c0106014:	89 44 24 14          	mov    %eax,0x14(%esp)
c0106018:	89 74 24 10          	mov    %esi,0x10(%esp)
c010601c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0106020:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0106024:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106028:	c7 04 24 49 a4 10 c0 	movl   $0xc010a449,(%esp)
c010602f:	e8 31 a3 ff ff       	call   c0100365 <cprintf>
        size_t l, r = left * NPTEENTRY;
c0106034:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106037:	c1 e0 0a             	shl    $0xa,%eax
c010603a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c010603d:	eb 50                	jmp    c010608f <print_pgdir+0xcc>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c010603f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106042:	89 04 24             	mov    %eax,(%esp)
c0106045:	e8 83 fe ff ff       	call   c0105ecd <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c010604a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010604d:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c0106050:	29 ca                	sub    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0106052:	89 d6                	mov    %edx,%esi
c0106054:	c1 e6 0c             	shl    $0xc,%esi
c0106057:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010605a:	89 d3                	mov    %edx,%ebx
c010605c:	c1 e3 0c             	shl    $0xc,%ebx
c010605f:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106062:	89 d1                	mov    %edx,%ecx
c0106064:	c1 e1 0c             	shl    $0xc,%ecx
c0106067:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010606a:	8b 7d d8             	mov    -0x28(%ebp),%edi
c010606d:	29 fa                	sub    %edi,%edx
c010606f:	89 44 24 14          	mov    %eax,0x14(%esp)
c0106073:	89 74 24 10          	mov    %esi,0x10(%esp)
c0106077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010607b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010607f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106083:	c7 04 24 68 a4 10 c0 	movl   $0xc010a468,(%esp)
c010608a:	e8 d6 a2 ff ff       	call   c0100365 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c010608f:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c0106094:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106097:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010609a:	89 d3                	mov    %edx,%ebx
c010609c:	c1 e3 0a             	shl    $0xa,%ebx
c010609f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01060a2:	89 d1                	mov    %edx,%ecx
c01060a4:	c1 e1 0a             	shl    $0xa,%ecx
c01060a7:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c01060aa:	89 54 24 14          	mov    %edx,0x14(%esp)
c01060ae:	8d 55 d8             	lea    -0x28(%ebp),%edx
c01060b1:	89 54 24 10          	mov    %edx,0x10(%esp)
c01060b5:	89 74 24 0c          	mov    %esi,0xc(%esp)
c01060b9:	89 44 24 08          	mov    %eax,0x8(%esp)
c01060bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01060c1:	89 0c 24             	mov    %ecx,(%esp)
c01060c4:	e8 46 fe ff ff       	call   c0105f0f <get_pgtable_items>
c01060c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01060cc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01060d0:	0f 85 69 ff ff ff    	jne    c010603f <print_pgdir+0x7c>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c01060d6:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c01060db:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01060de:	8d 55 dc             	lea    -0x24(%ebp),%edx
c01060e1:	89 54 24 14          	mov    %edx,0x14(%esp)
c01060e5:	8d 55 e0             	lea    -0x20(%ebp),%edx
c01060e8:	89 54 24 10          	mov    %edx,0x10(%esp)
c01060ec:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01060f0:	89 44 24 08          	mov    %eax,0x8(%esp)
c01060f4:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c01060fb:	00 
c01060fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0106103:	e8 07 fe ff ff       	call   c0105f0f <get_pgtable_items>
c0106108:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010610b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010610f:	0f 85 cf fe ff ff    	jne    c0105fe4 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0106115:	c7 04 24 8c a4 10 c0 	movl   $0xc010a48c,(%esp)
c010611c:	e8 44 a2 ff ff       	call   c0100365 <cprintf>
}
c0106121:	90                   	nop
c0106122:	83 c4 4c             	add    $0x4c,%esp
c0106125:	5b                   	pop    %ebx
c0106126:	5e                   	pop    %esi
c0106127:	5f                   	pop    %edi
c0106128:	5d                   	pop    %ebp
c0106129:	c3                   	ret    

c010612a <kmalloc>:

void *
kmalloc(size_t n) {
c010612a:	55                   	push   %ebp
c010612b:	89 e5                	mov    %esp,%ebp
c010612d:	83 ec 28             	sub    $0x28,%esp
    void * ptr=NULL;
c0106130:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    struct Page *base=NULL;
c0106137:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    assert(n > 0 && n < 1024*0124);
c010613e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0106142:	74 09                	je     c010614d <kmalloc+0x23>
c0106144:	81 7d 08 ff 4f 01 00 	cmpl   $0x14fff,0x8(%ebp)
c010614b:	76 24                	jbe    c0106171 <kmalloc+0x47>
c010614d:	c7 44 24 0c bd a4 10 	movl   $0xc010a4bd,0xc(%esp)
c0106154:	c0 
c0106155:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c010615c:	c0 
c010615d:	c7 44 24 04 c1 02 00 	movl   $0x2c1,0x4(%esp)
c0106164:	00 
c0106165:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c010616c:	e8 9d ab ff ff       	call   c0100d0e <__panic>
    int num_pages=(n+PGSIZE-1)/PGSIZE;
c0106171:	8b 45 08             	mov    0x8(%ebp),%eax
c0106174:	05 ff 0f 00 00       	add    $0xfff,%eax
c0106179:	c1 e8 0c             	shr    $0xc,%eax
c010617c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    base = alloc_pages(num_pages);
c010617f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106182:	89 04 24             	mov    %eax,(%esp)
c0106185:	e8 b6 e7 ff ff       	call   c0104940 <alloc_pages>
c010618a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(base != NULL);
c010618d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106191:	75 24                	jne    c01061b7 <kmalloc+0x8d>
c0106193:	c7 44 24 0c d4 a4 10 	movl   $0xc010a4d4,0xc(%esp)
c010619a:	c0 
c010619b:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c01061a2:	c0 
c01061a3:	c7 44 24 04 c4 02 00 	movl   $0x2c4,0x4(%esp)
c01061aa:	00 
c01061ab:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c01061b2:	e8 57 ab ff ff       	call   c0100d0e <__panic>
    ptr=page2kva(base);
c01061b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01061ba:	89 04 24             	mov    %eax,(%esp)
c01061bd:	e8 72 e4 ff ff       	call   c0104634 <page2kva>
c01061c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ptr;
c01061c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01061c8:	89 ec                	mov    %ebp,%esp
c01061ca:	5d                   	pop    %ebp
c01061cb:	c3                   	ret    

c01061cc <kfree>:

void 
kfree(void *ptr, size_t n) {
c01061cc:	55                   	push   %ebp
c01061cd:	89 e5                	mov    %esp,%ebp
c01061cf:	83 ec 28             	sub    $0x28,%esp
    assert(n > 0 && n < 1024*0124);
c01061d2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01061d6:	74 09                	je     c01061e1 <kfree+0x15>
c01061d8:	81 7d 0c ff 4f 01 00 	cmpl   $0x14fff,0xc(%ebp)
c01061df:	76 24                	jbe    c0106205 <kfree+0x39>
c01061e1:	c7 44 24 0c bd a4 10 	movl   $0xc010a4bd,0xc(%esp)
c01061e8:	c0 
c01061e9:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c01061f0:	c0 
c01061f1:	c7 44 24 04 cb 02 00 	movl   $0x2cb,0x4(%esp)
c01061f8:	00 
c01061f9:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c0106200:	e8 09 ab ff ff       	call   c0100d0e <__panic>
    assert(ptr != NULL);
c0106205:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0106209:	75 24                	jne    c010622f <kfree+0x63>
c010620b:	c7 44 24 0c e1 a4 10 	movl   $0xc010a4e1,0xc(%esp)
c0106212:	c0 
c0106213:	c7 44 24 08 51 9f 10 	movl   $0xc0109f51,0x8(%esp)
c010621a:	c0 
c010621b:	c7 44 24 04 cc 02 00 	movl   $0x2cc,0x4(%esp)
c0106222:	00 
c0106223:	c7 04 24 2c 9f 10 c0 	movl   $0xc0109f2c,(%esp)
c010622a:	e8 df aa ff ff       	call   c0100d0e <__panic>
    struct Page *base=NULL;
c010622f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    int num_pages=(n+PGSIZE-1)/PGSIZE;
c0106236:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106239:	05 ff 0f 00 00       	add    $0xfff,%eax
c010623e:	c1 e8 0c             	shr    $0xc,%eax
c0106241:	89 45 f0             	mov    %eax,-0x10(%ebp)
    base = kva2page(ptr);
c0106244:	8b 45 08             	mov    0x8(%ebp),%eax
c0106247:	89 04 24             	mov    %eax,(%esp)
c010624a:	e8 3b e4 ff ff       	call   c010468a <kva2page>
c010624f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    free_pages(base, num_pages);
c0106252:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106255:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106259:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010625c:	89 04 24             	mov    %eax,(%esp)
c010625f:	e8 49 e7 ff ff       	call   c01049ad <free_pages>
}
c0106264:	90                   	nop
c0106265:	89 ec                	mov    %ebp,%esp
c0106267:	5d                   	pop    %ebp
c0106268:	c3                   	ret    

c0106269 <pa2page>:
pa2page(uintptr_t pa) {
c0106269:	55                   	push   %ebp
c010626a:	89 e5                	mov    %esp,%ebp
c010626c:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c010626f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106272:	c1 e8 0c             	shr    $0xc,%eax
c0106275:	89 c2                	mov    %eax,%edx
c0106277:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c010627c:	39 c2                	cmp    %eax,%edx
c010627e:	72 1c                	jb     c010629c <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0106280:	c7 44 24 08 f0 a4 10 	movl   $0xc010a4f0,0x8(%esp)
c0106287:	c0 
c0106288:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c010628f:	00 
c0106290:	c7 04 24 0f a5 10 c0 	movl   $0xc010a50f,(%esp)
c0106297:	e8 72 aa ff ff       	call   c0100d0e <__panic>
    return &pages[PPN(pa)];
c010629c:	8b 15 a0 6f 12 c0    	mov    0xc0126fa0,%edx
c01062a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01062a5:	c1 e8 0c             	shr    $0xc,%eax
c01062a8:	c1 e0 05             	shl    $0x5,%eax
c01062ab:	01 d0                	add    %edx,%eax
}
c01062ad:	89 ec                	mov    %ebp,%esp
c01062af:	5d                   	pop    %ebp
c01062b0:	c3                   	ret    

c01062b1 <pte2page>:
pte2page(pte_t pte) {
c01062b1:	55                   	push   %ebp
c01062b2:	89 e5                	mov    %esp,%ebp
c01062b4:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c01062b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01062ba:	83 e0 01             	and    $0x1,%eax
c01062bd:	85 c0                	test   %eax,%eax
c01062bf:	75 1c                	jne    c01062dd <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c01062c1:	c7 44 24 08 20 a5 10 	movl   $0xc010a520,0x8(%esp)
c01062c8:	c0 
c01062c9:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c01062d0:	00 
c01062d1:	c7 04 24 0f a5 10 c0 	movl   $0xc010a50f,(%esp)
c01062d8:	e8 31 aa ff ff       	call   c0100d0e <__panic>
    return pa2page(PTE_ADDR(pte));
c01062dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01062e0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01062e5:	89 04 24             	mov    %eax,(%esp)
c01062e8:	e8 7c ff ff ff       	call   c0106269 <pa2page>
}
c01062ed:	89 ec                	mov    %ebp,%esp
c01062ef:	5d                   	pop    %ebp
c01062f0:	c3                   	ret    

c01062f1 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c01062f1:	55                   	push   %ebp
c01062f2:	89 e5                	mov    %esp,%ebp
c01062f4:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c01062f7:	e8 40 21 00 00       	call   c010843c <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c01062fc:	a1 40 70 12 c0       	mov    0xc0127040,%eax
c0106301:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c0106306:	76 0c                	jbe    c0106314 <swap_init+0x23>
c0106308:	a1 40 70 12 c0       	mov    0xc0127040,%eax
c010630d:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c0106312:	76 25                	jbe    c0106339 <swap_init+0x48>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c0106314:	a1 40 70 12 c0       	mov    0xc0127040,%eax
c0106319:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010631d:	c7 44 24 08 41 a5 10 	movl   $0xc010a541,0x8(%esp)
c0106324:	c0 
c0106325:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
c010632c:	00 
c010632d:	c7 04 24 5c a5 10 c0 	movl   $0xc010a55c,(%esp)
c0106334:	e8 d5 a9 ff ff       	call   c0100d0e <__panic>
     }
     

     //sm = &swap_manager_fifo;
     sm= &swap_manager_extended_clock;
c0106339:	c7 05 00 71 12 c0 40 	movl   $0xc0123a40,0xc0127100
c0106340:	3a 12 c0 
     int r = sm->init();
c0106343:	a1 00 71 12 c0       	mov    0xc0127100,%eax
c0106348:	8b 40 04             	mov    0x4(%eax),%eax
c010634b:	ff d0                	call   *%eax
c010634d:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c0106350:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106354:	75 26                	jne    c010637c <swap_init+0x8b>
     {
          swap_init_ok = 1;
c0106356:	c7 05 44 70 12 c0 01 	movl   $0x1,0xc0127044
c010635d:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c0106360:	a1 00 71 12 c0       	mov    0xc0127100,%eax
c0106365:	8b 00                	mov    (%eax),%eax
c0106367:	89 44 24 04          	mov    %eax,0x4(%esp)
c010636b:	c7 04 24 6b a5 10 c0 	movl   $0xc010a56b,(%esp)
c0106372:	e8 ee 9f ff ff       	call   c0100365 <cprintf>
          check_swap();
c0106377:	e8 a5 05 00 00       	call   c0106921 <check_swap>
     }

     return r;
c010637c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010637f:	89 ec                	mov    %ebp,%esp
c0106381:	5d                   	pop    %ebp
c0106382:	c3                   	ret    

c0106383 <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c0106383:	55                   	push   %ebp
c0106384:	89 e5                	mov    %esp,%ebp
c0106386:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c0106389:	a1 00 71 12 c0       	mov    0xc0127100,%eax
c010638e:	8b 40 08             	mov    0x8(%eax),%eax
c0106391:	8b 55 08             	mov    0x8(%ebp),%edx
c0106394:	89 14 24             	mov    %edx,(%esp)
c0106397:	ff d0                	call   *%eax
}
c0106399:	89 ec                	mov    %ebp,%esp
c010639b:	5d                   	pop    %ebp
c010639c:	c3                   	ret    

c010639d <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c010639d:	55                   	push   %ebp
c010639e:	89 e5                	mov    %esp,%ebp
c01063a0:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c01063a3:	a1 00 71 12 c0       	mov    0xc0127100,%eax
c01063a8:	8b 40 0c             	mov    0xc(%eax),%eax
c01063ab:	8b 55 08             	mov    0x8(%ebp),%edx
c01063ae:	89 14 24             	mov    %edx,(%esp)
c01063b1:	ff d0                	call   *%eax
}
c01063b3:	89 ec                	mov    %ebp,%esp
c01063b5:	5d                   	pop    %ebp
c01063b6:	c3                   	ret    

c01063b7 <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c01063b7:	55                   	push   %ebp
c01063b8:	89 e5                	mov    %esp,%ebp
c01063ba:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c01063bd:	a1 00 71 12 c0       	mov    0xc0127100,%eax
c01063c2:	8b 40 10             	mov    0x10(%eax),%eax
c01063c5:	8b 55 14             	mov    0x14(%ebp),%edx
c01063c8:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01063cc:	8b 55 10             	mov    0x10(%ebp),%edx
c01063cf:	89 54 24 08          	mov    %edx,0x8(%esp)
c01063d3:	8b 55 0c             	mov    0xc(%ebp),%edx
c01063d6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01063da:	8b 55 08             	mov    0x8(%ebp),%edx
c01063dd:	89 14 24             	mov    %edx,(%esp)
c01063e0:	ff d0                	call   *%eax
}
c01063e2:	89 ec                	mov    %ebp,%esp
c01063e4:	5d                   	pop    %ebp
c01063e5:	c3                   	ret    

c01063e6 <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c01063e6:	55                   	push   %ebp
c01063e7:	89 e5                	mov    %esp,%ebp
c01063e9:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c01063ec:	a1 00 71 12 c0       	mov    0xc0127100,%eax
c01063f1:	8b 40 14             	mov    0x14(%eax),%eax
c01063f4:	8b 55 0c             	mov    0xc(%ebp),%edx
c01063f7:	89 54 24 04          	mov    %edx,0x4(%esp)
c01063fb:	8b 55 08             	mov    0x8(%ebp),%edx
c01063fe:	89 14 24             	mov    %edx,(%esp)
c0106401:	ff d0                	call   *%eax
}
c0106403:	89 ec                	mov    %ebp,%esp
c0106405:	5d                   	pop    %ebp
c0106406:	c3                   	ret    

c0106407 <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c0106407:	55                   	push   %ebp
c0106408:	89 e5                	mov    %esp,%ebp
c010640a:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c010640d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106414:	e9 53 01 00 00       	jmp    c010656c <swap_out+0x165>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c0106419:	a1 00 71 12 c0       	mov    0xc0127100,%eax
c010641e:	8b 40 18             	mov    0x18(%eax),%eax
c0106421:	8b 55 10             	mov    0x10(%ebp),%edx
c0106424:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106428:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c010642b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010642f:	8b 55 08             	mov    0x8(%ebp),%edx
c0106432:	89 14 24             	mov    %edx,(%esp)
c0106435:	ff d0                	call   *%eax
c0106437:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c010643a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010643e:	74 18                	je     c0106458 <swap_out+0x51>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c0106440:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106443:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106447:	c7 04 24 80 a5 10 c0 	movl   $0xc010a580,(%esp)
c010644e:	e8 12 9f ff ff       	call   c0100365 <cprintf>
c0106453:	e9 20 01 00 00       	jmp    c0106578 <swap_out+0x171>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c0106458:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010645b:	8b 40 1c             	mov    0x1c(%eax),%eax
c010645e:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c0106461:	8b 45 08             	mov    0x8(%ebp),%eax
c0106464:	8b 40 0c             	mov    0xc(%eax),%eax
c0106467:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010646e:	00 
c010646f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106472:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106476:	89 04 24             	mov    %eax,(%esp)
c0106479:	e8 78 eb ff ff       	call   c0104ff6 <get_pte>
c010647e:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c0106481:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106484:	8b 00                	mov    (%eax),%eax
c0106486:	83 e0 01             	and    $0x1,%eax
c0106489:	85 c0                	test   %eax,%eax
c010648b:	75 24                	jne    c01064b1 <swap_out+0xaa>
c010648d:	c7 44 24 0c ad a5 10 	movl   $0xc010a5ad,0xc(%esp)
c0106494:	c0 
c0106495:	c7 44 24 08 c2 a5 10 	movl   $0xc010a5c2,0x8(%esp)
c010649c:	c0 
c010649d:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c01064a4:	00 
c01064a5:	c7 04 24 5c a5 10 c0 	movl   $0xc010a55c,(%esp)
c01064ac:	e8 5d a8 ff ff       	call   c0100d0e <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c01064b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01064b4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01064b7:	8b 52 1c             	mov    0x1c(%edx),%edx
c01064ba:	c1 ea 0c             	shr    $0xc,%edx
c01064bd:	42                   	inc    %edx
c01064be:	c1 e2 08             	shl    $0x8,%edx
c01064c1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01064c5:	89 14 24             	mov    %edx,(%esp)
c01064c8:	e8 2e 20 00 00       	call   c01084fb <swapfs_write>
c01064cd:	85 c0                	test   %eax,%eax
c01064cf:	74 34                	je     c0106505 <swap_out+0xfe>
                    cprintf("SWAP: failed to save\n");
c01064d1:	c7 04 24 d7 a5 10 c0 	movl   $0xc010a5d7,(%esp)
c01064d8:	e8 88 9e ff ff       	call   c0100365 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c01064dd:	a1 00 71 12 c0       	mov    0xc0127100,%eax
c01064e2:	8b 40 10             	mov    0x10(%eax),%eax
c01064e5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01064e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01064ef:	00 
c01064f0:	89 54 24 08          	mov    %edx,0x8(%esp)
c01064f4:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01064f7:	89 54 24 04          	mov    %edx,0x4(%esp)
c01064fb:	8b 55 08             	mov    0x8(%ebp),%edx
c01064fe:	89 14 24             	mov    %edx,(%esp)
c0106501:	ff d0                	call   *%eax
c0106503:	eb 64                	jmp    c0106569 <swap_out+0x162>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c0106505:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106508:	8b 40 1c             	mov    0x1c(%eax),%eax
c010650b:	c1 e8 0c             	shr    $0xc,%eax
c010650e:	40                   	inc    %eax
c010650f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106513:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106516:	89 44 24 08          	mov    %eax,0x8(%esp)
c010651a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010651d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106521:	c7 04 24 f0 a5 10 c0 	movl   $0xc010a5f0,(%esp)
c0106528:	e8 38 9e ff ff       	call   c0100365 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c010652d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106530:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106533:	c1 e8 0c             	shr    $0xc,%eax
c0106536:	40                   	inc    %eax
c0106537:	c1 e0 08             	shl    $0x8,%eax
c010653a:	89 c2                	mov    %eax,%edx
c010653c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010653f:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c0106541:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106544:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010654b:	00 
c010654c:	89 04 24             	mov    %eax,(%esp)
c010654f:	e8 59 e4 ff ff       	call   c01049ad <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c0106554:	8b 45 08             	mov    0x8(%ebp),%eax
c0106557:	8b 40 0c             	mov    0xc(%eax),%eax
c010655a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010655d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106561:	89 04 24             	mov    %eax,(%esp)
c0106564:	e8 ed ed ff ff       	call   c0105356 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
c0106569:	ff 45 f4             	incl   -0xc(%ebp)
c010656c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010656f:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106572:	0f 85 a1 fe ff ff    	jne    c0106419 <swap_out+0x12>
     }
     return i;
c0106578:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010657b:	89 ec                	mov    %ebp,%esp
c010657d:	5d                   	pop    %ebp
c010657e:	c3                   	ret    

c010657f <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c010657f:	55                   	push   %ebp
c0106580:	89 e5                	mov    %esp,%ebp
c0106582:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c0106585:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010658c:	e8 af e3 ff ff       	call   c0104940 <alloc_pages>
c0106591:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c0106594:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106598:	75 24                	jne    c01065be <swap_in+0x3f>
c010659a:	c7 44 24 0c 30 a6 10 	movl   $0xc010a630,0xc(%esp)
c01065a1:	c0 
c01065a2:	c7 44 24 08 c2 a5 10 	movl   $0xc010a5c2,0x8(%esp)
c01065a9:	c0 
c01065aa:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c01065b1:	00 
c01065b2:	c7 04 24 5c a5 10 c0 	movl   $0xc010a55c,(%esp)
c01065b9:	e8 50 a7 ff ff       	call   c0100d0e <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c01065be:	8b 45 08             	mov    0x8(%ebp),%eax
c01065c1:	8b 40 0c             	mov    0xc(%eax),%eax
c01065c4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01065cb:	00 
c01065cc:	8b 55 0c             	mov    0xc(%ebp),%edx
c01065cf:	89 54 24 04          	mov    %edx,0x4(%esp)
c01065d3:	89 04 24             	mov    %eax,(%esp)
c01065d6:	e8 1b ea ff ff       	call   c0104ff6 <get_pte>
c01065db:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c01065de:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01065e1:	8b 00                	mov    (%eax),%eax
c01065e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01065e6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01065ea:	89 04 24             	mov    %eax,(%esp)
c01065ed:	e8 95 1e 00 00       	call   c0108487 <swapfs_read>
c01065f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01065f5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01065f9:	74 2a                	je     c0106625 <swap_in+0xa6>
     {
        assert(r!=0);
c01065fb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01065ff:	75 24                	jne    c0106625 <swap_in+0xa6>
c0106601:	c7 44 24 0c 3d a6 10 	movl   $0xc010a63d,0xc(%esp)
c0106608:	c0 
c0106609:	c7 44 24 08 c2 a5 10 	movl   $0xc010a5c2,0x8(%esp)
c0106610:	c0 
c0106611:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
c0106618:	00 
c0106619:	c7 04 24 5c a5 10 c0 	movl   $0xc010a55c,(%esp)
c0106620:	e8 e9 a6 ff ff       	call   c0100d0e <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c0106625:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106628:	8b 00                	mov    (%eax),%eax
c010662a:	c1 e8 08             	shr    $0x8,%eax
c010662d:	89 c2                	mov    %eax,%edx
c010662f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106632:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106636:	89 54 24 04          	mov    %edx,0x4(%esp)
c010663a:	c7 04 24 44 a6 10 c0 	movl   $0xc010a644,(%esp)
c0106641:	e8 1f 9d ff ff       	call   c0100365 <cprintf>
     *ptr_result=result;
c0106646:	8b 45 10             	mov    0x10(%ebp),%eax
c0106649:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010664c:	89 10                	mov    %edx,(%eax)
     return 0;
c010664e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106653:	89 ec                	mov    %ebp,%esp
c0106655:	5d                   	pop    %ebp
c0106656:	c3                   	ret    

c0106657 <visit>:

static void visit(struct mm_struct *mm,uintptr_t addr,int value){
c0106657:	55                   	push   %ebp
c0106658:	89 e5                	mov    %esp,%ebp
c010665a:	83 ec 28             	sub    $0x28,%esp
    *(unsigned char*) addr = value;
c010665d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106660:	8b 55 10             	mov    0x10(%ebp),%edx
c0106663:	88 10                	mov    %dl,(%eax)
    //从虚拟地址获取pte
    uintptr_t *pte = get_pte(mm->pgdir,addr,0);
c0106665:	8b 45 08             	mov    0x8(%ebp),%eax
c0106668:	8b 40 0c             	mov    0xc(%eax),%eax
c010666b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106672:	00 
c0106673:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106676:	89 54 24 04          	mov    %edx,0x4(%esp)
c010667a:	89 04 24             	mov    %eax,(%esp)
c010667d:	e8 74 e9 ff ff       	call   c0104ff6 <get_pte>
c0106682:	89 45 f4             	mov    %eax,-0xc(%ebp)
    //之后我们将访问位，以及direty位置1
    if(pte!=NULL)
c0106685:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106689:	74 1e                	je     c01066a9 <visit+0x52>
    {
    *pte |=PTE_A ;
c010668b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010668e:	8b 00                	mov    (%eax),%eax
c0106690:	83 c8 20             	or     $0x20,%eax
c0106693:	89 c2                	mov    %eax,%edx
c0106695:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106698:	89 10                	mov    %edx,(%eax)
    *pte |=PTE_D;
c010669a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010669d:	8b 00                	mov    (%eax),%eax
c010669f:	83 c8 40             	or     $0x40,%eax
c01066a2:	89 c2                	mov    %eax,%edx
c01066a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01066a7:	89 10                	mov    %edx,(%eax)
    }
   
}
c01066a9:	90                   	nop
c01066aa:	89 ec                	mov    %ebp,%esp
c01066ac:	5d                   	pop    %ebp
c01066ad:	c3                   	ret    

c01066ae <check_content_set>:



static inline void
check_content_set(struct mm_struct *mm)
{
c01066ae:	55                   	push   %ebp
c01066af:	89 e5                	mov    %esp,%ebp
c01066b1:	83 ec 18             	sub    $0x18,%esp
     //*(unsigned char *)0x1000 = 0x0a;
     visit(mm,0x1000,0x0a);
c01066b4:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
c01066bb:	00 
c01066bc:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01066c3:	00 
c01066c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01066c7:	89 04 24             	mov    %eax,(%esp)
c01066ca:	e8 88 ff ff ff       	call   c0106657 <visit>
     assert(pgfault_num==1);
c01066cf:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c01066d4:	83 f8 01             	cmp    $0x1,%eax
c01066d7:	74 24                	je     c01066fd <check_content_set+0x4f>
c01066d9:	c7 44 24 0c 82 a6 10 	movl   $0xc010a682,0xc(%esp)
c01066e0:	c0 
c01066e1:	c7 44 24 08 c2 a5 10 	movl   $0xc010a5c2,0x8(%esp)
c01066e8:	c0 
c01066e9:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c01066f0:	00 
c01066f1:	c7 04 24 5c a5 10 c0 	movl   $0xc010a55c,(%esp)
c01066f8:	e8 11 a6 ff ff       	call   c0100d0e <__panic>
     //*(unsigned char *)0x1010 = 0x0a;
     visit(mm,0x1010,0x0a);
c01066fd:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
c0106704:	00 
c0106705:	c7 44 24 04 10 10 00 	movl   $0x1010,0x4(%esp)
c010670c:	00 
c010670d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106710:	89 04 24             	mov    %eax,(%esp)
c0106713:	e8 3f ff ff ff       	call   c0106657 <visit>
     assert(pgfault_num==1);
c0106718:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c010671d:	83 f8 01             	cmp    $0x1,%eax
c0106720:	74 24                	je     c0106746 <check_content_set+0x98>
c0106722:	c7 44 24 0c 82 a6 10 	movl   $0xc010a682,0xc(%esp)
c0106729:	c0 
c010672a:	c7 44 24 08 c2 a5 10 	movl   $0xc010a5c2,0x8(%esp)
c0106731:	c0 
c0106732:	c7 44 24 04 a3 00 00 	movl   $0xa3,0x4(%esp)
c0106739:	00 
c010673a:	c7 04 24 5c a5 10 c0 	movl   $0xc010a55c,(%esp)
c0106741:	e8 c8 a5 ff ff       	call   c0100d0e <__panic>
     //*(unsigned char *)0x2000 = 0x0b;
     visit(mm,0x2000,0x0b);
c0106746:	c7 44 24 08 0b 00 00 	movl   $0xb,0x8(%esp)
c010674d:	00 
c010674e:	c7 44 24 04 00 20 00 	movl   $0x2000,0x4(%esp)
c0106755:	00 
c0106756:	8b 45 08             	mov    0x8(%ebp),%eax
c0106759:	89 04 24             	mov    %eax,(%esp)
c010675c:	e8 f6 fe ff ff       	call   c0106657 <visit>
     assert(pgfault_num==2);
c0106761:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c0106766:	83 f8 02             	cmp    $0x2,%eax
c0106769:	74 24                	je     c010678f <check_content_set+0xe1>
c010676b:	c7 44 24 0c 91 a6 10 	movl   $0xc010a691,0xc(%esp)
c0106772:	c0 
c0106773:	c7 44 24 08 c2 a5 10 	movl   $0xc010a5c2,0x8(%esp)
c010677a:	c0 
c010677b:	c7 44 24 04 a6 00 00 	movl   $0xa6,0x4(%esp)
c0106782:	00 
c0106783:	c7 04 24 5c a5 10 c0 	movl   $0xc010a55c,(%esp)
c010678a:	e8 7f a5 ff ff       	call   c0100d0e <__panic>
     //*(unsigned char *)0x2010 = 0x0b;
     visit(mm,0x2010,0x0b);
c010678f:	c7 44 24 08 0b 00 00 	movl   $0xb,0x8(%esp)
c0106796:	00 
c0106797:	c7 44 24 04 10 20 00 	movl   $0x2010,0x4(%esp)
c010679e:	00 
c010679f:	8b 45 08             	mov    0x8(%ebp),%eax
c01067a2:	89 04 24             	mov    %eax,(%esp)
c01067a5:	e8 ad fe ff ff       	call   c0106657 <visit>
     assert(pgfault_num==2);
c01067aa:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c01067af:	83 f8 02             	cmp    $0x2,%eax
c01067b2:	74 24                	je     c01067d8 <check_content_set+0x12a>
c01067b4:	c7 44 24 0c 91 a6 10 	movl   $0xc010a691,0xc(%esp)
c01067bb:	c0 
c01067bc:	c7 44 24 08 c2 a5 10 	movl   $0xc010a5c2,0x8(%esp)
c01067c3:	c0 
c01067c4:	c7 44 24 04 a9 00 00 	movl   $0xa9,0x4(%esp)
c01067cb:	00 
c01067cc:	c7 04 24 5c a5 10 c0 	movl   $0xc010a55c,(%esp)
c01067d3:	e8 36 a5 ff ff       	call   c0100d0e <__panic>
     //*(unsigned char *)0x3000 = 0x0c;
     visit(mm,0x3000,0x0c);
c01067d8:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
c01067df:	00 
c01067e0:	c7 44 24 04 00 30 00 	movl   $0x3000,0x4(%esp)
c01067e7:	00 
c01067e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01067eb:	89 04 24             	mov    %eax,(%esp)
c01067ee:	e8 64 fe ff ff       	call   c0106657 <visit>
     assert(pgfault_num==3);
c01067f3:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c01067f8:	83 f8 03             	cmp    $0x3,%eax
c01067fb:	74 24                	je     c0106821 <check_content_set+0x173>
c01067fd:	c7 44 24 0c a0 a6 10 	movl   $0xc010a6a0,0xc(%esp)
c0106804:	c0 
c0106805:	c7 44 24 08 c2 a5 10 	movl   $0xc010a5c2,0x8(%esp)
c010680c:	c0 
c010680d:	c7 44 24 04 ac 00 00 	movl   $0xac,0x4(%esp)
c0106814:	00 
c0106815:	c7 04 24 5c a5 10 c0 	movl   $0xc010a55c,(%esp)
c010681c:	e8 ed a4 ff ff       	call   c0100d0e <__panic>
     //*(unsigned char *)0x3010 = 0x0c;
     visit(mm,0x3010,0x0c);
c0106821:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
c0106828:	00 
c0106829:	c7 44 24 04 10 30 00 	movl   $0x3010,0x4(%esp)
c0106830:	00 
c0106831:	8b 45 08             	mov    0x8(%ebp),%eax
c0106834:	89 04 24             	mov    %eax,(%esp)
c0106837:	e8 1b fe ff ff       	call   c0106657 <visit>
     assert(pgfault_num==3);
c010683c:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c0106841:	83 f8 03             	cmp    $0x3,%eax
c0106844:	74 24                	je     c010686a <check_content_set+0x1bc>
c0106846:	c7 44 24 0c a0 a6 10 	movl   $0xc010a6a0,0xc(%esp)
c010684d:	c0 
c010684e:	c7 44 24 08 c2 a5 10 	movl   $0xc010a5c2,0x8(%esp)
c0106855:	c0 
c0106856:	c7 44 24 04 af 00 00 	movl   $0xaf,0x4(%esp)
c010685d:	00 
c010685e:	c7 04 24 5c a5 10 c0 	movl   $0xc010a55c,(%esp)
c0106865:	e8 a4 a4 ff ff       	call   c0100d0e <__panic>
     //*(unsigned char *)0x4000 = 0x0d;
     visit(mm,0x4000,0x0d);
c010686a:	c7 44 24 08 0d 00 00 	movl   $0xd,0x8(%esp)
c0106871:	00 
c0106872:	c7 44 24 04 00 40 00 	movl   $0x4000,0x4(%esp)
c0106879:	00 
c010687a:	8b 45 08             	mov    0x8(%ebp),%eax
c010687d:	89 04 24             	mov    %eax,(%esp)
c0106880:	e8 d2 fd ff ff       	call   c0106657 <visit>
     assert(pgfault_num==4);
c0106885:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c010688a:	83 f8 04             	cmp    $0x4,%eax
c010688d:	74 24                	je     c01068b3 <check_content_set+0x205>
c010688f:	c7 44 24 0c af a6 10 	movl   $0xc010a6af,0xc(%esp)
c0106896:	c0 
c0106897:	c7 44 24 08 c2 a5 10 	movl   $0xc010a5c2,0x8(%esp)
c010689e:	c0 
c010689f:	c7 44 24 04 b2 00 00 	movl   $0xb2,0x4(%esp)
c01068a6:	00 
c01068a7:	c7 04 24 5c a5 10 c0 	movl   $0xc010a55c,(%esp)
c01068ae:	e8 5b a4 ff ff       	call   c0100d0e <__panic>
     //*(unsigned char *)0x4010 = 0x0d;
     visit(mm,0x4010,0x0d);
c01068b3:	c7 44 24 08 0d 00 00 	movl   $0xd,0x8(%esp)
c01068ba:	00 
c01068bb:	c7 44 24 04 10 40 00 	movl   $0x4010,0x4(%esp)
c01068c2:	00 
c01068c3:	8b 45 08             	mov    0x8(%ebp),%eax
c01068c6:	89 04 24             	mov    %eax,(%esp)
c01068c9:	e8 89 fd ff ff       	call   c0106657 <visit>
     assert(pgfault_num==4);
c01068ce:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c01068d3:	83 f8 04             	cmp    $0x4,%eax
c01068d6:	74 24                	je     c01068fc <check_content_set+0x24e>
c01068d8:	c7 44 24 0c af a6 10 	movl   $0xc010a6af,0xc(%esp)
c01068df:	c0 
c01068e0:	c7 44 24 08 c2 a5 10 	movl   $0xc010a5c2,0x8(%esp)
c01068e7:	c0 
c01068e8:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
c01068ef:	00 
c01068f0:	c7 04 24 5c a5 10 c0 	movl   $0xc010a55c,(%esp)
c01068f7:	e8 12 a4 ff ff       	call   c0100d0e <__panic>
}
c01068fc:	90                   	nop
c01068fd:	89 ec                	mov    %ebp,%esp
c01068ff:	5d                   	pop    %ebp
c0106900:	c3                   	ret    

c0106901 <check_content_access>:

static inline int
check_content_access(struct mm_struct *mm)
{
c0106901:	55                   	push   %ebp
c0106902:	89 e5                	mov    %esp,%ebp
c0106904:	83 ec 28             	sub    $0x28,%esp
    int ret = sm->check_swap(mm);
c0106907:	a1 00 71 12 c0       	mov    0xc0127100,%eax
c010690c:	8b 40 1c             	mov    0x1c(%eax),%eax
c010690f:	8b 55 08             	mov    0x8(%ebp),%edx
c0106912:	89 14 24             	mov    %edx,(%esp)
c0106915:	ff d0                	call   *%eax
c0106917:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c010691a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010691d:	89 ec                	mov    %ebp,%esp
c010691f:	5d                   	pop    %ebp
c0106920:	c3                   	ret    

c0106921 <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c0106921:	55                   	push   %ebp
c0106922:	89 e5                	mov    %esp,%ebp
c0106924:	83 ec 78             	sub    $0x78,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c0106927:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010692e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c0106935:	c7 45 e8 84 6f 12 c0 	movl   $0xc0126f84,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c010693c:	eb 6a                	jmp    c01069a8 <check_swap+0x87>
        struct Page *p = le2page(le, page_link);
c010693e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106941:	83 e8 0c             	sub    $0xc,%eax
c0106944:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(PageProperty(p));
c0106947:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010694a:	83 c0 04             	add    $0x4,%eax
c010694d:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0106954:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106957:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010695a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010695d:	0f a3 10             	bt     %edx,(%eax)
c0106960:	19 c0                	sbb    %eax,%eax
c0106962:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c0106965:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0106969:	0f 95 c0             	setne  %al
c010696c:	0f b6 c0             	movzbl %al,%eax
c010696f:	85 c0                	test   %eax,%eax
c0106971:	75 24                	jne    c0106997 <check_swap+0x76>
c0106973:	c7 44 24 0c be a6 10 	movl   $0xc010a6be,0xc(%esp)
c010697a:	c0 
c010697b:	c7 44 24 08 c2 a5 10 	movl   $0xc010a5c2,0x8(%esp)
c0106982:	c0 
c0106983:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c010698a:	00 
c010698b:	c7 04 24 5c a5 10 c0 	movl   $0xc010a55c,(%esp)
c0106992:	e8 77 a3 ff ff       	call   c0100d0e <__panic>
        count ++, total += p->property;
c0106997:	ff 45 f4             	incl   -0xc(%ebp)
c010699a:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010699d:	8b 50 08             	mov    0x8(%eax),%edx
c01069a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01069a3:	01 d0                	add    %edx,%eax
c01069a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01069a8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01069ab:	89 45 b8             	mov    %eax,-0x48(%ebp)
c01069ae:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01069b1:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c01069b4:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01069b7:	81 7d e8 84 6f 12 c0 	cmpl   $0xc0126f84,-0x18(%ebp)
c01069be:	0f 85 7a ff ff ff    	jne    c010693e <check_swap+0x1d>
     }
     assert(total == nr_free_pages());
c01069c4:	e8 19 e0 ff ff       	call   c01049e2 <nr_free_pages>
c01069c9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01069cc:	39 d0                	cmp    %edx,%eax
c01069ce:	74 24                	je     c01069f4 <check_swap+0xd3>
c01069d0:	c7 44 24 0c ce a6 10 	movl   $0xc010a6ce,0xc(%esp)
c01069d7:	c0 
c01069d8:	c7 44 24 08 c2 a5 10 	movl   $0xc010a5c2,0x8(%esp)
c01069df:	c0 
c01069e0:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c01069e7:	00 
c01069e8:	c7 04 24 5c a5 10 c0 	movl   $0xc010a55c,(%esp)
c01069ef:	e8 1a a3 ff ff       	call   c0100d0e <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c01069f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01069f7:	89 44 24 08          	mov    %eax,0x8(%esp)
c01069fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01069fe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106a02:	c7 04 24 e8 a6 10 c0 	movl   $0xc010a6e8,(%esp)
c0106a09:	e8 57 99 ff ff       	call   c0100365 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c0106a0e:	e8 56 0c 00 00       	call   c0107669 <mm_create>
c0106a13:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     assert(mm != NULL);
c0106a16:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106a1a:	75 24                	jne    c0106a40 <check_swap+0x11f>
c0106a1c:	c7 44 24 0c 0e a7 10 	movl   $0xc010a70e,0xc(%esp)
c0106a23:	c0 
c0106a24:	c7 44 24 08 c2 a5 10 	movl   $0xc010a5c2,0x8(%esp)
c0106a2b:	c0 
c0106a2c:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
c0106a33:	00 
c0106a34:	c7 04 24 5c a5 10 c0 	movl   $0xc010a55c,(%esp)
c0106a3b:	e8 ce a2 ff ff       	call   c0100d0e <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c0106a40:	a1 0c 71 12 c0       	mov    0xc012710c,%eax
c0106a45:	85 c0                	test   %eax,%eax
c0106a47:	74 24                	je     c0106a6d <check_swap+0x14c>
c0106a49:	c7 44 24 0c 19 a7 10 	movl   $0xc010a719,0xc(%esp)
c0106a50:	c0 
c0106a51:	c7 44 24 08 c2 a5 10 	movl   $0xc010a5c2,0x8(%esp)
c0106a58:	c0 
c0106a59:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c0106a60:	00 
c0106a61:	c7 04 24 5c a5 10 c0 	movl   $0xc010a55c,(%esp)
c0106a68:	e8 a1 a2 ff ff       	call   c0100d0e <__panic>

     check_mm_struct = mm;
c0106a6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106a70:	a3 0c 71 12 c0       	mov    %eax,0xc012710c

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c0106a75:	8b 15 e0 39 12 c0    	mov    0xc01239e0,%edx
c0106a7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106a7e:	89 50 0c             	mov    %edx,0xc(%eax)
c0106a81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106a84:	8b 40 0c             	mov    0xc(%eax),%eax
c0106a87:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(pgdir[0] == 0);
c0106a8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106a8d:	8b 00                	mov    (%eax),%eax
c0106a8f:	85 c0                	test   %eax,%eax
c0106a91:	74 24                	je     c0106ab7 <check_swap+0x196>
c0106a93:	c7 44 24 0c 31 a7 10 	movl   $0xc010a731,0xc(%esp)
c0106a9a:	c0 
c0106a9b:	c7 44 24 08 c2 a5 10 	movl   $0xc010a5c2,0x8(%esp)
c0106aa2:	c0 
c0106aa3:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c0106aaa:	00 
c0106aab:	c7 04 24 5c a5 10 c0 	movl   $0xc010a55c,(%esp)
c0106ab2:	e8 57 a2 ff ff       	call   c0100d0e <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c0106ab7:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c0106abe:	00 
c0106abf:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c0106ac6:	00 
c0106ac7:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c0106ace:	e8 11 0c 00 00       	call   c01076e4 <vma_create>
c0106ad3:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(vma != NULL);
c0106ad6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0106ada:	75 24                	jne    c0106b00 <check_swap+0x1df>
c0106adc:	c7 44 24 0c 3f a7 10 	movl   $0xc010a73f,0xc(%esp)
c0106ae3:	c0 
c0106ae4:	c7 44 24 08 c2 a5 10 	movl   $0xc010a5c2,0x8(%esp)
c0106aeb:	c0 
c0106aec:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c0106af3:	00 
c0106af4:	c7 04 24 5c a5 10 c0 	movl   $0xc010a55c,(%esp)
c0106afb:	e8 0e a2 ff ff       	call   c0100d0e <__panic>

     insert_vma_struct(mm, vma);
c0106b00:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106b03:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106b0a:	89 04 24             	mov    %eax,(%esp)
c0106b0d:	e8 69 0d 00 00       	call   c010787b <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c0106b12:	c7 04 24 4c a7 10 c0 	movl   $0xc010a74c,(%esp)
c0106b19:	e8 47 98 ff ff       	call   c0100365 <cprintf>
     pte_t *temp_ptep=NULL;
c0106b1e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c0106b25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106b28:	8b 40 0c             	mov    0xc(%eax),%eax
c0106b2b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0106b32:	00 
c0106b33:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0106b3a:	00 
c0106b3b:	89 04 24             	mov    %eax,(%esp)
c0106b3e:	e8 b3 e4 ff ff       	call   c0104ff6 <get_pte>
c0106b43:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(temp_ptep!= NULL);
c0106b46:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0106b4a:	75 24                	jne    c0106b70 <check_swap+0x24f>
c0106b4c:	c7 44 24 0c 80 a7 10 	movl   $0xc010a780,0xc(%esp)
c0106b53:	c0 
c0106b54:	c7 44 24 08 c2 a5 10 	movl   $0xc010a5c2,0x8(%esp)
c0106b5b:	c0 
c0106b5c:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
c0106b63:	00 
c0106b64:	c7 04 24 5c a5 10 c0 	movl   $0xc010a55c,(%esp)
c0106b6b:	e8 9e a1 ff ff       	call   c0100d0e <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c0106b70:	c7 04 24 94 a7 10 c0 	movl   $0xc010a794,(%esp)
c0106b77:	e8 e9 97 ff ff       	call   c0100365 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106b7c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106b83:	e9 a2 00 00 00       	jmp    c0106c2a <check_swap+0x309>
          check_rp[i] = alloc_page();
c0106b88:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106b8f:	e8 ac dd ff ff       	call   c0104940 <alloc_pages>
c0106b94:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106b97:	89 04 95 cc 70 12 c0 	mov    %eax,-0x3fed8f34(,%edx,4)
          assert(check_rp[i] != NULL );
c0106b9e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106ba1:	8b 04 85 cc 70 12 c0 	mov    -0x3fed8f34(,%eax,4),%eax
c0106ba8:	85 c0                	test   %eax,%eax
c0106baa:	75 24                	jne    c0106bd0 <check_swap+0x2af>
c0106bac:	c7 44 24 0c b8 a7 10 	movl   $0xc010a7b8,0xc(%esp)
c0106bb3:	c0 
c0106bb4:	c7 44 24 08 c2 a5 10 	movl   $0xc010a5c2,0x8(%esp)
c0106bbb:	c0 
c0106bbc:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c0106bc3:	00 
c0106bc4:	c7 04 24 5c a5 10 c0 	movl   $0xc010a55c,(%esp)
c0106bcb:	e8 3e a1 ff ff       	call   c0100d0e <__panic>
          assert(!PageProperty(check_rp[i]));
c0106bd0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106bd3:	8b 04 85 cc 70 12 c0 	mov    -0x3fed8f34(,%eax,4),%eax
c0106bda:	83 c0 04             	add    $0x4,%eax
c0106bdd:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c0106be4:	89 45 b0             	mov    %eax,-0x50(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106be7:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0106bea:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0106bed:	0f a3 10             	bt     %edx,(%eax)
c0106bf0:	19 c0                	sbb    %eax,%eax
c0106bf2:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c0106bf5:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c0106bf9:	0f 95 c0             	setne  %al
c0106bfc:	0f b6 c0             	movzbl %al,%eax
c0106bff:	85 c0                	test   %eax,%eax
c0106c01:	74 24                	je     c0106c27 <check_swap+0x306>
c0106c03:	c7 44 24 0c cc a7 10 	movl   $0xc010a7cc,0xc(%esp)
c0106c0a:	c0 
c0106c0b:	c7 44 24 08 c2 a5 10 	movl   $0xc010a5c2,0x8(%esp)
c0106c12:	c0 
c0106c13:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
c0106c1a:	00 
c0106c1b:	c7 04 24 5c a5 10 c0 	movl   $0xc010a55c,(%esp)
c0106c22:	e8 e7 a0 ff ff       	call   c0100d0e <__panic>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106c27:	ff 45 ec             	incl   -0x14(%ebp)
c0106c2a:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106c2e:	0f 8e 54 ff ff ff    	jle    c0106b88 <check_swap+0x267>
     }
     list_entry_t free_list_store = free_list;
c0106c34:	a1 84 6f 12 c0       	mov    0xc0126f84,%eax
c0106c39:	8b 15 88 6f 12 c0    	mov    0xc0126f88,%edx
c0106c3f:	89 45 98             	mov    %eax,-0x68(%ebp)
c0106c42:	89 55 9c             	mov    %edx,-0x64(%ebp)
c0106c45:	c7 45 a4 84 6f 12 c0 	movl   $0xc0126f84,-0x5c(%ebp)
    elm->prev = elm->next = elm;
c0106c4c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106c4f:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0106c52:	89 50 04             	mov    %edx,0x4(%eax)
c0106c55:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106c58:	8b 50 04             	mov    0x4(%eax),%edx
c0106c5b:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106c5e:	89 10                	mov    %edx,(%eax)
}
c0106c60:	90                   	nop
c0106c61:	c7 45 a8 84 6f 12 c0 	movl   $0xc0126f84,-0x58(%ebp)
    return list->next == list;
c0106c68:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0106c6b:	8b 40 04             	mov    0x4(%eax),%eax
c0106c6e:	39 45 a8             	cmp    %eax,-0x58(%ebp)
c0106c71:	0f 94 c0             	sete   %al
c0106c74:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c0106c77:	85 c0                	test   %eax,%eax
c0106c79:	75 24                	jne    c0106c9f <check_swap+0x37e>
c0106c7b:	c7 44 24 0c e7 a7 10 	movl   $0xc010a7e7,0xc(%esp)
c0106c82:	c0 
c0106c83:	c7 44 24 08 c2 a5 10 	movl   $0xc010a5c2,0x8(%esp)
c0106c8a:	c0 
c0106c8b:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
c0106c92:	00 
c0106c93:	c7 04 24 5c a5 10 c0 	movl   $0xc010a55c,(%esp)
c0106c9a:	e8 6f a0 ff ff       	call   c0100d0e <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c0106c9f:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
c0106ca4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     nr_free = 0;
c0106ca7:	c7 05 8c 6f 12 c0 00 	movl   $0x0,0xc0126f8c
c0106cae:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106cb1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106cb8:	eb 1d                	jmp    c0106cd7 <check_swap+0x3b6>
        free_pages(check_rp[i],1);
c0106cba:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106cbd:	8b 04 85 cc 70 12 c0 	mov    -0x3fed8f34(,%eax,4),%eax
c0106cc4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106ccb:	00 
c0106ccc:	89 04 24             	mov    %eax,(%esp)
c0106ccf:	e8 d9 dc ff ff       	call   c01049ad <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106cd4:	ff 45 ec             	incl   -0x14(%ebp)
c0106cd7:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106cdb:	7e dd                	jle    c0106cba <check_swap+0x399>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c0106cdd:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
c0106ce2:	83 f8 04             	cmp    $0x4,%eax
c0106ce5:	74 24                	je     c0106d0b <check_swap+0x3ea>
c0106ce7:	c7 44 24 0c 00 a8 10 	movl   $0xc010a800,0xc(%esp)
c0106cee:	c0 
c0106cef:	c7 44 24 08 c2 a5 10 	movl   $0xc010a5c2,0x8(%esp)
c0106cf6:	c0 
c0106cf7:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
c0106cfe:	00 
c0106cff:	c7 04 24 5c a5 10 c0 	movl   $0xc010a55c,(%esp)
c0106d06:	e8 03 a0 ff ff       	call   c0100d0e <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c0106d0b:	c7 04 24 24 a8 10 c0 	movl   $0xc010a824,(%esp)
c0106d12:	e8 4e 96 ff ff       	call   c0100365 <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c0106d17:	c7 05 10 71 12 c0 00 	movl   $0x0,0xc0127110
c0106d1e:	00 00 00 
     
     check_content_set(mm);
c0106d21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106d24:	89 04 24             	mov    %eax,(%esp)
c0106d27:	e8 82 f9 ff ff       	call   c01066ae <check_content_set>
     assert( nr_free == 0);         
c0106d2c:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
c0106d31:	85 c0                	test   %eax,%eax
c0106d33:	74 24                	je     c0106d59 <check_swap+0x438>
c0106d35:	c7 44 24 0c 4b a8 10 	movl   $0xc010a84b,0xc(%esp)
c0106d3c:	c0 
c0106d3d:	c7 44 24 08 c2 a5 10 	movl   $0xc010a5c2,0x8(%esp)
c0106d44:	c0 
c0106d45:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
c0106d4c:	00 
c0106d4d:	c7 04 24 5c a5 10 c0 	movl   $0xc010a55c,(%esp)
c0106d54:	e8 b5 9f ff ff       	call   c0100d0e <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0106d59:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106d60:	eb 25                	jmp    c0106d87 <check_swap+0x466>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c0106d62:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106d65:	c7 04 85 60 70 12 c0 	movl   $0xffffffff,-0x3fed8fa0(,%eax,4)
c0106d6c:	ff ff ff ff 
c0106d70:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106d73:	8b 14 85 60 70 12 c0 	mov    -0x3fed8fa0(,%eax,4),%edx
c0106d7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106d7d:	89 14 85 a0 70 12 c0 	mov    %edx,-0x3fed8f60(,%eax,4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0106d84:	ff 45 ec             	incl   -0x14(%ebp)
c0106d87:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c0106d8b:	7e d5                	jle    c0106d62 <check_swap+0x441>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106d8d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106d94:	e9 e8 00 00 00       	jmp    c0106e81 <check_swap+0x560>
         check_ptep[i]=0;
c0106d99:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106d9c:	c7 04 85 dc 70 12 c0 	movl   $0x0,-0x3fed8f24(,%eax,4)
c0106da3:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c0106da7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106daa:	40                   	inc    %eax
c0106dab:	c1 e0 0c             	shl    $0xc,%eax
c0106dae:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106db5:	00 
c0106db6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106dba:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106dbd:	89 04 24             	mov    %eax,(%esp)
c0106dc0:	e8 31 e2 ff ff       	call   c0104ff6 <get_pte>
c0106dc5:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106dc8:	89 04 95 dc 70 12 c0 	mov    %eax,-0x3fed8f24(,%edx,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c0106dcf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106dd2:	8b 04 85 dc 70 12 c0 	mov    -0x3fed8f24(,%eax,4),%eax
c0106dd9:	85 c0                	test   %eax,%eax
c0106ddb:	75 24                	jne    c0106e01 <check_swap+0x4e0>
c0106ddd:	c7 44 24 0c 58 a8 10 	movl   $0xc010a858,0xc(%esp)
c0106de4:	c0 
c0106de5:	c7 44 24 08 c2 a5 10 	movl   $0xc010a5c2,0x8(%esp)
c0106dec:	c0 
c0106ded:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
c0106df4:	00 
c0106df5:	c7 04 24 5c a5 10 c0 	movl   $0xc010a55c,(%esp)
c0106dfc:	e8 0d 9f ff ff       	call   c0100d0e <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c0106e01:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106e04:	8b 04 85 dc 70 12 c0 	mov    -0x3fed8f24(,%eax,4),%eax
c0106e0b:	8b 00                	mov    (%eax),%eax
c0106e0d:	89 04 24             	mov    %eax,(%esp)
c0106e10:	e8 9c f4 ff ff       	call   c01062b1 <pte2page>
c0106e15:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106e18:	8b 14 95 cc 70 12 c0 	mov    -0x3fed8f34(,%edx,4),%edx
c0106e1f:	39 d0                	cmp    %edx,%eax
c0106e21:	74 24                	je     c0106e47 <check_swap+0x526>
c0106e23:	c7 44 24 0c 70 a8 10 	movl   $0xc010a870,0xc(%esp)
c0106e2a:	c0 
c0106e2b:	c7 44 24 08 c2 a5 10 	movl   $0xc010a5c2,0x8(%esp)
c0106e32:	c0 
c0106e33:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
c0106e3a:	00 
c0106e3b:	c7 04 24 5c a5 10 c0 	movl   $0xc010a55c,(%esp)
c0106e42:	e8 c7 9e ff ff       	call   c0100d0e <__panic>
         assert((*check_ptep[i] & PTE_P));          
c0106e47:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106e4a:	8b 04 85 dc 70 12 c0 	mov    -0x3fed8f24(,%eax,4),%eax
c0106e51:	8b 00                	mov    (%eax),%eax
c0106e53:	83 e0 01             	and    $0x1,%eax
c0106e56:	85 c0                	test   %eax,%eax
c0106e58:	75 24                	jne    c0106e7e <check_swap+0x55d>
c0106e5a:	c7 44 24 0c 98 a8 10 	movl   $0xc010a898,0xc(%esp)
c0106e61:	c0 
c0106e62:	c7 44 24 08 c2 a5 10 	movl   $0xc010a5c2,0x8(%esp)
c0106e69:	c0 
c0106e6a:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
c0106e71:	00 
c0106e72:	c7 04 24 5c a5 10 c0 	movl   $0xc010a55c,(%esp)
c0106e79:	e8 90 9e ff ff       	call   c0100d0e <__panic>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106e7e:	ff 45 ec             	incl   -0x14(%ebp)
c0106e81:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106e85:	0f 8e 0e ff ff ff    	jle    c0106d99 <check_swap+0x478>
     }
     cprintf("set up init env for check_swap over!\n");
c0106e8b:	c7 04 24 b4 a8 10 c0 	movl   $0xc010a8b4,(%esp)
c0106e92:	e8 ce 94 ff ff       	call   c0100365 <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access(mm);
c0106e97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106e9a:	89 04 24             	mov    %eax,(%esp)
c0106e9d:	e8 5f fa ff ff       	call   c0106901 <check_content_access>
c0106ea2:	89 45 d0             	mov    %eax,-0x30(%ebp)
     assert(ret==0);
c0106ea5:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0106ea9:	74 24                	je     c0106ecf <check_swap+0x5ae>
c0106eab:	c7 44 24 0c da a8 10 	movl   $0xc010a8da,0xc(%esp)
c0106eb2:	c0 
c0106eb3:	c7 44 24 08 c2 a5 10 	movl   $0xc010a5c2,0x8(%esp)
c0106eba:	c0 
c0106ebb:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c0106ec2:	00 
c0106ec3:	c7 04 24 5c a5 10 c0 	movl   $0xc010a55c,(%esp)
c0106eca:	e8 3f 9e ff ff       	call   c0100d0e <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106ecf:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106ed6:	eb 1d                	jmp    c0106ef5 <check_swap+0x5d4>
         free_pages(check_rp[i],1);
c0106ed8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106edb:	8b 04 85 cc 70 12 c0 	mov    -0x3fed8f34(,%eax,4),%eax
c0106ee2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106ee9:	00 
c0106eea:	89 04 24             	mov    %eax,(%esp)
c0106eed:	e8 bb da ff ff       	call   c01049ad <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106ef2:	ff 45 ec             	incl   -0x14(%ebp)
c0106ef5:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106ef9:	7e dd                	jle    c0106ed8 <check_swap+0x5b7>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
c0106efb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106efe:	89 04 24             	mov    %eax,(%esp)
c0106f01:	e8 ab 0a 00 00       	call   c01079b1 <mm_destroy>
         
     nr_free = nr_free_store;
c0106f06:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106f09:	a3 8c 6f 12 c0       	mov    %eax,0xc0126f8c
     free_list = free_list_store;
c0106f0e:	8b 45 98             	mov    -0x68(%ebp),%eax
c0106f11:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0106f14:	a3 84 6f 12 c0       	mov    %eax,0xc0126f84
c0106f19:	89 15 88 6f 12 c0    	mov    %edx,0xc0126f88

     
     le = &free_list;
c0106f1f:	c7 45 e8 84 6f 12 c0 	movl   $0xc0126f84,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0106f26:	eb 1c                	jmp    c0106f44 <check_swap+0x623>
         struct Page *p = le2page(le, page_link);
c0106f28:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106f2b:	83 e8 0c             	sub    $0xc,%eax
c0106f2e:	89 45 cc             	mov    %eax,-0x34(%ebp)
         count --, total -= p->property;
c0106f31:	ff 4d f4             	decl   -0xc(%ebp)
c0106f34:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106f37:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0106f3a:	8b 48 08             	mov    0x8(%eax),%ecx
c0106f3d:	89 d0                	mov    %edx,%eax
c0106f3f:	29 c8                	sub    %ecx,%eax
c0106f41:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106f44:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106f47:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return listelm->next;
c0106f4a:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0106f4d:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c0106f50:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106f53:	81 7d e8 84 6f 12 c0 	cmpl   $0xc0126f84,-0x18(%ebp)
c0106f5a:	75 cc                	jne    c0106f28 <check_swap+0x607>
     }
     cprintf("count is %d, total is %d\n",count,total);
c0106f5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106f5f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106f63:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106f66:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106f6a:	c7 04 24 e1 a8 10 c0 	movl   $0xc010a8e1,(%esp)
c0106f71:	e8 ef 93 ff ff       	call   c0100365 <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c0106f76:	c7 04 24 fb a8 10 c0 	movl   $0xc010a8fb,(%esp)
c0106f7d:	e8 e3 93 ff ff       	call   c0100365 <cprintf>
}
c0106f82:	90                   	nop
c0106f83:	89 ec                	mov    %ebp,%esp
c0106f85:	5d                   	pop    %ebp
c0106f86:	c3                   	ret    

c0106f87 <_extended_clock_init_mm>:
 * (2) _extended_clock_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access extended_clock PRA
 */
static int
_extended_clock_init_mm(struct mm_struct *mm)
{     
c0106f87:	55                   	push   %ebp
c0106f88:	89 e5                	mov    %esp,%ebp
c0106f8a:	83 ec 10             	sub    $0x10,%esp
c0106f8d:	c7 45 fc 04 71 12 c0 	movl   $0xc0127104,-0x4(%ebp)
    elm->prev = elm->next = elm;
c0106f94:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106f97:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0106f9a:	89 50 04             	mov    %edx,0x4(%eax)
c0106f9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106fa0:	8b 50 04             	mov    0x4(%eax),%edx
c0106fa3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106fa6:	89 10                	mov    %edx,(%eax)
}
c0106fa8:	90                   	nop
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c0106fa9:	8b 45 08             	mov    0x8(%ebp),%eax
c0106fac:	c7 40 14 04 71 12 c0 	movl   $0xc0127104,0x14(%eax)
     //cprintf(" mm->sm_priv %x in extended_clock_init_mm\n",mm->sm_priv);
     return 0;
c0106fb3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106fb8:	89 ec                	mov    %ebp,%esp
c0106fba:	5d                   	pop    %ebp
c0106fbb:	c3                   	ret    

c0106fbc <_extended_clock_map_swappable>:
/*
 * (3)_extended_clock_map_swappable: According extended_clock PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_extended_clock_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0106fbc:	55                   	push   %ebp
c0106fbd:	89 e5                	mov    %esp,%ebp
c0106fbf:	83 ec 48             	sub    $0x48,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0106fc2:	8b 45 08             	mov    0x8(%ebp),%eax
c0106fc5:	8b 40 14             	mov    0x14(%eax),%eax
c0106fc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c0106fcb:	8b 45 10             	mov    0x10(%ebp),%eax
c0106fce:	83 c0 14             	add    $0x14,%eax
c0106fd1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(entry != NULL && head != NULL);
c0106fd4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106fd8:	74 06                	je     c0106fe0 <_extended_clock_map_swappable+0x24>
c0106fda:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106fde:	75 24                	jne    c0107004 <_extended_clock_map_swappable+0x48>
c0106fe0:	c7 44 24 0c 14 a9 10 	movl   $0xc010a914,0xc(%esp)
c0106fe7:	c0 
c0106fe8:	c7 44 24 08 32 a9 10 	movl   $0xc010a932,0x8(%esp)
c0106fef:	c0 
c0106ff0:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
c0106ff7:	00 
c0106ff8:	c7 04 24 47 a9 10 c0 	movl   $0xc010a947,(%esp)
c0106fff:	e8 0a 9d ff ff       	call   c0100d0e <__panic>
c0107004:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107007:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010700a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010700d:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0107010:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107013:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0107016:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107019:	89 45 d8             	mov    %eax,-0x28(%ebp)
    __list_add(elm, listelm, listelm->next);
c010701c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010701f:	8b 40 04             	mov    0x4(%eax),%eax
c0107022:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107025:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0107028:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010702b:	89 55 d0             	mov    %edx,-0x30(%ebp)
c010702e:	89 45 cc             	mov    %eax,-0x34(%ebp)
    prev->next = next->prev = elm;
c0107031:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0107034:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107037:	89 10                	mov    %edx,(%eax)
c0107039:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010703c:	8b 10                	mov    (%eax),%edx
c010703e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107041:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0107044:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107047:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010704a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010704d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107050:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0107053:	89 10                	mov    %edx,(%eax)
}
c0107055:	90                   	nop
}
c0107056:	90                   	nop
}
c0107057:	90                   	nop

    list_add(head, entry);
    // 初始访问位和修改位均置0
    struct Page *ptr = le2page(entry, pra_page_link);
c0107058:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010705b:	83 e8 14             	sub    $0x14,%eax
c010705e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pte_t *pte = get_pte(mm -> pgdir, ptr -> pra_vaddr, 0);
c0107061:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107064:	8b 50 1c             	mov    0x1c(%eax),%edx
c0107067:	8b 45 08             	mov    0x8(%ebp),%eax
c010706a:	8b 40 0c             	mov    0xc(%eax),%eax
c010706d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107074:	00 
c0107075:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107079:	89 04 24             	mov    %eax,(%esp)
c010707c:	e8 75 df ff ff       	call   c0104ff6 <get_pte>
c0107081:	89 45 e8             	mov    %eax,-0x18(%ebp)
    // 将PTE_A（访问位）和PTE_D（读写位）置0
    *pte &= ~PTE_D;
c0107084:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107087:	8b 00                	mov    (%eax),%eax
c0107089:	83 e0 bf             	and    $0xffffffbf,%eax
c010708c:	89 c2                	mov    %eax,%edx
c010708e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107091:	89 10                	mov    %edx,(%eax)
    *pte &= ~PTE_A;
c0107093:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107096:	8b 00                	mov    (%eax),%eax
c0107098:	83 e0 df             	and    $0xffffffdf,%eax
c010709b:	89 c2                	mov    %eax,%edx
c010709d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01070a0:	89 10                	mov    %edx,(%eax)
    
    
    return 0;
c01070a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01070a7:	89 ec                	mov    %ebp,%esp
c01070a9:	5d                   	pop    %ebp
c01070aa:	c3                   	ret    

c01070ab <_extended_clock_swap_out_victim>:
 *  (4)_extended_clock_swap_out_victim: According extended_clock PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_extended_clock_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c01070ab:	55                   	push   %ebp
c01070ac:	89 e5                	mov    %esp,%ebp
c01070ae:	83 ec 68             	sub    $0x68,%esp
     // 两个指针，一个指向头，一个指向尾
    list_entry_t *head = (list_entry_t*)mm->sm_priv;
c01070b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01070b4:	8b 40 14             	mov    0x14(%eax),%eax
c01070b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(head != NULL);
c01070ba:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01070be:	75 24                	jne    c01070e4 <_extended_clock_swap_out_victim+0x39>
c01070c0:	c7 44 24 0c 65 a9 10 	movl   $0xc010a965,0xc(%esp)
c01070c7:	c0 
c01070c8:	c7 44 24 08 32 a9 10 	movl   $0xc010a932,0x8(%esp)
c01070cf:	c0 
c01070d0:	c7 44 24 04 47 00 00 	movl   $0x47,0x4(%esp)
c01070d7:	00 
c01070d8:	c7 04 24 47 a9 10 c0 	movl   $0xc010a947,(%esp)
c01070df:	e8 2a 9c ff ff       	call   c0100d0e <__panic>
    assert(in_tick == 0);
c01070e4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01070e8:	74 24                	je     c010710e <_extended_clock_swap_out_victim+0x63>
c01070ea:	c7 44 24 0c 72 a9 10 	movl   $0xc010a972,0xc(%esp)
c01070f1:	c0 
c01070f2:	c7 44 24 08 32 a9 10 	movl   $0xc010a932,0x8(%esp)
c01070f9:	c0 
c01070fa:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
c0107101:	00 
c0107102:	c7 04 24 47 a9 10 c0 	movl   $0xc010a947,(%esp)
c0107109:	e8 00 9c ff ff       	call   c0100d0e <__panic>
    list_entry_t *tail = head->prev;
c010710e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107111:	8b 00                	mov    (%eax),%eax
c0107113:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int i;
    for (i = 0; i <= 3; i ++) {
c0107116:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c010711d:	e9 20 02 00 00       	jmp    c0107342 <_extended_clock_swap_out_victim+0x297>
        while (tail != head) {
            struct Page *page = le2page(tail, pra_page_link);
c0107122:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107125:	83 e8 14             	sub    $0x14,%eax
c0107128:	89 45 e8             	mov    %eax,-0x18(%ebp)
            pte_t *ptep = get_pte(mm->pgdir, page->pra_vaddr, 0);
c010712b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010712e:	8b 50 1c             	mov    0x1c(%eax),%edx
c0107131:	8b 45 08             	mov    0x8(%ebp),%eax
c0107134:	8b 40 0c             	mov    0xc(%eax),%eax
c0107137:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010713e:	00 
c010713f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107143:	89 04 24             	mov    %eax,(%esp)
c0107146:	e8 ab de ff ff       	call   c0104ff6 <get_pte>
c010714b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            switch(i)
c010714e:	83 7d f0 02          	cmpl   $0x2,-0x10(%ebp)
c0107152:	0f 84 04 01 00 00    	je     c010725c <_extended_clock_swap_out_victim+0x1b1>
c0107158:	83 7d f0 02          	cmpl   $0x2,-0x10(%ebp)
c010715c:	0f 8f 64 01 00 00    	jg     c01072c6 <_extended_clock_swap_out_victim+0x21b>
c0107162:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107166:	74 0b                	je     c0107173 <_extended_clock_swap_out_victim+0xc8>
c0107168:	83 7d f0 01          	cmpl   $0x1,-0x10(%ebp)
c010716c:	74 72                	je     c01071e0 <_extended_clock_swap_out_victim+0x135>
c010716e:	e9 53 01 00 00       	jmp    c01072c6 <_extended_clock_swap_out_victim+0x21b>
            {
                case 0:
                {
                    if (!(*ptep & PTE_A) && !(*ptep & PTE_D)) {
c0107173:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107176:	8b 00                	mov    (%eax),%eax
c0107178:	83 e0 20             	and    $0x20,%eax
c010717b:	85 c0                	test   %eax,%eax
c010717d:	75 54                	jne    c01071d3 <_extended_clock_swap_out_victim+0x128>
c010717f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107182:	8b 00                	mov    (%eax),%eax
c0107184:	83 e0 40             	and    $0x40,%eax
c0107187:	85 c0                	test   %eax,%eax
c0107189:	75 48                	jne    c01071d3 <_extended_clock_swap_out_victim+0x128>
c010718b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010718e:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_del(listelm->prev, listelm->next);
c0107191:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107194:	8b 40 04             	mov    0x4(%eax),%eax
c0107197:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010719a:	8b 12                	mov    (%edx),%edx
c010719c:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010719f:	89 45 d8             	mov    %eax,-0x28(%ebp)
    prev->next = next;
c01071a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01071a5:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01071a8:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01071ab:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01071ae:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01071b1:	89 10                	mov    %edx,(%eax)
}
c01071b3:	90                   	nop
}
c01071b4:	90                   	nop
                        list_del(tail);
                        cprintf("我们找到了(0,0)的页进行换出\n\n");
c01071b5:	c7 04 24 80 a9 10 c0 	movl   $0xc010a980,(%esp)
c01071bc:	e8 a4 91 ff ff       	call   c0100365 <cprintf>
                        *ptr_page = page;
c01071c1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01071c4:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01071c7:	89 10                	mov    %edx,(%eax)
                        return 0;
c01071c9:	b8 00 00 00 00       	mov    $0x0,%eax
c01071ce:	e9 75 01 00 00       	jmp    c0107348 <_extended_clock_swap_out_victim+0x29d>
                    }
                    tail = tail->prev;
c01071d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01071d6:	8b 00                	mov    (%eax),%eax
c01071d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
                    break;
c01071db:	e9 4b 01 00 00       	jmp    c010732b <_extended_clock_swap_out_victim+0x280>
                }
                case 1:
                {
                    if( !(*ptep & PTE_A) && (*ptep & PTE_D) )
c01071e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01071e3:	8b 00                	mov    (%eax),%eax
c01071e5:	83 e0 20             	and    $0x20,%eax
c01071e8:	85 c0                	test   %eax,%eax
c01071ea:	75 54                	jne    c0107240 <_extended_clock_swap_out_victim+0x195>
c01071ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01071ef:	8b 00                	mov    (%eax),%eax
c01071f1:	83 e0 40             	and    $0x40,%eax
c01071f4:	85 c0                	test   %eax,%eax
c01071f6:	74 48                	je     c0107240 <_extended_clock_swap_out_victim+0x195>
c01071f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01071fb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    __list_del(listelm->prev, listelm->next);
c01071fe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107201:	8b 40 04             	mov    0x4(%eax),%eax
c0107204:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107207:	8b 12                	mov    (%edx),%edx
c0107209:	89 55 d0             	mov    %edx,-0x30(%ebp)
c010720c:	89 45 cc             	mov    %eax,-0x34(%ebp)
    prev->next = next;
c010720f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107212:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0107215:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0107218:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010721b:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010721e:	89 10                	mov    %edx,(%eax)
}
c0107220:	90                   	nop
}
c0107221:	90                   	nop
                    {
                        list_del(tail);
                        cprintf("我们找到了(0,1)的页进行换出\n\n");
c0107222:	c7 04 24 ac a9 10 c0 	movl   $0xc010a9ac,(%esp)
c0107229:	e8 37 91 ff ff       	call   c0100365 <cprintf>
                        *ptr_page = page;
c010722e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107231:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0107234:	89 10                	mov    %edx,(%eax)
                        return 0;
c0107236:	b8 00 00 00 00       	mov    $0x0,%eax
c010723b:	e9 08 01 00 00       	jmp    c0107348 <_extended_clock_swap_out_victim+0x29d>
                    }
                    else
                    {
                        *ptep &= ~PTE_A;
c0107240:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107243:	8b 00                	mov    (%eax),%eax
c0107245:	83 e0 df             	and    $0xffffffdf,%eax
c0107248:	89 c2                	mov    %eax,%edx
c010724a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010724d:	89 10                	mov    %edx,(%eax)
                    }
                    tail = tail->prev;
c010724f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107252:	8b 00                	mov    (%eax),%eax
c0107254:	89 45 f4             	mov    %eax,-0xc(%ebp)
                    break;
c0107257:	e9 cf 00 00 00       	jmp    c010732b <_extended_clock_swap_out_victim+0x280>
                }
                case 2:
                {
                    if (!(*ptep & PTE_A) && !(*ptep & PTE_D)) {
c010725c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010725f:	8b 00                	mov    (%eax),%eax
c0107261:	83 e0 20             	and    $0x20,%eax
c0107264:	85 c0                	test   %eax,%eax
c0107266:	75 54                	jne    c01072bc <_extended_clock_swap_out_victim+0x211>
c0107268:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010726b:	8b 00                	mov    (%eax),%eax
c010726d:	83 e0 40             	and    $0x40,%eax
c0107270:	85 c0                	test   %eax,%eax
c0107272:	75 48                	jne    c01072bc <_extended_clock_swap_out_victim+0x211>
c0107274:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107277:	89 45 c8             	mov    %eax,-0x38(%ebp)
    __list_del(listelm->prev, listelm->next);
c010727a:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010727d:	8b 40 04             	mov    0x4(%eax),%eax
c0107280:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0107283:	8b 12                	mov    (%edx),%edx
c0107285:	89 55 c4             	mov    %edx,-0x3c(%ebp)
c0107288:	89 45 c0             	mov    %eax,-0x40(%ebp)
    prev->next = next;
c010728b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010728e:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0107291:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0107294:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0107297:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010729a:	89 10                	mov    %edx,(%eax)
}
c010729c:	90                   	nop
}
c010729d:	90                   	nop
                        list_del(tail);
                        cprintf("我们找到了(1,0)的页进行换出\n\n");
c010729e:	c7 04 24 d8 a9 10 c0 	movl   $0xc010a9d8,(%esp)
c01072a5:	e8 bb 90 ff ff       	call   c0100365 <cprintf>
                        *ptr_page = page;
c01072aa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01072ad:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01072b0:	89 10                	mov    %edx,(%eax)
                        return 0;
c01072b2:	b8 00 00 00 00       	mov    $0x0,%eax
c01072b7:	e9 8c 00 00 00       	jmp    c0107348 <_extended_clock_swap_out_victim+0x29d>
                    }
                    tail = tail->prev;
c01072bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01072bf:	8b 00                	mov    (%eax),%eax
c01072c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
                    break;
c01072c4:	eb 65                	jmp    c010732b <_extended_clock_swap_out_victim+0x280>
                }
                default:
                {
                    if( !(*ptep & PTE_A) && (*ptep & PTE_D) )
c01072c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01072c9:	8b 00                	mov    (%eax),%eax
c01072cb:	83 e0 20             	and    $0x20,%eax
c01072ce:	85 c0                	test   %eax,%eax
c01072d0:	75 51                	jne    c0107323 <_extended_clock_swap_out_victim+0x278>
c01072d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01072d5:	8b 00                	mov    (%eax),%eax
c01072d7:	83 e0 40             	and    $0x40,%eax
c01072da:	85 c0                	test   %eax,%eax
c01072dc:	74 45                	je     c0107323 <_extended_clock_swap_out_victim+0x278>
c01072de:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01072e1:	89 45 bc             	mov    %eax,-0x44(%ebp)
    __list_del(listelm->prev, listelm->next);
c01072e4:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01072e7:	8b 40 04             	mov    0x4(%eax),%eax
c01072ea:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01072ed:	8b 12                	mov    (%edx),%edx
c01072ef:	89 55 b8             	mov    %edx,-0x48(%ebp)
c01072f2:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    prev->next = next;
c01072f5:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01072f8:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01072fb:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01072fe:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0107301:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0107304:	89 10                	mov    %edx,(%eax)
}
c0107306:	90                   	nop
}
c0107307:	90                   	nop
                    {
                        list_del(tail);
                        cprintf("我们找到了(1,1)的页进行换出\n\n");
c0107308:	c7 04 24 04 aa 10 c0 	movl   $0xc010aa04,(%esp)
c010730f:	e8 51 90 ff ff       	call   c0100365 <cprintf>
                        *ptr_page = page;
c0107314:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107317:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010731a:	89 10                	mov    %edx,(%eax)
                        return 0;
c010731c:	b8 00 00 00 00       	mov    $0x0,%eax
c0107321:	eb 25                	jmp    c0107348 <_extended_clock_swap_out_victim+0x29d>
                    }
                    tail = tail->prev;
c0107323:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107326:	8b 00                	mov    (%eax),%eax
c0107328:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while (tail != head) {
c010732b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010732e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107331:	0f 85 eb fd ff ff    	jne    c0107122 <_extended_clock_swap_out_victim+0x77>
                }

            }
            
        }
        tail = tail->prev;
c0107337:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010733a:	8b 00                	mov    (%eax),%eax
c010733c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (i = 0; i <= 3; i ++) {
c010733f:	ff 45 f0             	incl   -0x10(%ebp)
c0107342:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
c0107346:	7e e3                	jle    c010732b <_extended_clock_swap_out_victim+0x280>
    
    }
    

    
}
c0107348:	89 ec                	mov    %ebp,%esp
c010734a:	5d                   	pop    %ebp
c010734b:	c3                   	ret    

c010734c <visit>:

static void visit(struct mm_struct *mm,uintptr_t addr,int value){
c010734c:	55                   	push   %ebp
c010734d:	89 e5                	mov    %esp,%ebp
c010734f:	83 ec 28             	sub    $0x28,%esp
    *(unsigned char*) addr = value;
c0107352:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107355:	8b 55 10             	mov    0x10(%ebp),%edx
c0107358:	88 10                	mov    %dl,(%eax)
    //从虚拟地址获取pte
    uintptr_t *pte = get_pte(mm->pgdir,addr,0);
c010735a:	8b 45 08             	mov    0x8(%ebp),%eax
c010735d:	8b 40 0c             	mov    0xc(%eax),%eax
c0107360:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107367:	00 
c0107368:	8b 55 0c             	mov    0xc(%ebp),%edx
c010736b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010736f:	89 04 24             	mov    %eax,(%esp)
c0107372:	e8 7f dc ff ff       	call   c0104ff6 <get_pte>
c0107377:	89 45 f4             	mov    %eax,-0xc(%ebp)
    //之后我们将访问位，以及direty位置1
    if(pte!=NULL)
c010737a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010737e:	74 1e                	je     c010739e <visit+0x52>
    {
    *pte |=PTE_A ;
c0107380:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107383:	8b 00                	mov    (%eax),%eax
c0107385:	83 c8 20             	or     $0x20,%eax
c0107388:	89 c2                	mov    %eax,%edx
c010738a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010738d:	89 10                	mov    %edx,(%eax)
    *pte |=PTE_D;
c010738f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107392:	8b 00                	mov    (%eax),%eax
c0107394:	83 c8 40             	or     $0x40,%eax
c0107397:	89 c2                	mov    %eax,%edx
c0107399:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010739c:	89 10                	mov    %edx,(%eax)
    }
   
}
c010739e:	90                   	nop
c010739f:	89 ec                	mov    %ebp,%esp
c01073a1:	5d                   	pop    %ebp
c01073a2:	c3                   	ret    

c01073a3 <_extended_clock_check_swap>:



static int
_extended_clock_check_swap(struct mm_struct *mm) {
c01073a3:	55                   	push   %ebp
c01073a4:	89 e5                	mov    %esp,%ebp
c01073a6:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in extended_clock_check_swap\n");
c01073a9:	c7 04 24 30 aa 10 c0 	movl   $0xc010aa30,(%esp)
c01073b0:	e8 b0 8f ff ff       	call   c0100365 <cprintf>
    //*(unsigned char *)0x3000 = 0x0c;
    visit(mm,0x3000,0x0c);
c01073b5:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
c01073bc:	00 
c01073bd:	c7 44 24 04 00 30 00 	movl   $0x3000,0x4(%esp)
c01073c4:	00 
c01073c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01073c8:	89 04 24             	mov    %eax,(%esp)
c01073cb:	e8 7c ff ff ff       	call   c010734c <visit>
    assert(pgfault_num==4);
c01073d0:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c01073d5:	83 f8 04             	cmp    $0x4,%eax
c01073d8:	74 24                	je     c01073fe <_extended_clock_check_swap+0x5b>
c01073da:	c7 44 24 0c 60 aa 10 	movl   $0xc010aa60,0xc(%esp)
c01073e1:	c0 
c01073e2:	c7 44 24 08 32 a9 10 	movl   $0xc010a932,0x8(%esp)
c01073e9:	c0 
c01073ea:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
c01073f1:	00 
c01073f2:	c7 04 24 47 a9 10 c0 	movl   $0xc010a947,(%esp)
c01073f9:	e8 10 99 ff ff       	call   c0100d0e <__panic>
    cprintf("write Virt Page a in extended_clock_check_swap\n");
c01073fe:	c7 04 24 70 aa 10 c0 	movl   $0xc010aa70,(%esp)
c0107405:	e8 5b 8f ff ff       	call   c0100365 <cprintf>
    //*(unsigned char *)0x1000 = 0x0a;
    visit(mm,0x1000,0x0a);
c010740a:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
c0107411:	00 
c0107412:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0107419:	00 
c010741a:	8b 45 08             	mov    0x8(%ebp),%eax
c010741d:	89 04 24             	mov    %eax,(%esp)
c0107420:	e8 27 ff ff ff       	call   c010734c <visit>
    assert(pgfault_num==4);
c0107425:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c010742a:	83 f8 04             	cmp    $0x4,%eax
c010742d:	74 24                	je     c0107453 <_extended_clock_check_swap+0xb0>
c010742f:	c7 44 24 0c 60 aa 10 	movl   $0xc010aa60,0xc(%esp)
c0107436:	c0 
c0107437:	c7 44 24 08 32 a9 10 	movl   $0xc010a932,0x8(%esp)
c010743e:	c0 
c010743f:	c7 44 24 04 a6 00 00 	movl   $0xa6,0x4(%esp)
c0107446:	00 
c0107447:	c7 04 24 47 a9 10 c0 	movl   $0xc010a947,(%esp)
c010744e:	e8 bb 98 ff ff       	call   c0100d0e <__panic>
    cprintf("write Virt Page d in extended_clock_check_swap\n");
c0107453:	c7 04 24 a0 aa 10 c0 	movl   $0xc010aaa0,(%esp)
c010745a:	e8 06 8f ff ff       	call   c0100365 <cprintf>
    //*(unsigned char *)0x4000 = 0x0d;
    visit(mm,0x4000,0x0d);
c010745f:	c7 44 24 08 0d 00 00 	movl   $0xd,0x8(%esp)
c0107466:	00 
c0107467:	c7 44 24 04 00 40 00 	movl   $0x4000,0x4(%esp)
c010746e:	00 
c010746f:	8b 45 08             	mov    0x8(%ebp),%eax
c0107472:	89 04 24             	mov    %eax,(%esp)
c0107475:	e8 d2 fe ff ff       	call   c010734c <visit>
    assert(pgfault_num==4);
c010747a:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c010747f:	83 f8 04             	cmp    $0x4,%eax
c0107482:	74 24                	je     c01074a8 <_extended_clock_check_swap+0x105>
c0107484:	c7 44 24 0c 60 aa 10 	movl   $0xc010aa60,0xc(%esp)
c010748b:	c0 
c010748c:	c7 44 24 08 32 a9 10 	movl   $0xc010a932,0x8(%esp)
c0107493:	c0 
c0107494:	c7 44 24 04 aa 00 00 	movl   $0xaa,0x4(%esp)
c010749b:	00 
c010749c:	c7 04 24 47 a9 10 c0 	movl   $0xc010a947,(%esp)
c01074a3:	e8 66 98 ff ff       	call   c0100d0e <__panic>
   /*cprintf("write Virt Page b in extended_clock_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==4);*/
    cprintf("write Virt Page e in extended_clock_check_swap\n");
c01074a8:	c7 04 24 d0 aa 10 c0 	movl   $0xc010aad0,(%esp)
c01074af:	e8 b1 8e ff ff       	call   c0100365 <cprintf>
    //*(unsigned char *)0x5000 = 0x0e;
    visit(mm,0x5000,0x0e);
c01074b4:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
c01074bb:	00 
c01074bc:	c7 44 24 04 00 50 00 	movl   $0x5000,0x4(%esp)
c01074c3:	00 
c01074c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01074c7:	89 04 24             	mov    %eax,(%esp)
c01074ca:	e8 7d fe ff ff       	call   c010734c <visit>
    //assert(pgfault_num==5);
    cprintf("write Virt Page b in extended_clock_check_swap\n");
c01074cf:	c7 04 24 00 ab 10 c0 	movl   $0xc010ab00,(%esp)
c01074d6:	e8 8a 8e ff ff       	call   c0100365 <cprintf>
    //*(unsigned char *)0x2000 = 0x0b;
    visit(mm,0x2000,0x0b);
c01074db:	c7 44 24 08 0b 00 00 	movl   $0xb,0x8(%esp)
c01074e2:	00 
c01074e3:	c7 44 24 04 00 20 00 	movl   $0x2000,0x4(%esp)
c01074ea:	00 
c01074eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01074ee:	89 04 24             	mov    %eax,(%esp)
c01074f1:	e8 56 fe ff ff       	call   c010734c <visit>
    //assert(pgfault_num==5);
    cprintf("write Virt Page a in extended_clock_check_swap\n");
c01074f6:	c7 04 24 70 aa 10 c0 	movl   $0xc010aa70,(%esp)
c01074fd:	e8 63 8e ff ff       	call   c0100365 <cprintf>
    //*(unsigned char *)0x1000 = 0x0a;
    visit(mm,0x1000,0x0a);
c0107502:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
c0107509:	00 
c010750a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0107511:	00 
c0107512:	8b 45 08             	mov    0x8(%ebp),%eax
c0107515:	89 04 24             	mov    %eax,(%esp)
c0107518:	e8 2f fe ff ff       	call   c010734c <visit>
    //assert(pgfault_num==6);
    cprintf("write Virt Page b in extended_clock_check_swap\n");
c010751d:	c7 04 24 00 ab 10 c0 	movl   $0xc010ab00,(%esp)
c0107524:	e8 3c 8e ff ff       	call   c0100365 <cprintf>
    //*(unsigned char *)0x2000 = 0x0b;
    visit(mm,0x2000,0x0b);
c0107529:	c7 44 24 08 0b 00 00 	movl   $0xb,0x8(%esp)
c0107530:	00 
c0107531:	c7 44 24 04 00 20 00 	movl   $0x2000,0x4(%esp)
c0107538:	00 
c0107539:	8b 45 08             	mov    0x8(%ebp),%eax
c010753c:	89 04 24             	mov    %eax,(%esp)
c010753f:	e8 08 fe ff ff       	call   c010734c <visit>
    //assert(pgfault_num==7);
    cprintf("write Virt Page c in extended_clock_check_swap\n");
c0107544:	c7 04 24 30 aa 10 c0 	movl   $0xc010aa30,(%esp)
c010754b:	e8 15 8e ff ff       	call   c0100365 <cprintf>
    //*(unsigned char *)0x3000 = 0x0c;
    visit(mm,0x3000,0x0c);
c0107550:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
c0107557:	00 
c0107558:	c7 44 24 04 00 30 00 	movl   $0x3000,0x4(%esp)
c010755f:	00 
c0107560:	8b 45 08             	mov    0x8(%ebp),%eax
c0107563:	89 04 24             	mov    %eax,(%esp)
c0107566:	e8 e1 fd ff ff       	call   c010734c <visit>
    //assert(pgfault_num==8);
    cprintf("write Virt Page d in extended_clock_check_swap\n");
c010756b:	c7 04 24 a0 aa 10 c0 	movl   $0xc010aaa0,(%esp)
c0107572:	e8 ee 8d ff ff       	call   c0100365 <cprintf>
    //*(unsigned char *)0x4000 = 0x0d;
    visit(mm,0x4000,0x0d);
c0107577:	c7 44 24 08 0d 00 00 	movl   $0xd,0x8(%esp)
c010757e:	00 
c010757f:	c7 44 24 04 00 40 00 	movl   $0x4000,0x4(%esp)
c0107586:	00 
c0107587:	8b 45 08             	mov    0x8(%ebp),%eax
c010758a:	89 04 24             	mov    %eax,(%esp)
c010758d:	e8 ba fd ff ff       	call   c010734c <visit>
    //assert(pgfault_num==9);
    cprintf("write Virt Page e in extended_clock_check_swap\n");
c0107592:	c7 04 24 d0 aa 10 c0 	movl   $0xc010aad0,(%esp)
c0107599:	e8 c7 8d ff ff       	call   c0100365 <cprintf>
    //*(unsigned char *)0x5000 = 0x0e;
    visit(mm,0x5000,0x0e);
c010759e:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
c01075a5:	00 
c01075a6:	c7 44 24 04 00 50 00 	movl   $0x5000,0x4(%esp)
c01075ad:	00 
c01075ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01075b1:	89 04 24             	mov    %eax,(%esp)
c01075b4:	e8 93 fd ff ff       	call   c010734c <visit>
    //assert(pgfault_num==10);
    cprintf("write Virt Page a in extended_clock_check_swap\n");
c01075b9:	c7 04 24 70 aa 10 c0 	movl   $0xc010aa70,(%esp)
c01075c0:	e8 a0 8d ff ff       	call   c0100365 <cprintf>
    //assert(*(unsigned char *)0x1000 == 0x0a);
    //*(unsigned char *)0x1000 = 0x0a;
    visit(mm,0x1000,0x0a);
c01075c5:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
c01075cc:	00 
c01075cd:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01075d4:	00 
c01075d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01075d8:	89 04 24             	mov    %eax,(%esp)
c01075db:	e8 6c fd ff ff       	call   c010734c <visit>
    //assert(pgfault_num==11);
    return 0;
c01075e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01075e5:	89 ec                	mov    %ebp,%esp
c01075e7:	5d                   	pop    %ebp
c01075e8:	c3                   	ret    

c01075e9 <_extended_clock_init>:


static int
_extended_clock_init(void)
{
c01075e9:	55                   	push   %ebp
c01075ea:	89 e5                	mov    %esp,%ebp
    return 0;
c01075ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01075f1:	5d                   	pop    %ebp
c01075f2:	c3                   	ret    

c01075f3 <_extended_clock_set_unswappable>:

static int
_extended_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c01075f3:	55                   	push   %ebp
c01075f4:	89 e5                	mov    %esp,%ebp
    return 0;
c01075f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01075fb:	5d                   	pop    %ebp
c01075fc:	c3                   	ret    

c01075fd <_extended_clock_tick_event>:

static int
_extended_clock_tick_event(struct mm_struct *mm)
{ return 0; }
c01075fd:	55                   	push   %ebp
c01075fe:	89 e5                	mov    %esp,%ebp
c0107600:	b8 00 00 00 00       	mov    $0x0,%eax
c0107605:	5d                   	pop    %ebp
c0107606:	c3                   	ret    

c0107607 <pa2page>:
pa2page(uintptr_t pa) {
c0107607:	55                   	push   %ebp
c0107608:	89 e5                	mov    %esp,%ebp
c010760a:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c010760d:	8b 45 08             	mov    0x8(%ebp),%eax
c0107610:	c1 e8 0c             	shr    $0xc,%eax
c0107613:	89 c2                	mov    %eax,%edx
c0107615:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c010761a:	39 c2                	cmp    %eax,%edx
c010761c:	72 1c                	jb     c010763a <pa2page+0x33>
        panic("pa2page called with invalid pa");
c010761e:	c7 44 24 08 4c ab 10 	movl   $0xc010ab4c,0x8(%esp)
c0107625:	c0 
c0107626:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c010762d:	00 
c010762e:	c7 04 24 6b ab 10 c0 	movl   $0xc010ab6b,(%esp)
c0107635:	e8 d4 96 ff ff       	call   c0100d0e <__panic>
    return &pages[PPN(pa)];
c010763a:	8b 15 a0 6f 12 c0    	mov    0xc0126fa0,%edx
c0107640:	8b 45 08             	mov    0x8(%ebp),%eax
c0107643:	c1 e8 0c             	shr    $0xc,%eax
c0107646:	c1 e0 05             	shl    $0x5,%eax
c0107649:	01 d0                	add    %edx,%eax
}
c010764b:	89 ec                	mov    %ebp,%esp
c010764d:	5d                   	pop    %ebp
c010764e:	c3                   	ret    

c010764f <pde2page>:
pde2page(pde_t pde) {
c010764f:	55                   	push   %ebp
c0107650:	89 e5                	mov    %esp,%ebp
c0107652:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0107655:	8b 45 08             	mov    0x8(%ebp),%eax
c0107658:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010765d:	89 04 24             	mov    %eax,(%esp)
c0107660:	e8 a2 ff ff ff       	call   c0107607 <pa2page>
}
c0107665:	89 ec                	mov    %ebp,%esp
c0107667:	5d                   	pop    %ebp
c0107668:	c3                   	ret    

c0107669 <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c0107669:	55                   	push   %ebp
c010766a:	89 e5                	mov    %esp,%ebp
c010766c:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c010766f:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c0107676:	e8 af ea ff ff       	call   c010612a <kmalloc>
c010767b:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c010767e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107682:	74 59                	je     c01076dd <mm_create+0x74>
        list_init(&(mm->mmap_list));
c0107684:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107687:	89 45 f0             	mov    %eax,-0x10(%ebp)
    elm->prev = elm->next = elm;
c010768a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010768d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107690:	89 50 04             	mov    %edx,0x4(%eax)
c0107693:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107696:	8b 50 04             	mov    0x4(%eax),%edx
c0107699:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010769c:	89 10                	mov    %edx,(%eax)
}
c010769e:	90                   	nop
        mm->mmap_cache = NULL;
c010769f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01076a2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c01076a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01076ac:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c01076b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01076b6:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c01076bd:	a1 44 70 12 c0       	mov    0xc0127044,%eax
c01076c2:	85 c0                	test   %eax,%eax
c01076c4:	74 0d                	je     c01076d3 <mm_create+0x6a>
c01076c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01076c9:	89 04 24             	mov    %eax,(%esp)
c01076cc:	e8 b2 ec ff ff       	call   c0106383 <swap_init_mm>
c01076d1:	eb 0a                	jmp    c01076dd <mm_create+0x74>
        else mm->sm_priv = NULL;
c01076d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01076d6:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    }
    return mm;
c01076dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01076e0:	89 ec                	mov    %ebp,%esp
c01076e2:	5d                   	pop    %ebp
c01076e3:	c3                   	ret    

c01076e4 <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c01076e4:	55                   	push   %ebp
c01076e5:	89 e5                	mov    %esp,%ebp
c01076e7:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c01076ea:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c01076f1:	e8 34 ea ff ff       	call   c010612a <kmalloc>
c01076f6:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c01076f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01076fd:	74 1b                	je     c010771a <vma_create+0x36>
        vma->vm_start = vm_start;
c01076ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107702:	8b 55 08             	mov    0x8(%ebp),%edx
c0107705:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c0107708:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010770b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010770e:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c0107711:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107714:	8b 55 10             	mov    0x10(%ebp),%edx
c0107717:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c010771a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010771d:	89 ec                	mov    %ebp,%esp
c010771f:	5d                   	pop    %ebp
c0107720:	c3                   	ret    

c0107721 <find_vma>:
//find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
//vma_cache,找的时候先找cache，如果cache里面没有东西，或是cache里面的vma不对的话，那么就在双向链表里面找，如果
//找到vma之后，都会在cahe里面更新，即cache里面的东西为上次找到vma，或是为null

struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c0107721:	55                   	push   %ebp
c0107722:	89 e5                	mov    %esp,%ebp
c0107724:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c0107727:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c010772e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0107732:	0f 84 95 00 00 00    	je     c01077cd <find_vma+0xac>
        vma = mm->mmap_cache;
c0107738:	8b 45 08             	mov    0x8(%ebp),%eax
c010773b:	8b 40 08             	mov    0x8(%eax),%eax
c010773e:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c0107741:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0107745:	74 16                	je     c010775d <find_vma+0x3c>
c0107747:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010774a:	8b 40 04             	mov    0x4(%eax),%eax
c010774d:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0107750:	72 0b                	jb     c010775d <find_vma+0x3c>
c0107752:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107755:	8b 40 08             	mov    0x8(%eax),%eax
c0107758:	39 45 0c             	cmp    %eax,0xc(%ebp)
c010775b:	72 61                	jb     c01077be <find_vma+0x9d>
                bool found = 0;
c010775d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c0107764:	8b 45 08             	mov    0x8(%ebp),%eax
c0107767:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010776a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010776d:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c0107770:	eb 28                	jmp    c010779a <find_vma+0x79>
                    vma = le2vma(le, list_link);
c0107772:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107775:	83 e8 10             	sub    $0x10,%eax
c0107778:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c010777b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010777e:	8b 40 04             	mov    0x4(%eax),%eax
c0107781:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0107784:	72 14                	jb     c010779a <find_vma+0x79>
c0107786:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107789:	8b 40 08             	mov    0x8(%eax),%eax
c010778c:	39 45 0c             	cmp    %eax,0xc(%ebp)
c010778f:	73 09                	jae    c010779a <find_vma+0x79>
                        found = 1;
c0107791:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c0107798:	eb 17                	jmp    c01077b1 <find_vma+0x90>
c010779a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010779d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    return listelm->next;
c01077a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01077a3:	8b 40 04             	mov    0x4(%eax),%eax
                while ((le = list_next(le)) != list) {
c01077a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01077a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01077ac:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01077af:	75 c1                	jne    c0107772 <find_vma+0x51>
                    }
                }
                if (!found) {
c01077b1:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c01077b5:	75 07                	jne    c01077be <find_vma+0x9d>
                    vma = NULL;
c01077b7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c01077be:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01077c2:	74 09                	je     c01077cd <find_vma+0xac>
            mm->mmap_cache = vma;
c01077c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01077c7:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01077ca:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c01077cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01077d0:	89 ec                	mov    %ebp,%esp
c01077d2:	5d                   	pop    %ebp
c01077d3:	c3                   	ret    

c01077d4 <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
//看vma地址相交是否不为空
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c01077d4:	55                   	push   %ebp
c01077d5:	89 e5                	mov    %esp,%ebp
c01077d7:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c01077da:	8b 45 08             	mov    0x8(%ebp),%eax
c01077dd:	8b 50 04             	mov    0x4(%eax),%edx
c01077e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01077e3:	8b 40 08             	mov    0x8(%eax),%eax
c01077e6:	39 c2                	cmp    %eax,%edx
c01077e8:	72 24                	jb     c010780e <check_vma_overlap+0x3a>
c01077ea:	c7 44 24 0c 79 ab 10 	movl   $0xc010ab79,0xc(%esp)
c01077f1:	c0 
c01077f2:	c7 44 24 08 97 ab 10 	movl   $0xc010ab97,0x8(%esp)
c01077f9:	c0 
c01077fa:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c0107801:	00 
c0107802:	c7 04 24 ac ab 10 c0 	movl   $0xc010abac,(%esp)
c0107809:	e8 00 95 ff ff       	call   c0100d0e <__panic>
    assert(prev->vm_end <= next->vm_start);
c010780e:	8b 45 08             	mov    0x8(%ebp),%eax
c0107811:	8b 50 08             	mov    0x8(%eax),%edx
c0107814:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107817:	8b 40 04             	mov    0x4(%eax),%eax
c010781a:	39 c2                	cmp    %eax,%edx
c010781c:	76 24                	jbe    c0107842 <check_vma_overlap+0x6e>
c010781e:	c7 44 24 0c bc ab 10 	movl   $0xc010abbc,0xc(%esp)
c0107825:	c0 
c0107826:	c7 44 24 08 97 ab 10 	movl   $0xc010ab97,0x8(%esp)
c010782d:	c0 
c010782e:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0107835:	00 
c0107836:	c7 04 24 ac ab 10 c0 	movl   $0xc010abac,(%esp)
c010783d:	e8 cc 94 ff ff       	call   c0100d0e <__panic>
    assert(next->vm_start < next->vm_end);
c0107842:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107845:	8b 50 04             	mov    0x4(%eax),%edx
c0107848:	8b 45 0c             	mov    0xc(%ebp),%eax
c010784b:	8b 40 08             	mov    0x8(%eax),%eax
c010784e:	39 c2                	cmp    %eax,%edx
c0107850:	72 24                	jb     c0107876 <check_vma_overlap+0xa2>
c0107852:	c7 44 24 0c db ab 10 	movl   $0xc010abdb,0xc(%esp)
c0107859:	c0 
c010785a:	c7 44 24 08 97 ab 10 	movl   $0xc010ab97,0x8(%esp)
c0107861:	c0 
c0107862:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0107869:	00 
c010786a:	c7 04 24 ac ab 10 c0 	movl   $0xc010abac,(%esp)
c0107871:	e8 98 94 ff ff       	call   c0100d0e <__panic>
}
c0107876:	90                   	nop
c0107877:	89 ec                	mov    %ebp,%esp
c0107879:	5d                   	pop    %ebp
c010787a:	c3                   	ret    

c010787b <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
//将vma插入双向链表，用的方法是，找到第一个start比vma的start大的节点，然后把vma后插到它的前一个节点上
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c010787b:	55                   	push   %ebp
c010787c:	89 e5                	mov    %esp,%ebp
c010787e:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c0107881:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107884:	8b 50 04             	mov    0x4(%eax),%edx
c0107887:	8b 45 0c             	mov    0xc(%ebp),%eax
c010788a:	8b 40 08             	mov    0x8(%eax),%eax
c010788d:	39 c2                	cmp    %eax,%edx
c010788f:	72 24                	jb     c01078b5 <insert_vma_struct+0x3a>
c0107891:	c7 44 24 0c f9 ab 10 	movl   $0xc010abf9,0xc(%esp)
c0107898:	c0 
c0107899:	c7 44 24 08 97 ab 10 	movl   $0xc010ab97,0x8(%esp)
c01078a0:	c0 
c01078a1:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
c01078a8:	00 
c01078a9:	c7 04 24 ac ab 10 c0 	movl   $0xc010abac,(%esp)
c01078b0:	e8 59 94 ff ff       	call   c0100d0e <__panic>
    list_entry_t *list = &(mm->mmap_list);
c01078b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01078b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c01078bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01078be:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c01078c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01078c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c01078c7:	eb 1f                	jmp    c01078e8 <insert_vma_struct+0x6d>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c01078c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01078cc:	83 e8 10             	sub    $0x10,%eax
c01078cf:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c01078d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01078d5:	8b 50 04             	mov    0x4(%eax),%edx
c01078d8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01078db:	8b 40 04             	mov    0x4(%eax),%eax
c01078de:	39 c2                	cmp    %eax,%edx
c01078e0:	77 1f                	ja     c0107901 <insert_vma_struct+0x86>
                break;
            }
            le_prev = le;
c01078e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01078e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01078e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01078eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01078ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01078f1:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c01078f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01078f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01078fa:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01078fd:	75 ca                	jne    c01078c9 <insert_vma_struct+0x4e>
c01078ff:	eb 01                	jmp    c0107902 <insert_vma_struct+0x87>
                break;
c0107901:	90                   	nop
c0107902:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107905:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0107908:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010790b:	8b 40 04             	mov    0x4(%eax),%eax
        }

    le_next = list_next(le_prev);
c010790e:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list) {
c0107911:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107914:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107917:	74 15                	je     c010792e <insert_vma_struct+0xb3>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c0107919:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010791c:	8d 50 f0             	lea    -0x10(%eax),%edx
c010791f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107922:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107926:	89 14 24             	mov    %edx,(%esp)
c0107929:	e8 a6 fe ff ff       	call   c01077d4 <check_vma_overlap>
    }
    if (le_next != list) {
c010792e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107931:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107934:	74 15                	je     c010794b <insert_vma_struct+0xd0>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c0107936:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107939:	83 e8 10             	sub    $0x10,%eax
c010793c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107940:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107943:	89 04 24             	mov    %eax,(%esp)
c0107946:	e8 89 fe ff ff       	call   c01077d4 <check_vma_overlap>
    }

    vma->vm_mm = mm;
c010794b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010794e:	8b 55 08             	mov    0x8(%ebp),%edx
c0107951:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c0107953:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107956:	8d 50 10             	lea    0x10(%eax),%edx
c0107959:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010795c:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010795f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c0107962:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107965:	8b 40 04             	mov    0x4(%eax),%eax
c0107968:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010796b:	89 55 d0             	mov    %edx,-0x30(%ebp)
c010796e:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107971:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0107974:	89 45 c8             	mov    %eax,-0x38(%ebp)
    prev->next = next->prev = elm;
c0107977:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010797a:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010797d:	89 10                	mov    %edx,(%eax)
c010797f:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0107982:	8b 10                	mov    (%eax),%edx
c0107984:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0107987:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010798a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010798d:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0107990:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0107993:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107996:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0107999:	89 10                	mov    %edx,(%eax)
}
c010799b:	90                   	nop
}
c010799c:	90                   	nop

    mm->map_count ++;
c010799d:	8b 45 08             	mov    0x8(%ebp),%eax
c01079a0:	8b 40 10             	mov    0x10(%eax),%eax
c01079a3:	8d 50 01             	lea    0x1(%eax),%edx
c01079a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01079a9:	89 50 10             	mov    %edx,0x10(%eax)
}
c01079ac:	90                   	nop
c01079ad:	89 ec                	mov    %ebp,%esp
c01079af:	5d                   	pop    %ebp
c01079b0:	c3                   	ret    

c01079b1 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c01079b1:	55                   	push   %ebp
c01079b2:	89 e5                	mov    %esp,%ebp
c01079b4:	83 ec 38             	sub    $0x38,%esp

    list_entry_t *list = &(mm->mmap_list), *le;
c01079b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01079ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c01079bd:	eb 40                	jmp    c01079ff <mm_destroy+0x4e>
c01079bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01079c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    __list_del(listelm->prev, listelm->next);
c01079c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01079c8:	8b 40 04             	mov    0x4(%eax),%eax
c01079cb:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01079ce:	8b 12                	mov    (%edx),%edx
c01079d0:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01079d3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    prev->next = next;
c01079d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01079d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01079dc:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01079df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01079e2:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01079e5:	89 10                	mov    %edx,(%eax)
}
c01079e7:	90                   	nop
}
c01079e8:	90                   	nop
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
c01079e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01079ec:	83 e8 10             	sub    $0x10,%eax
c01079ef:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
c01079f6:	00 
c01079f7:	89 04 24             	mov    %eax,(%esp)
c01079fa:	e8 cd e7 ff ff       	call   c01061cc <kfree>
c01079ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a02:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c0107a05:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107a08:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(list)) != list) {
c0107a0b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107a0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107a11:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0107a14:	75 a9                	jne    c01079bf <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
c0107a16:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
c0107a1d:	00 
c0107a1e:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a21:	89 04 24             	mov    %eax,(%esp)
c0107a24:	e8 a3 e7 ff ff       	call   c01061cc <kfree>
    mm=NULL;
c0107a29:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c0107a30:	90                   	nop
c0107a31:	89 ec                	mov    %ebp,%esp
c0107a33:	5d                   	pop    %ebp
c0107a34:	c3                   	ret    

c0107a35 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c0107a35:	55                   	push   %ebp
c0107a36:	89 e5                	mov    %esp,%ebp
c0107a38:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c0107a3b:	e8 05 00 00 00       	call   c0107a45 <check_vmm>
}
c0107a40:	90                   	nop
c0107a41:	89 ec                	mov    %ebp,%esp
c0107a43:	5d                   	pop    %ebp
c0107a44:	c3                   	ret    

c0107a45 <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c0107a45:	55                   	push   %ebp
c0107a46:	89 e5                	mov    %esp,%ebp
c0107a48:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0107a4b:	e8 92 cf ff ff       	call   c01049e2 <nr_free_pages>
c0107a50:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c0107a53:	e8 44 00 00 00       	call   c0107a9c <check_vma_struct>
    check_pgfault();
c0107a58:	e8 01 05 00 00       	call   c0107f5e <check_pgfault>

    assert(nr_free_pages_store == nr_free_pages());
c0107a5d:	e8 80 cf ff ff       	call   c01049e2 <nr_free_pages>
c0107a62:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0107a65:	74 24                	je     c0107a8b <check_vmm+0x46>
c0107a67:	c7 44 24 0c 18 ac 10 	movl   $0xc010ac18,0xc(%esp)
c0107a6e:	c0 
c0107a6f:	c7 44 24 08 97 ab 10 	movl   $0xc010ab97,0x8(%esp)
c0107a76:	c0 
c0107a77:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
c0107a7e:	00 
c0107a7f:	c7 04 24 ac ab 10 c0 	movl   $0xc010abac,(%esp)
c0107a86:	e8 83 92 ff ff       	call   c0100d0e <__panic>

    cprintf("check_vmm() succeeded.\n");
c0107a8b:	c7 04 24 3f ac 10 c0 	movl   $0xc010ac3f,(%esp)
c0107a92:	e8 ce 88 ff ff       	call   c0100365 <cprintf>
}
c0107a97:	90                   	nop
c0107a98:	89 ec                	mov    %ebp,%esp
c0107a9a:	5d                   	pop    %ebp
c0107a9b:	c3                   	ret    

c0107a9c <check_vma_struct>:

static void
check_vma_struct(void) {
c0107a9c:	55                   	push   %ebp
c0107a9d:	89 e5                	mov    %esp,%ebp
c0107a9f:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0107aa2:	e8 3b cf ff ff       	call   c01049e2 <nr_free_pages>
c0107aa7:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c0107aaa:	e8 ba fb ff ff       	call   c0107669 <mm_create>
c0107aaf:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c0107ab2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0107ab6:	75 24                	jne    c0107adc <check_vma_struct+0x40>
c0107ab8:	c7 44 24 0c 57 ac 10 	movl   $0xc010ac57,0xc(%esp)
c0107abf:	c0 
c0107ac0:	c7 44 24 08 97 ab 10 	movl   $0xc010ab97,0x8(%esp)
c0107ac7:	c0 
c0107ac8:	c7 44 24 04 b8 00 00 	movl   $0xb8,0x4(%esp)
c0107acf:	00 
c0107ad0:	c7 04 24 ac ab 10 c0 	movl   $0xc010abac,(%esp)
c0107ad7:	e8 32 92 ff ff       	call   c0100d0e <__panic>

    int step1 = 10, step2 = step1 * 10;
c0107adc:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c0107ae3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107ae6:	89 d0                	mov    %edx,%eax
c0107ae8:	c1 e0 02             	shl    $0x2,%eax
c0107aeb:	01 d0                	add    %edx,%eax
c0107aed:	01 c0                	add    %eax,%eax
c0107aef:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c0107af2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107af5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107af8:	eb 6f                	jmp    c0107b69 <check_vma_struct+0xcd>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0107afa:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107afd:	89 d0                	mov    %edx,%eax
c0107aff:	c1 e0 02             	shl    $0x2,%eax
c0107b02:	01 d0                	add    %edx,%eax
c0107b04:	83 c0 02             	add    $0x2,%eax
c0107b07:	89 c1                	mov    %eax,%ecx
c0107b09:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107b0c:	89 d0                	mov    %edx,%eax
c0107b0e:	c1 e0 02             	shl    $0x2,%eax
c0107b11:	01 d0                	add    %edx,%eax
c0107b13:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107b1a:	00 
c0107b1b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0107b1f:	89 04 24             	mov    %eax,(%esp)
c0107b22:	e8 bd fb ff ff       	call   c01076e4 <vma_create>
c0107b27:	89 45 bc             	mov    %eax,-0x44(%ebp)
        assert(vma != NULL);
c0107b2a:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0107b2e:	75 24                	jne    c0107b54 <check_vma_struct+0xb8>
c0107b30:	c7 44 24 0c 62 ac 10 	movl   $0xc010ac62,0xc(%esp)
c0107b37:	c0 
c0107b38:	c7 44 24 08 97 ab 10 	movl   $0xc010ab97,0x8(%esp)
c0107b3f:	c0 
c0107b40:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
c0107b47:	00 
c0107b48:	c7 04 24 ac ab 10 c0 	movl   $0xc010abac,(%esp)
c0107b4f:	e8 ba 91 ff ff       	call   c0100d0e <__panic>
        insert_vma_struct(mm, vma);
c0107b54:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0107b57:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107b5b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107b5e:	89 04 24             	mov    %eax,(%esp)
c0107b61:	e8 15 fd ff ff       	call   c010787b <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
c0107b66:	ff 4d f4             	decl   -0xc(%ebp)
c0107b69:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107b6d:	7f 8b                	jg     c0107afa <check_vma_struct+0x5e>
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0107b6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107b72:	40                   	inc    %eax
c0107b73:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107b76:	eb 6f                	jmp    c0107be7 <check_vma_struct+0x14b>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0107b78:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107b7b:	89 d0                	mov    %edx,%eax
c0107b7d:	c1 e0 02             	shl    $0x2,%eax
c0107b80:	01 d0                	add    %edx,%eax
c0107b82:	83 c0 02             	add    $0x2,%eax
c0107b85:	89 c1                	mov    %eax,%ecx
c0107b87:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107b8a:	89 d0                	mov    %edx,%eax
c0107b8c:	c1 e0 02             	shl    $0x2,%eax
c0107b8f:	01 d0                	add    %edx,%eax
c0107b91:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107b98:	00 
c0107b99:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0107b9d:	89 04 24             	mov    %eax,(%esp)
c0107ba0:	e8 3f fb ff ff       	call   c01076e4 <vma_create>
c0107ba5:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma != NULL);
c0107ba8:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c0107bac:	75 24                	jne    c0107bd2 <check_vma_struct+0x136>
c0107bae:	c7 44 24 0c 62 ac 10 	movl   $0xc010ac62,0xc(%esp)
c0107bb5:	c0 
c0107bb6:	c7 44 24 08 97 ab 10 	movl   $0xc010ab97,0x8(%esp)
c0107bbd:	c0 
c0107bbe:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
c0107bc5:	00 
c0107bc6:	c7 04 24 ac ab 10 c0 	movl   $0xc010abac,(%esp)
c0107bcd:	e8 3c 91 ff ff       	call   c0100d0e <__panic>
        insert_vma_struct(mm, vma);
c0107bd2:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0107bd5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107bd9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107bdc:	89 04 24             	mov    %eax,(%esp)
c0107bdf:	e8 97 fc ff ff       	call   c010787b <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
c0107be4:	ff 45 f4             	incl   -0xc(%ebp)
c0107be7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107bea:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0107bed:	7e 89                	jle    c0107b78 <check_vma_struct+0xdc>
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c0107bef:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107bf2:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0107bf5:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0107bf8:	8b 40 04             	mov    0x4(%eax),%eax
c0107bfb:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c0107bfe:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c0107c05:	e9 96 00 00 00       	jmp    c0107ca0 <check_vma_struct+0x204>
        assert(le != &(mm->mmap_list));
c0107c0a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107c0d:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0107c10:	75 24                	jne    c0107c36 <check_vma_struct+0x19a>
c0107c12:	c7 44 24 0c 6e ac 10 	movl   $0xc010ac6e,0xc(%esp)
c0107c19:	c0 
c0107c1a:	c7 44 24 08 97 ab 10 	movl   $0xc010ab97,0x8(%esp)
c0107c21:	c0 
c0107c22:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c0107c29:	00 
c0107c2a:	c7 04 24 ac ab 10 c0 	movl   $0xc010abac,(%esp)
c0107c31:	e8 d8 90 ff ff       	call   c0100d0e <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c0107c36:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107c39:	83 e8 10             	sub    $0x10,%eax
c0107c3c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c0107c3f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0107c42:	8b 48 04             	mov    0x4(%eax),%ecx
c0107c45:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107c48:	89 d0                	mov    %edx,%eax
c0107c4a:	c1 e0 02             	shl    $0x2,%eax
c0107c4d:	01 d0                	add    %edx,%eax
c0107c4f:	39 c1                	cmp    %eax,%ecx
c0107c51:	75 17                	jne    c0107c6a <check_vma_struct+0x1ce>
c0107c53:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0107c56:	8b 48 08             	mov    0x8(%eax),%ecx
c0107c59:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107c5c:	89 d0                	mov    %edx,%eax
c0107c5e:	c1 e0 02             	shl    $0x2,%eax
c0107c61:	01 d0                	add    %edx,%eax
c0107c63:	83 c0 02             	add    $0x2,%eax
c0107c66:	39 c1                	cmp    %eax,%ecx
c0107c68:	74 24                	je     c0107c8e <check_vma_struct+0x1f2>
c0107c6a:	c7 44 24 0c 88 ac 10 	movl   $0xc010ac88,0xc(%esp)
c0107c71:	c0 
c0107c72:	c7 44 24 08 97 ab 10 	movl   $0xc010ab97,0x8(%esp)
c0107c79:	c0 
c0107c7a:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0107c81:	00 
c0107c82:	c7 04 24 ac ab 10 c0 	movl   $0xc010abac,(%esp)
c0107c89:	e8 80 90 ff ff       	call   c0100d0e <__panic>
c0107c8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107c91:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0107c94:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0107c97:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0107c9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (i = 1; i <= step2; i ++) {
c0107c9d:	ff 45 f4             	incl   -0xc(%ebp)
c0107ca0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ca3:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0107ca6:	0f 8e 5e ff ff ff    	jle    c0107c0a <check_vma_struct+0x16e>
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0107cac:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c0107cb3:	e9 cb 01 00 00       	jmp    c0107e83 <check_vma_struct+0x3e7>
        struct vma_struct *vma1 = find_vma(mm, i);
c0107cb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107cbb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107cbf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107cc2:	89 04 24             	mov    %eax,(%esp)
c0107cc5:	e8 57 fa ff ff       	call   c0107721 <find_vma>
c0107cca:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma1 != NULL);
c0107ccd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0107cd1:	75 24                	jne    c0107cf7 <check_vma_struct+0x25b>
c0107cd3:	c7 44 24 0c bd ac 10 	movl   $0xc010acbd,0xc(%esp)
c0107cda:	c0 
c0107cdb:	c7 44 24 08 97 ab 10 	movl   $0xc010ab97,0x8(%esp)
c0107ce2:	c0 
c0107ce3:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c0107cea:	00 
c0107ceb:	c7 04 24 ac ab 10 c0 	movl   $0xc010abac,(%esp)
c0107cf2:	e8 17 90 ff ff       	call   c0100d0e <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c0107cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107cfa:	40                   	inc    %eax
c0107cfb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107cff:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107d02:	89 04 24             	mov    %eax,(%esp)
c0107d05:	e8 17 fa ff ff       	call   c0107721 <find_vma>
c0107d0a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(vma2 != NULL);
c0107d0d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0107d11:	75 24                	jne    c0107d37 <check_vma_struct+0x29b>
c0107d13:	c7 44 24 0c ca ac 10 	movl   $0xc010acca,0xc(%esp)
c0107d1a:	c0 
c0107d1b:	c7 44 24 08 97 ab 10 	movl   $0xc010ab97,0x8(%esp)
c0107d22:	c0 
c0107d23:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0107d2a:	00 
c0107d2b:	c7 04 24 ac ab 10 c0 	movl   $0xc010abac,(%esp)
c0107d32:	e8 d7 8f ff ff       	call   c0100d0e <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c0107d37:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107d3a:	83 c0 02             	add    $0x2,%eax
c0107d3d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107d41:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107d44:	89 04 24             	mov    %eax,(%esp)
c0107d47:	e8 d5 f9 ff ff       	call   c0107721 <find_vma>
c0107d4c:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma3 == NULL);
c0107d4f:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0107d53:	74 24                	je     c0107d79 <check_vma_struct+0x2dd>
c0107d55:	c7 44 24 0c d7 ac 10 	movl   $0xc010acd7,0xc(%esp)
c0107d5c:	c0 
c0107d5d:	c7 44 24 08 97 ab 10 	movl   $0xc010ab97,0x8(%esp)
c0107d64:	c0 
c0107d65:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
c0107d6c:	00 
c0107d6d:	c7 04 24 ac ab 10 c0 	movl   $0xc010abac,(%esp)
c0107d74:	e8 95 8f ff ff       	call   c0100d0e <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c0107d79:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107d7c:	83 c0 03             	add    $0x3,%eax
c0107d7f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107d83:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107d86:	89 04 24             	mov    %eax,(%esp)
c0107d89:	e8 93 f9 ff ff       	call   c0107721 <find_vma>
c0107d8e:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma4 == NULL);
c0107d91:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0107d95:	74 24                	je     c0107dbb <check_vma_struct+0x31f>
c0107d97:	c7 44 24 0c e4 ac 10 	movl   $0xc010ace4,0xc(%esp)
c0107d9e:	c0 
c0107d9f:	c7 44 24 08 97 ab 10 	movl   $0xc010ab97,0x8(%esp)
c0107da6:	c0 
c0107da7:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c0107dae:	00 
c0107daf:	c7 04 24 ac ab 10 c0 	movl   $0xc010abac,(%esp)
c0107db6:	e8 53 8f ff ff       	call   c0100d0e <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c0107dbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107dbe:	83 c0 04             	add    $0x4,%eax
c0107dc1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107dc5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107dc8:	89 04 24             	mov    %eax,(%esp)
c0107dcb:	e8 51 f9 ff ff       	call   c0107721 <find_vma>
c0107dd0:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma5 == NULL);
c0107dd3:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0107dd7:	74 24                	je     c0107dfd <check_vma_struct+0x361>
c0107dd9:	c7 44 24 0c f1 ac 10 	movl   $0xc010acf1,0xc(%esp)
c0107de0:	c0 
c0107de1:	c7 44 24 08 97 ab 10 	movl   $0xc010ab97,0x8(%esp)
c0107de8:	c0 
c0107de9:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c0107df0:	00 
c0107df1:	c7 04 24 ac ab 10 c0 	movl   $0xc010abac,(%esp)
c0107df8:	e8 11 8f ff ff       	call   c0100d0e <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c0107dfd:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107e00:	8b 50 04             	mov    0x4(%eax),%edx
c0107e03:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107e06:	39 c2                	cmp    %eax,%edx
c0107e08:	75 10                	jne    c0107e1a <check_vma_struct+0x37e>
c0107e0a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107e0d:	8b 40 08             	mov    0x8(%eax),%eax
c0107e10:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107e13:	83 c2 02             	add    $0x2,%edx
c0107e16:	39 d0                	cmp    %edx,%eax
c0107e18:	74 24                	je     c0107e3e <check_vma_struct+0x3a2>
c0107e1a:	c7 44 24 0c 00 ad 10 	movl   $0xc010ad00,0xc(%esp)
c0107e21:	c0 
c0107e22:	c7 44 24 08 97 ab 10 	movl   $0xc010ab97,0x8(%esp)
c0107e29:	c0 
c0107e2a:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c0107e31:	00 
c0107e32:	c7 04 24 ac ab 10 c0 	movl   $0xc010abac,(%esp)
c0107e39:	e8 d0 8e ff ff       	call   c0100d0e <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c0107e3e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107e41:	8b 50 04             	mov    0x4(%eax),%edx
c0107e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107e47:	39 c2                	cmp    %eax,%edx
c0107e49:	75 10                	jne    c0107e5b <check_vma_struct+0x3bf>
c0107e4b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107e4e:	8b 40 08             	mov    0x8(%eax),%eax
c0107e51:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107e54:	83 c2 02             	add    $0x2,%edx
c0107e57:	39 d0                	cmp    %edx,%eax
c0107e59:	74 24                	je     c0107e7f <check_vma_struct+0x3e3>
c0107e5b:	c7 44 24 0c 30 ad 10 	movl   $0xc010ad30,0xc(%esp)
c0107e62:	c0 
c0107e63:	c7 44 24 08 97 ab 10 	movl   $0xc010ab97,0x8(%esp)
c0107e6a:	c0 
c0107e6b:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
c0107e72:	00 
c0107e73:	c7 04 24 ac ab 10 c0 	movl   $0xc010abac,(%esp)
c0107e7a:	e8 8f 8e ff ff       	call   c0100d0e <__panic>
    for (i = 5; i <= 5 * step2; i +=5) {
c0107e7f:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c0107e83:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107e86:	89 d0                	mov    %edx,%eax
c0107e88:	c1 e0 02             	shl    $0x2,%eax
c0107e8b:	01 d0                	add    %edx,%eax
c0107e8d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0107e90:	0f 8e 22 fe ff ff    	jle    c0107cb8 <check_vma_struct+0x21c>
    }

    for (i =4; i>=0; i--) {
c0107e96:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0107e9d:	eb 6f                	jmp    c0107f0e <check_vma_struct+0x472>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c0107e9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ea2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107ea6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107ea9:	89 04 24             	mov    %eax,(%esp)
c0107eac:	e8 70 f8 ff ff       	call   c0107721 <find_vma>
c0107eb1:	89 45 dc             	mov    %eax,-0x24(%ebp)
        if (vma_below_5 != NULL ) {
c0107eb4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0107eb8:	74 27                	je     c0107ee1 <check_vma_struct+0x445>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c0107eba:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107ebd:	8b 50 08             	mov    0x8(%eax),%edx
c0107ec0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107ec3:	8b 40 04             	mov    0x4(%eax),%eax
c0107ec6:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0107eca:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ed1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107ed5:	c7 04 24 60 ad 10 c0 	movl   $0xc010ad60,(%esp)
c0107edc:	e8 84 84 ff ff       	call   c0100365 <cprintf>
        }
        assert(vma_below_5 == NULL);
c0107ee1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0107ee5:	74 24                	je     c0107f0b <check_vma_struct+0x46f>
c0107ee7:	c7 44 24 0c 85 ad 10 	movl   $0xc010ad85,0xc(%esp)
c0107eee:	c0 
c0107eef:	c7 44 24 08 97 ab 10 	movl   $0xc010ab97,0x8(%esp)
c0107ef6:	c0 
c0107ef7:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c0107efe:	00 
c0107eff:	c7 04 24 ac ab 10 c0 	movl   $0xc010abac,(%esp)
c0107f06:	e8 03 8e ff ff       	call   c0100d0e <__panic>
    for (i =4; i>=0; i--) {
c0107f0b:	ff 4d f4             	decl   -0xc(%ebp)
c0107f0e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107f12:	79 8b                	jns    c0107e9f <check_vma_struct+0x403>
    }

    mm_destroy(mm);
c0107f14:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107f17:	89 04 24             	mov    %eax,(%esp)
c0107f1a:	e8 92 fa ff ff       	call   c01079b1 <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
c0107f1f:	e8 be ca ff ff       	call   c01049e2 <nr_free_pages>
c0107f24:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0107f27:	74 24                	je     c0107f4d <check_vma_struct+0x4b1>
c0107f29:	c7 44 24 0c 18 ac 10 	movl   $0xc010ac18,0xc(%esp)
c0107f30:	c0 
c0107f31:	c7 44 24 08 97 ab 10 	movl   $0xc010ab97,0x8(%esp)
c0107f38:	c0 
c0107f39:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
c0107f40:	00 
c0107f41:	c7 04 24 ac ab 10 c0 	movl   $0xc010abac,(%esp)
c0107f48:	e8 c1 8d ff ff       	call   c0100d0e <__panic>

    cprintf("check_vma_struct() succeeded!\n");
c0107f4d:	c7 04 24 9c ad 10 c0 	movl   $0xc010ad9c,(%esp)
c0107f54:	e8 0c 84 ff ff       	call   c0100365 <cprintf>
}
c0107f59:	90                   	nop
c0107f5a:	89 ec                	mov    %ebp,%esp
c0107f5c:	5d                   	pop    %ebp
c0107f5d:	c3                   	ret    

c0107f5e <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c0107f5e:	55                   	push   %ebp
c0107f5f:	89 e5                	mov    %esp,%ebp
c0107f61:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0107f64:	e8 79 ca ff ff       	call   c01049e2 <nr_free_pages>
c0107f69:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c0107f6c:	e8 f8 f6 ff ff       	call   c0107669 <mm_create>
c0107f71:	a3 0c 71 12 c0       	mov    %eax,0xc012710c
    assert(check_mm_struct != NULL);
c0107f76:	a1 0c 71 12 c0       	mov    0xc012710c,%eax
c0107f7b:	85 c0                	test   %eax,%eax
c0107f7d:	75 24                	jne    c0107fa3 <check_pgfault+0x45>
c0107f7f:	c7 44 24 0c bb ad 10 	movl   $0xc010adbb,0xc(%esp)
c0107f86:	c0 
c0107f87:	c7 44 24 08 97 ab 10 	movl   $0xc010ab97,0x8(%esp)
c0107f8e:	c0 
c0107f8f:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c0107f96:	00 
c0107f97:	c7 04 24 ac ab 10 c0 	movl   $0xc010abac,(%esp)
c0107f9e:	e8 6b 8d ff ff       	call   c0100d0e <__panic>

    struct mm_struct *mm = check_mm_struct;
c0107fa3:	a1 0c 71 12 c0       	mov    0xc012710c,%eax
c0107fa8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0107fab:	8b 15 e0 39 12 c0    	mov    0xc01239e0,%edx
c0107fb1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107fb4:	89 50 0c             	mov    %edx,0xc(%eax)
c0107fb7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107fba:	8b 40 0c             	mov    0xc(%eax),%eax
c0107fbd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c0107fc0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107fc3:	8b 00                	mov    (%eax),%eax
c0107fc5:	85 c0                	test   %eax,%eax
c0107fc7:	74 24                	je     c0107fed <check_pgfault+0x8f>
c0107fc9:	c7 44 24 0c d3 ad 10 	movl   $0xc010add3,0xc(%esp)
c0107fd0:	c0 
c0107fd1:	c7 44 24 08 97 ab 10 	movl   $0xc010ab97,0x8(%esp)
c0107fd8:	c0 
c0107fd9:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
c0107fe0:	00 
c0107fe1:	c7 04 24 ac ab 10 c0 	movl   $0xc010abac,(%esp)
c0107fe8:	e8 21 8d ff ff       	call   c0100d0e <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c0107fed:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c0107ff4:	00 
c0107ff5:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c0107ffc:	00 
c0107ffd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0108004:	e8 db f6 ff ff       	call   c01076e4 <vma_create>
c0108009:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c010800c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0108010:	75 24                	jne    c0108036 <check_pgfault+0xd8>
c0108012:	c7 44 24 0c 62 ac 10 	movl   $0xc010ac62,0xc(%esp)
c0108019:	c0 
c010801a:	c7 44 24 08 97 ab 10 	movl   $0xc010ab97,0x8(%esp)
c0108021:	c0 
c0108022:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c0108029:	00 
c010802a:	c7 04 24 ac ab 10 c0 	movl   $0xc010abac,(%esp)
c0108031:	e8 d8 8c ff ff       	call   c0100d0e <__panic>

    insert_vma_struct(mm, vma);
c0108036:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108039:	89 44 24 04          	mov    %eax,0x4(%esp)
c010803d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108040:	89 04 24             	mov    %eax,(%esp)
c0108043:	e8 33 f8 ff ff       	call   c010787b <insert_vma_struct>

    uintptr_t addr = 0x100;
c0108048:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c010804f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108052:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108056:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108059:	89 04 24             	mov    %eax,(%esp)
c010805c:	e8 c0 f6 ff ff       	call   c0107721 <find_vma>
c0108061:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0108064:	74 24                	je     c010808a <check_pgfault+0x12c>
c0108066:	c7 44 24 0c e1 ad 10 	movl   $0xc010ade1,0xc(%esp)
c010806d:	c0 
c010806e:	c7 44 24 08 97 ab 10 	movl   $0xc010ab97,0x8(%esp)
c0108075:	c0 
c0108076:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
c010807d:	00 
c010807e:	c7 04 24 ac ab 10 c0 	movl   $0xc010abac,(%esp)
c0108085:	e8 84 8c ff ff       	call   c0100d0e <__panic>

    int i, sum = 0;
c010808a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0108091:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0108098:	eb 16                	jmp    c01080b0 <check_pgfault+0x152>
        *(char *)(addr + i) = i;
c010809a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010809d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01080a0:	01 d0                	add    %edx,%eax
c01080a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01080a5:	88 10                	mov    %dl,(%eax)
        sum += i;
c01080a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01080aa:	01 45 f0             	add    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c01080ad:	ff 45 f4             	incl   -0xc(%ebp)
c01080b0:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c01080b4:	7e e4                	jle    c010809a <check_pgfault+0x13c>
    }
    for (i = 0; i < 100; i ++) {
c01080b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01080bd:	eb 14                	jmp    c01080d3 <check_pgfault+0x175>
        sum -= *(char *)(addr + i);
c01080bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01080c2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01080c5:	01 d0                	add    %edx,%eax
c01080c7:	0f b6 00             	movzbl (%eax),%eax
c01080ca:	0f be c0             	movsbl %al,%eax
c01080cd:	29 45 f0             	sub    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c01080d0:	ff 45 f4             	incl   -0xc(%ebp)
c01080d3:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c01080d7:	7e e6                	jle    c01080bf <check_pgfault+0x161>
    }
    assert(sum == 0);
c01080d9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01080dd:	74 24                	je     c0108103 <check_pgfault+0x1a5>
c01080df:	c7 44 24 0c fb ad 10 	movl   $0xc010adfb,0xc(%esp)
c01080e6:	c0 
c01080e7:	c7 44 24 08 97 ab 10 	movl   $0xc010ab97,0x8(%esp)
c01080ee:	c0 
c01080ef:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
c01080f6:	00 
c01080f7:	c7 04 24 ac ab 10 c0 	movl   $0xc010abac,(%esp)
c01080fe:	e8 0b 8c ff ff       	call   c0100d0e <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c0108103:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108106:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108109:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010810c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108111:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108115:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108118:	89 04 24             	mov    %eax,(%esp)
c010811b:	e8 34 d1 ff ff       	call   c0105254 <page_remove>
    free_page(pde2page(pgdir[0]));
c0108120:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108123:	8b 00                	mov    (%eax),%eax
c0108125:	89 04 24             	mov    %eax,(%esp)
c0108128:	e8 22 f5 ff ff       	call   c010764f <pde2page>
c010812d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108134:	00 
c0108135:	89 04 24             	mov    %eax,(%esp)
c0108138:	e8 70 c8 ff ff       	call   c01049ad <free_pages>
    pgdir[0] = 0;
c010813d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108140:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c0108146:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108149:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c0108150:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108153:	89 04 24             	mov    %eax,(%esp)
c0108156:	e8 56 f8 ff ff       	call   c01079b1 <mm_destroy>
    check_mm_struct = NULL;
c010815b:	c7 05 0c 71 12 c0 00 	movl   $0x0,0xc012710c
c0108162:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c0108165:	e8 78 c8 ff ff       	call   c01049e2 <nr_free_pages>
c010816a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c010816d:	74 24                	je     c0108193 <check_pgfault+0x235>
c010816f:	c7 44 24 0c 18 ac 10 	movl   $0xc010ac18,0xc(%esp)
c0108176:	c0 
c0108177:	c7 44 24 08 97 ab 10 	movl   $0xc010ab97,0x8(%esp)
c010817e:	c0 
c010817f:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c0108186:	00 
c0108187:	c7 04 24 ac ab 10 c0 	movl   $0xc010abac,(%esp)
c010818e:	e8 7b 8b ff ff       	call   c0100d0e <__panic>

    cprintf("check_pgfault() succeeded!\n");
c0108193:	c7 04 24 04 ae 10 c0 	movl   $0xc010ae04,(%esp)
c010819a:	e8 c6 81 ff ff       	call   c0100365 <cprintf>
}
c010819f:	90                   	nop
c01081a0:	89 ec                	mov    %ebp,%esp
c01081a2:	5d                   	pop    %ebp
c01081a3:	c3                   	ret    

c01081a4 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c01081a4:	55                   	push   %ebp
c01081a5:	89 e5                	mov    %esp,%ebp
c01081a7:	83 ec 38             	sub    $0x38,%esp
    //应该返回不同类型的错误，只有为0时才正确执行函数
    int ret = -E_INVAL;
c01081aa:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c01081b1:	8b 45 10             	mov    0x10(%ebp),%eax
c01081b4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01081b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01081bb:	89 04 24             	mov    %eax,(%esp)
c01081be:	e8 5e f5 ff ff       	call   c0107721 <find_vma>
c01081c3:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c01081c6:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c01081cb:	40                   	inc    %eax
c01081cc:	a3 10 71 12 c0       	mov    %eax,0xc0127110
    //If the addr is in the range of a mm's vma?个人感觉||之后的好像没有必要
    if (vma == NULL || vma->vm_start > addr) {
c01081d1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01081d5:	74 0b                	je     c01081e2 <do_pgfault+0x3e>
c01081d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01081da:	8b 40 04             	mov    0x4(%eax),%eax
c01081dd:	39 45 10             	cmp    %eax,0x10(%ebp)
c01081e0:	73 18                	jae    c01081fa <do_pgfault+0x56>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c01081e2:	8b 45 10             	mov    0x10(%ebp),%eax
c01081e5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01081e9:	c7 04 24 20 ae 10 c0 	movl   $0xc010ae20,(%esp)
c01081f0:	e8 70 81 ff ff       	call   c0100365 <cprintf>
        goto failed;
c01081f5:	e9 ba 01 00 00       	jmp    c01083b4 <do_pgfault+0x210>
    }
    //check the error_code
    switch (error_code & 3) {
c01081fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01081fd:	83 e0 03             	and    $0x3,%eax
c0108200:	85 c0                	test   %eax,%eax
c0108202:	74 34                	je     c0108238 <do_pgfault+0x94>
c0108204:	83 f8 01             	cmp    $0x1,%eax
c0108207:	74 1e                	je     c0108227 <do_pgfault+0x83>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
            //表示写异常且对应的页表存在，个人推测可能是对应的物理内存页被换出了，还有可能就是页表项为0
    case 2: /* error code flag : (W/R=1, P=0): write, not present */ //表示写时发生的异常，对应的页表物理页不存在
        if (!(vma->vm_flags & VM_WRITE)) { //如果虚拟地址不可写
c0108209:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010820c:	8b 40 0c             	mov    0xc(%eax),%eax
c010820f:	83 e0 02             	and    $0x2,%eax
c0108212:	85 c0                	test   %eax,%eax
c0108214:	75 40                	jne    c0108256 <do_pgfault+0xb2>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c0108216:	c7 04 24 50 ae 10 c0 	movl   $0xc010ae50,(%esp)
c010821d:	e8 43 81 ff ff       	call   c0100365 <cprintf>
            goto failed;
c0108222:	e9 8d 01 00 00       	jmp    c01083b4 <do_pgfault+0x210>
        }
        break;
    case 1: /* error code flag : (W/R=0, P=1): read, present */ //表示读异常，对应的物理页存在
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c0108227:	c7 04 24 b0 ae 10 c0 	movl   $0xc010aeb0,(%esp)
c010822e:	e8 32 81 ff ff       	call   c0100365 <cprintf>
        goto failed;
c0108233:	e9 7c 01 00 00       	jmp    c01083b4 <do_pgfault+0x210>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */ //表示读异常，对应的物理页不存在
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) { //如果虚拟地址不可读或是不可执行
c0108238:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010823b:	8b 40 0c             	mov    0xc(%eax),%eax
c010823e:	83 e0 05             	and    $0x5,%eax
c0108241:	85 c0                	test   %eax,%eax
c0108243:	75 12                	jne    c0108257 <do_pgfault+0xb3>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c0108245:	c7 04 24 e8 ae 10 c0 	movl   $0xc010aee8,(%esp)
c010824c:	e8 14 81 ff ff       	call   c0100365 <cprintf>
            goto failed;
c0108251:	e9 5e 01 00 00       	jmp    c01083b4 <do_pgfault+0x210>
        break;
c0108256:	90                   	nop
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c0108257:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c010825e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108261:	8b 40 0c             	mov    0xc(%eax),%eax
c0108264:	83 e0 02             	and    $0x2,%eax
c0108267:	85 c0                	test   %eax,%eax
c0108269:	74 04                	je     c010826f <do_pgfault+0xcb>
        perm |= PTE_W;
c010826b:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    //找到虚拟页的基址
    addr = ROUNDDOWN(addr, PGSIZE);
c010826f:	8b 45 10             	mov    0x10(%ebp),%eax
c0108272:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108275:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108278:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010827d:	89 45 10             	mov    %eax,0x10(%ebp)

    //之后的错误是由于内存短缺引起的
    ret = -E_NO_MEM;
c0108280:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c0108287:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
            goto failed;
        }
   }
#endif

    if((ptep=get_pte(mm->pgdir,addr,1))==NULL)
c010828e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108291:	8b 40 0c             	mov    0xc(%eax),%eax
c0108294:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010829b:	00 
c010829c:	8b 55 10             	mov    0x10(%ebp),%edx
c010829f:	89 54 24 04          	mov    %edx,0x4(%esp)
c01082a3:	89 04 24             	mov    %eax,(%esp)
c01082a6:	e8 4b cd ff ff       	call   c0104ff6 <get_pte>
c01082ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01082ae:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01082b2:	75 11                	jne    c01082c5 <do_pgfault+0x121>
    {
        cprintf("get_pte in do_pgfault failed\n");
c01082b4:	c7 04 24 4b af 10 c0 	movl   $0xc010af4b,(%esp)
c01082bb:	e8 a5 80 ff ff       	call   c0100365 <cprintf>
        goto failed;
c01082c0:	e9 ef 00 00 00       	jmp    c01083b4 <do_pgfault+0x210>
    }
    if(*ptep==0)
c01082c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01082c8:	8b 00                	mov    (%eax),%eax
c01082ca:	85 c0                	test   %eax,%eax
c01082cc:	75 35                	jne    c0108303 <do_pgfault+0x15f>
    {
        if(pgdir_alloc_page(mm->pgdir,addr,perm)==NULL)
c01082ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01082d1:	8b 40 0c             	mov    0xc(%eax),%eax
c01082d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01082d7:	89 54 24 08          	mov    %edx,0x8(%esp)
c01082db:	8b 55 10             	mov    0x10(%ebp),%edx
c01082de:	89 54 24 04          	mov    %edx,0x4(%esp)
c01082e2:	89 04 24             	mov    %eax,(%esp)
c01082e5:	e8 cb d0 ff ff       	call   c01053b5 <pgdir_alloc_page>
c01082ea:	85 c0                	test   %eax,%eax
c01082ec:	0f 85 bb 00 00 00    	jne    c01083ad <do_pgfault+0x209>
        {
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
c01082f2:	c7 04 24 6c af 10 c0 	movl   $0xc010af6c,(%esp)
c01082f9:	e8 67 80 ff ff       	call   c0100365 <cprintf>
            goto failed;
c01082fe:	e9 b1 00 00 00       	jmp    c01083b4 <do_pgfault+0x210>
        
        }
    }
    else
    {
        if(swap_init_ok)
c0108303:	a1 44 70 12 c0       	mov    0xc0127044,%eax
c0108308:	85 c0                	test   %eax,%eax
c010830a:	0f 84 86 00 00 00    	je     c0108396 <do_pgfault+0x1f2>
        {
            struct Page* page=NULL;
c0108310:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            if ((ret = swap_in(mm, addr, &page)) != 0)
c0108317:	8d 45 e0             	lea    -0x20(%ebp),%eax
c010831a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010831e:	8b 45 10             	mov    0x10(%ebp),%eax
c0108321:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108325:	8b 45 08             	mov    0x8(%ebp),%eax
c0108328:	89 04 24             	mov    %eax,(%esp)
c010832b:	e8 4f e2 ff ff       	call   c010657f <swap_in>
c0108330:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108333:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108337:	74 0e                	je     c0108347 <do_pgfault+0x1a3>
            {
                cprintf("swap_in in do_pgfault failed\n");
c0108339:	c7 04 24 93 af 10 c0 	movl   $0xc010af93,(%esp)
c0108340:	e8 20 80 ff ff       	call   c0100365 <cprintf>
c0108345:	eb 6d                	jmp    c01083b4 <do_pgfault+0x210>
                goto failed;
            }  

            page_insert(mm->pgdir,page, addr,perm);
c0108347:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010834a:	8b 45 08             	mov    0x8(%ebp),%eax
c010834d:	8b 40 0c             	mov    0xc(%eax),%eax
c0108350:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0108353:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0108357:	8b 4d 10             	mov    0x10(%ebp),%ecx
c010835a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010835e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108362:	89 04 24             	mov    %eax,(%esp)
c0108365:	e8 31 cf ff ff       	call   c010529b <page_insert>
            swap_map_swappable(mm, addr, page, 1);
c010836a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010836d:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c0108374:	00 
c0108375:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108379:	8b 45 10             	mov    0x10(%ebp),%eax
c010837c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108380:	8b 45 08             	mov    0x8(%ebp),%eax
c0108383:	89 04 24             	mov    %eax,(%esp)
c0108386:	e8 2c e0 ff ff       	call   c01063b7 <swap_map_swappable>
            page->pra_vaddr= addr;
c010838b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010838e:	8b 55 10             	mov    0x10(%ebp),%edx
c0108391:	89 50 1c             	mov    %edx,0x1c(%eax)
c0108394:	eb 17                	jmp    c01083ad <do_pgfault+0x209>
        }
        else{
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
c0108396:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108399:	8b 00                	mov    (%eax),%eax
c010839b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010839f:	c7 04 24 b4 af 10 c0 	movl   $0xc010afb4,(%esp)
c01083a6:	e8 ba 7f ff ff       	call   c0100365 <cprintf>
            goto failed;
c01083ab:	eb 07                	jmp    c01083b4 <do_pgfault+0x210>
    }

   


   ret = 0;
c01083ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c01083b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01083b7:	89 ec                	mov    %ebp,%esp
c01083b9:	5d                   	pop    %ebp
c01083ba:	c3                   	ret    

c01083bb <page2ppn>:
page2ppn(struct Page *page) {
c01083bb:	55                   	push   %ebp
c01083bc:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01083be:	8b 15 a0 6f 12 c0    	mov    0xc0126fa0,%edx
c01083c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01083c7:	29 d0                	sub    %edx,%eax
c01083c9:	c1 f8 05             	sar    $0x5,%eax
}
c01083cc:	5d                   	pop    %ebp
c01083cd:	c3                   	ret    

c01083ce <page2pa>:
page2pa(struct Page *page) {
c01083ce:	55                   	push   %ebp
c01083cf:	89 e5                	mov    %esp,%ebp
c01083d1:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01083d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01083d7:	89 04 24             	mov    %eax,(%esp)
c01083da:	e8 dc ff ff ff       	call   c01083bb <page2ppn>
c01083df:	c1 e0 0c             	shl    $0xc,%eax
}
c01083e2:	89 ec                	mov    %ebp,%esp
c01083e4:	5d                   	pop    %ebp
c01083e5:	c3                   	ret    

c01083e6 <page2kva>:
page2kva(struct Page *page) {
c01083e6:	55                   	push   %ebp
c01083e7:	89 e5                	mov    %esp,%ebp
c01083e9:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01083ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01083ef:	89 04 24             	mov    %eax,(%esp)
c01083f2:	e8 d7 ff ff ff       	call   c01083ce <page2pa>
c01083f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01083fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01083fd:	c1 e8 0c             	shr    $0xc,%eax
c0108400:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108403:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c0108408:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010840b:	72 23                	jb     c0108430 <page2kva+0x4a>
c010840d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108410:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108414:	c7 44 24 08 dc af 10 	movl   $0xc010afdc,0x8(%esp)
c010841b:	c0 
c010841c:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c0108423:	00 
c0108424:	c7 04 24 ff af 10 c0 	movl   $0xc010afff,(%esp)
c010842b:	e8 de 88 ff ff       	call   c0100d0e <__panic>
c0108430:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108433:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0108438:	89 ec                	mov    %ebp,%esp
c010843a:	5d                   	pop    %ebp
c010843b:	c3                   	ret    

c010843c <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c010843c:	55                   	push   %ebp
c010843d:	89 e5                	mov    %esp,%ebp
c010843f:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c0108442:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108449:	e8 6f 96 ff ff       	call   c0101abd <ide_device_valid>
c010844e:	85 c0                	test   %eax,%eax
c0108450:	75 1c                	jne    c010846e <swapfs_init+0x32>
        panic("swap fs isn't available.\n");
c0108452:	c7 44 24 08 0d b0 10 	movl   $0xc010b00d,0x8(%esp)
c0108459:	c0 
c010845a:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c0108461:	00 
c0108462:	c7 04 24 27 b0 10 c0 	movl   $0xc010b027,(%esp)
c0108469:	e8 a0 88 ff ff       	call   c0100d0e <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c010846e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108475:	e8 83 96 ff ff       	call   c0101afd <ide_device_size>
c010847a:	c1 e8 03             	shr    $0x3,%eax
c010847d:	a3 40 70 12 c0       	mov    %eax,0xc0127040
}
c0108482:	90                   	nop
c0108483:	89 ec                	mov    %ebp,%esp
c0108485:	5d                   	pop    %ebp
c0108486:	c3                   	ret    

c0108487 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c0108487:	55                   	push   %ebp
c0108488:	89 e5                	mov    %esp,%ebp
c010848a:	83 ec 28             	sub    $0x28,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c010848d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108490:	89 04 24             	mov    %eax,(%esp)
c0108493:	e8 4e ff ff ff       	call   c01083e6 <page2kva>
c0108498:	8b 55 08             	mov    0x8(%ebp),%edx
c010849b:	c1 ea 08             	shr    $0x8,%edx
c010849e:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01084a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01084a5:	74 0b                	je     c01084b2 <swapfs_read+0x2b>
c01084a7:	8b 15 40 70 12 c0    	mov    0xc0127040,%edx
c01084ad:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c01084b0:	72 23                	jb     c01084d5 <swapfs_read+0x4e>
c01084b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01084b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01084b9:	c7 44 24 08 38 b0 10 	movl   $0xc010b038,0x8(%esp)
c01084c0:	c0 
c01084c1:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c01084c8:	00 
c01084c9:	c7 04 24 27 b0 10 c0 	movl   $0xc010b027,(%esp)
c01084d0:	e8 39 88 ff ff       	call   c0100d0e <__panic>
c01084d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01084d8:	c1 e2 03             	shl    $0x3,%edx
c01084db:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c01084e2:	00 
c01084e3:	89 44 24 08          	mov    %eax,0x8(%esp)
c01084e7:	89 54 24 04          	mov    %edx,0x4(%esp)
c01084eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01084f2:	e8 43 96 ff ff       	call   c0101b3a <ide_read_secs>
}
c01084f7:	89 ec                	mov    %ebp,%esp
c01084f9:	5d                   	pop    %ebp
c01084fa:	c3                   	ret    

c01084fb <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c01084fb:	55                   	push   %ebp
c01084fc:	89 e5                	mov    %esp,%ebp
c01084fe:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0108501:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108504:	89 04 24             	mov    %eax,(%esp)
c0108507:	e8 da fe ff ff       	call   c01083e6 <page2kva>
c010850c:	8b 55 08             	mov    0x8(%ebp),%edx
c010850f:	c1 ea 08             	shr    $0x8,%edx
c0108512:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0108515:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108519:	74 0b                	je     c0108526 <swapfs_write+0x2b>
c010851b:	8b 15 40 70 12 c0    	mov    0xc0127040,%edx
c0108521:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0108524:	72 23                	jb     c0108549 <swapfs_write+0x4e>
c0108526:	8b 45 08             	mov    0x8(%ebp),%eax
c0108529:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010852d:	c7 44 24 08 38 b0 10 	movl   $0xc010b038,0x8(%esp)
c0108534:	c0 
c0108535:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c010853c:	00 
c010853d:	c7 04 24 27 b0 10 c0 	movl   $0xc010b027,(%esp)
c0108544:	e8 c5 87 ff ff       	call   c0100d0e <__panic>
c0108549:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010854c:	c1 e2 03             	shl    $0x3,%edx
c010854f:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c0108556:	00 
c0108557:	89 44 24 08          	mov    %eax,0x8(%esp)
c010855b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010855f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108566:	e8 10 98 ff ff       	call   c0101d7b <ide_write_secs>
}
c010856b:	89 ec                	mov    %ebp,%esp
c010856d:	5d                   	pop    %ebp
c010856e:	c3                   	ret    

c010856f <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010856f:	55                   	push   %ebp
c0108570:	89 e5                	mov    %esp,%ebp
c0108572:	83 ec 58             	sub    $0x58,%esp
c0108575:	8b 45 10             	mov    0x10(%ebp),%eax
c0108578:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010857b:	8b 45 14             	mov    0x14(%ebp),%eax
c010857e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c0108581:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108584:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0108587:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010858a:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c010858d:	8b 45 18             	mov    0x18(%ebp),%eax
c0108590:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108593:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108596:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108599:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010859c:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010859f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01085a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01085a5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01085a9:	74 1c                	je     c01085c7 <printnum+0x58>
c01085ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01085ae:	ba 00 00 00 00       	mov    $0x0,%edx
c01085b3:	f7 75 e4             	divl   -0x1c(%ebp)
c01085b6:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01085b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01085bc:	ba 00 00 00 00       	mov    $0x0,%edx
c01085c1:	f7 75 e4             	divl   -0x1c(%ebp)
c01085c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01085c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01085ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01085cd:	f7 75 e4             	divl   -0x1c(%ebp)
c01085d0:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01085d3:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01085d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01085d9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01085dc:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01085df:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01085e2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01085e5:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c01085e8:	8b 45 18             	mov    0x18(%ebp),%eax
c01085eb:	ba 00 00 00 00       	mov    $0x0,%edx
c01085f0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c01085f3:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c01085f6:	19 d1                	sbb    %edx,%ecx
c01085f8:	72 4c                	jb     c0108646 <printnum+0xd7>
        printnum(putch, putdat, result, base, width - 1, padc);
c01085fa:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01085fd:	8d 50 ff             	lea    -0x1(%eax),%edx
c0108600:	8b 45 20             	mov    0x20(%ebp),%eax
c0108603:	89 44 24 18          	mov    %eax,0x18(%esp)
c0108607:	89 54 24 14          	mov    %edx,0x14(%esp)
c010860b:	8b 45 18             	mov    0x18(%ebp),%eax
c010860e:	89 44 24 10          	mov    %eax,0x10(%esp)
c0108612:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108615:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108618:	89 44 24 08          	mov    %eax,0x8(%esp)
c010861c:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0108620:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108623:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108627:	8b 45 08             	mov    0x8(%ebp),%eax
c010862a:	89 04 24             	mov    %eax,(%esp)
c010862d:	e8 3d ff ff ff       	call   c010856f <printnum>
c0108632:	eb 1b                	jmp    c010864f <printnum+0xe0>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0108634:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108637:	89 44 24 04          	mov    %eax,0x4(%esp)
c010863b:	8b 45 20             	mov    0x20(%ebp),%eax
c010863e:	89 04 24             	mov    %eax,(%esp)
c0108641:	8b 45 08             	mov    0x8(%ebp),%eax
c0108644:	ff d0                	call   *%eax
        while (-- width > 0)
c0108646:	ff 4d 1c             	decl   0x1c(%ebp)
c0108649:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010864d:	7f e5                	jg     c0108634 <printnum+0xc5>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c010864f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108652:	05 d8 b0 10 c0       	add    $0xc010b0d8,%eax
c0108657:	0f b6 00             	movzbl (%eax),%eax
c010865a:	0f be c0             	movsbl %al,%eax
c010865d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108660:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108664:	89 04 24             	mov    %eax,(%esp)
c0108667:	8b 45 08             	mov    0x8(%ebp),%eax
c010866a:	ff d0                	call   *%eax
}
c010866c:	90                   	nop
c010866d:	89 ec                	mov    %ebp,%esp
c010866f:	5d                   	pop    %ebp
c0108670:	c3                   	ret    

c0108671 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c0108671:	55                   	push   %ebp
c0108672:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0108674:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0108678:	7e 14                	jle    c010868e <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c010867a:	8b 45 08             	mov    0x8(%ebp),%eax
c010867d:	8b 00                	mov    (%eax),%eax
c010867f:	8d 48 08             	lea    0x8(%eax),%ecx
c0108682:	8b 55 08             	mov    0x8(%ebp),%edx
c0108685:	89 0a                	mov    %ecx,(%edx)
c0108687:	8b 50 04             	mov    0x4(%eax),%edx
c010868a:	8b 00                	mov    (%eax),%eax
c010868c:	eb 30                	jmp    c01086be <getuint+0x4d>
    }
    else if (lflag) {
c010868e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0108692:	74 16                	je     c01086aa <getuint+0x39>
        return va_arg(*ap, unsigned long);
c0108694:	8b 45 08             	mov    0x8(%ebp),%eax
c0108697:	8b 00                	mov    (%eax),%eax
c0108699:	8d 48 04             	lea    0x4(%eax),%ecx
c010869c:	8b 55 08             	mov    0x8(%ebp),%edx
c010869f:	89 0a                	mov    %ecx,(%edx)
c01086a1:	8b 00                	mov    (%eax),%eax
c01086a3:	ba 00 00 00 00       	mov    $0x0,%edx
c01086a8:	eb 14                	jmp    c01086be <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c01086aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01086ad:	8b 00                	mov    (%eax),%eax
c01086af:	8d 48 04             	lea    0x4(%eax),%ecx
c01086b2:	8b 55 08             	mov    0x8(%ebp),%edx
c01086b5:	89 0a                	mov    %ecx,(%edx)
c01086b7:	8b 00                	mov    (%eax),%eax
c01086b9:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c01086be:	5d                   	pop    %ebp
c01086bf:	c3                   	ret    

c01086c0 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c01086c0:	55                   	push   %ebp
c01086c1:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01086c3:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01086c7:	7e 14                	jle    c01086dd <getint+0x1d>
        return va_arg(*ap, long long);
c01086c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01086cc:	8b 00                	mov    (%eax),%eax
c01086ce:	8d 48 08             	lea    0x8(%eax),%ecx
c01086d1:	8b 55 08             	mov    0x8(%ebp),%edx
c01086d4:	89 0a                	mov    %ecx,(%edx)
c01086d6:	8b 50 04             	mov    0x4(%eax),%edx
c01086d9:	8b 00                	mov    (%eax),%eax
c01086db:	eb 28                	jmp    c0108705 <getint+0x45>
    }
    else if (lflag) {
c01086dd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01086e1:	74 12                	je     c01086f5 <getint+0x35>
        return va_arg(*ap, long);
c01086e3:	8b 45 08             	mov    0x8(%ebp),%eax
c01086e6:	8b 00                	mov    (%eax),%eax
c01086e8:	8d 48 04             	lea    0x4(%eax),%ecx
c01086eb:	8b 55 08             	mov    0x8(%ebp),%edx
c01086ee:	89 0a                	mov    %ecx,(%edx)
c01086f0:	8b 00                	mov    (%eax),%eax
c01086f2:	99                   	cltd   
c01086f3:	eb 10                	jmp    c0108705 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c01086f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01086f8:	8b 00                	mov    (%eax),%eax
c01086fa:	8d 48 04             	lea    0x4(%eax),%ecx
c01086fd:	8b 55 08             	mov    0x8(%ebp),%edx
c0108700:	89 0a                	mov    %ecx,(%edx)
c0108702:	8b 00                	mov    (%eax),%eax
c0108704:	99                   	cltd   
    }
}
c0108705:	5d                   	pop    %ebp
c0108706:	c3                   	ret    

c0108707 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c0108707:	55                   	push   %ebp
c0108708:	89 e5                	mov    %esp,%ebp
c010870a:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c010870d:	8d 45 14             	lea    0x14(%ebp),%eax
c0108710:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0108713:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108716:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010871a:	8b 45 10             	mov    0x10(%ebp),%eax
c010871d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108721:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108724:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108728:	8b 45 08             	mov    0x8(%ebp),%eax
c010872b:	89 04 24             	mov    %eax,(%esp)
c010872e:	e8 05 00 00 00       	call   c0108738 <vprintfmt>
    va_end(ap);
}
c0108733:	90                   	nop
c0108734:	89 ec                	mov    %ebp,%esp
c0108736:	5d                   	pop    %ebp
c0108737:	c3                   	ret    

c0108738 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0108738:	55                   	push   %ebp
c0108739:	89 e5                	mov    %esp,%ebp
c010873b:	56                   	push   %esi
c010873c:	53                   	push   %ebx
c010873d:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0108740:	eb 17                	jmp    c0108759 <vprintfmt+0x21>
            if (ch == '\0') {
c0108742:	85 db                	test   %ebx,%ebx
c0108744:	0f 84 bf 03 00 00    	je     c0108b09 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c010874a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010874d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108751:	89 1c 24             	mov    %ebx,(%esp)
c0108754:	8b 45 08             	mov    0x8(%ebp),%eax
c0108757:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0108759:	8b 45 10             	mov    0x10(%ebp),%eax
c010875c:	8d 50 01             	lea    0x1(%eax),%edx
c010875f:	89 55 10             	mov    %edx,0x10(%ebp)
c0108762:	0f b6 00             	movzbl (%eax),%eax
c0108765:	0f b6 d8             	movzbl %al,%ebx
c0108768:	83 fb 25             	cmp    $0x25,%ebx
c010876b:	75 d5                	jne    c0108742 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c010876d:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0108771:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0108778:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010877b:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c010877e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0108785:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108788:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c010878b:	8b 45 10             	mov    0x10(%ebp),%eax
c010878e:	8d 50 01             	lea    0x1(%eax),%edx
c0108791:	89 55 10             	mov    %edx,0x10(%ebp)
c0108794:	0f b6 00             	movzbl (%eax),%eax
c0108797:	0f b6 d8             	movzbl %al,%ebx
c010879a:	8d 43 dd             	lea    -0x23(%ebx),%eax
c010879d:	83 f8 55             	cmp    $0x55,%eax
c01087a0:	0f 87 37 03 00 00    	ja     c0108add <vprintfmt+0x3a5>
c01087a6:	8b 04 85 fc b0 10 c0 	mov    -0x3fef4f04(,%eax,4),%eax
c01087ad:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c01087af:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c01087b3:	eb d6                	jmp    c010878b <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c01087b5:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c01087b9:	eb d0                	jmp    c010878b <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c01087bb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c01087c2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01087c5:	89 d0                	mov    %edx,%eax
c01087c7:	c1 e0 02             	shl    $0x2,%eax
c01087ca:	01 d0                	add    %edx,%eax
c01087cc:	01 c0                	add    %eax,%eax
c01087ce:	01 d8                	add    %ebx,%eax
c01087d0:	83 e8 30             	sub    $0x30,%eax
c01087d3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c01087d6:	8b 45 10             	mov    0x10(%ebp),%eax
c01087d9:	0f b6 00             	movzbl (%eax),%eax
c01087dc:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c01087df:	83 fb 2f             	cmp    $0x2f,%ebx
c01087e2:	7e 38                	jle    c010881c <vprintfmt+0xe4>
c01087e4:	83 fb 39             	cmp    $0x39,%ebx
c01087e7:	7f 33                	jg     c010881c <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
c01087e9:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c01087ec:	eb d4                	jmp    c01087c2 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c01087ee:	8b 45 14             	mov    0x14(%ebp),%eax
c01087f1:	8d 50 04             	lea    0x4(%eax),%edx
c01087f4:	89 55 14             	mov    %edx,0x14(%ebp)
c01087f7:	8b 00                	mov    (%eax),%eax
c01087f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c01087fc:	eb 1f                	jmp    c010881d <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c01087fe:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108802:	79 87                	jns    c010878b <vprintfmt+0x53>
                width = 0;
c0108804:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c010880b:	e9 7b ff ff ff       	jmp    c010878b <vprintfmt+0x53>

        case '#':
            altflag = 1;
c0108810:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0108817:	e9 6f ff ff ff       	jmp    c010878b <vprintfmt+0x53>
            goto process_precision;
c010881c:	90                   	nop

        process_precision:
            if (width < 0)
c010881d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108821:	0f 89 64 ff ff ff    	jns    c010878b <vprintfmt+0x53>
                width = precision, precision = -1;
c0108827:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010882a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010882d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0108834:	e9 52 ff ff ff       	jmp    c010878b <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0108839:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c010883c:	e9 4a ff ff ff       	jmp    c010878b <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0108841:	8b 45 14             	mov    0x14(%ebp),%eax
c0108844:	8d 50 04             	lea    0x4(%eax),%edx
c0108847:	89 55 14             	mov    %edx,0x14(%ebp)
c010884a:	8b 00                	mov    (%eax),%eax
c010884c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010884f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108853:	89 04 24             	mov    %eax,(%esp)
c0108856:	8b 45 08             	mov    0x8(%ebp),%eax
c0108859:	ff d0                	call   *%eax
            break;
c010885b:	e9 a4 02 00 00       	jmp    c0108b04 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0108860:	8b 45 14             	mov    0x14(%ebp),%eax
c0108863:	8d 50 04             	lea    0x4(%eax),%edx
c0108866:	89 55 14             	mov    %edx,0x14(%ebp)
c0108869:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c010886b:	85 db                	test   %ebx,%ebx
c010886d:	79 02                	jns    c0108871 <vprintfmt+0x139>
                err = -err;
c010886f:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0108871:	83 fb 06             	cmp    $0x6,%ebx
c0108874:	7f 0b                	jg     c0108881 <vprintfmt+0x149>
c0108876:	8b 34 9d bc b0 10 c0 	mov    -0x3fef4f44(,%ebx,4),%esi
c010887d:	85 f6                	test   %esi,%esi
c010887f:	75 23                	jne    c01088a4 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c0108881:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0108885:	c7 44 24 08 e9 b0 10 	movl   $0xc010b0e9,0x8(%esp)
c010888c:	c0 
c010888d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108890:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108894:	8b 45 08             	mov    0x8(%ebp),%eax
c0108897:	89 04 24             	mov    %eax,(%esp)
c010889a:	e8 68 fe ff ff       	call   c0108707 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c010889f:	e9 60 02 00 00       	jmp    c0108b04 <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
c01088a4:	89 74 24 0c          	mov    %esi,0xc(%esp)
c01088a8:	c7 44 24 08 f2 b0 10 	movl   $0xc010b0f2,0x8(%esp)
c01088af:	c0 
c01088b0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01088b3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01088b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01088ba:	89 04 24             	mov    %eax,(%esp)
c01088bd:	e8 45 fe ff ff       	call   c0108707 <printfmt>
            break;
c01088c2:	e9 3d 02 00 00       	jmp    c0108b04 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c01088c7:	8b 45 14             	mov    0x14(%ebp),%eax
c01088ca:	8d 50 04             	lea    0x4(%eax),%edx
c01088cd:	89 55 14             	mov    %edx,0x14(%ebp)
c01088d0:	8b 30                	mov    (%eax),%esi
c01088d2:	85 f6                	test   %esi,%esi
c01088d4:	75 05                	jne    c01088db <vprintfmt+0x1a3>
                p = "(null)";
c01088d6:	be f5 b0 10 c0       	mov    $0xc010b0f5,%esi
            }
            if (width > 0 && padc != '-') {
c01088db:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01088df:	7e 76                	jle    c0108957 <vprintfmt+0x21f>
c01088e1:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c01088e5:	74 70                	je     c0108957 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c01088e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01088ea:	89 44 24 04          	mov    %eax,0x4(%esp)
c01088ee:	89 34 24             	mov    %esi,(%esp)
c01088f1:	e8 ee 03 00 00       	call   c0108ce4 <strnlen>
c01088f6:	89 c2                	mov    %eax,%edx
c01088f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01088fb:	29 d0                	sub    %edx,%eax
c01088fd:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108900:	eb 16                	jmp    c0108918 <vprintfmt+0x1e0>
                    putch(padc, putdat);
c0108902:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0108906:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108909:	89 54 24 04          	mov    %edx,0x4(%esp)
c010890d:	89 04 24             	mov    %eax,(%esp)
c0108910:	8b 45 08             	mov    0x8(%ebp),%eax
c0108913:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c0108915:	ff 4d e8             	decl   -0x18(%ebp)
c0108918:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010891c:	7f e4                	jg     c0108902 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010891e:	eb 37                	jmp    c0108957 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c0108920:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0108924:	74 1f                	je     c0108945 <vprintfmt+0x20d>
c0108926:	83 fb 1f             	cmp    $0x1f,%ebx
c0108929:	7e 05                	jle    c0108930 <vprintfmt+0x1f8>
c010892b:	83 fb 7e             	cmp    $0x7e,%ebx
c010892e:	7e 15                	jle    c0108945 <vprintfmt+0x20d>
                    putch('?', putdat);
c0108930:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108933:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108937:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c010893e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108941:	ff d0                	call   *%eax
c0108943:	eb 0f                	jmp    c0108954 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c0108945:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108948:	89 44 24 04          	mov    %eax,0x4(%esp)
c010894c:	89 1c 24             	mov    %ebx,(%esp)
c010894f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108952:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0108954:	ff 4d e8             	decl   -0x18(%ebp)
c0108957:	89 f0                	mov    %esi,%eax
c0108959:	8d 70 01             	lea    0x1(%eax),%esi
c010895c:	0f b6 00             	movzbl (%eax),%eax
c010895f:	0f be d8             	movsbl %al,%ebx
c0108962:	85 db                	test   %ebx,%ebx
c0108964:	74 27                	je     c010898d <vprintfmt+0x255>
c0108966:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010896a:	78 b4                	js     c0108920 <vprintfmt+0x1e8>
c010896c:	ff 4d e4             	decl   -0x1c(%ebp)
c010896f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0108973:	79 ab                	jns    c0108920 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
c0108975:	eb 16                	jmp    c010898d <vprintfmt+0x255>
                putch(' ', putdat);
c0108977:	8b 45 0c             	mov    0xc(%ebp),%eax
c010897a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010897e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0108985:	8b 45 08             	mov    0x8(%ebp),%eax
c0108988:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c010898a:	ff 4d e8             	decl   -0x18(%ebp)
c010898d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108991:	7f e4                	jg     c0108977 <vprintfmt+0x23f>
            }
            break;
c0108993:	e9 6c 01 00 00       	jmp    c0108b04 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0108998:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010899b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010899f:	8d 45 14             	lea    0x14(%ebp),%eax
c01089a2:	89 04 24             	mov    %eax,(%esp)
c01089a5:	e8 16 fd ff ff       	call   c01086c0 <getint>
c01089aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01089ad:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c01089b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01089b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01089b6:	85 d2                	test   %edx,%edx
c01089b8:	79 26                	jns    c01089e0 <vprintfmt+0x2a8>
                putch('-', putdat);
c01089ba:	8b 45 0c             	mov    0xc(%ebp),%eax
c01089bd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01089c1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c01089c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01089cb:	ff d0                	call   *%eax
                num = -(long long)num;
c01089cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01089d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01089d3:	f7 d8                	neg    %eax
c01089d5:	83 d2 00             	adc    $0x0,%edx
c01089d8:	f7 da                	neg    %edx
c01089da:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01089dd:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c01089e0:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01089e7:	e9 a8 00 00 00       	jmp    c0108a94 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c01089ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01089ef:	89 44 24 04          	mov    %eax,0x4(%esp)
c01089f3:	8d 45 14             	lea    0x14(%ebp),%eax
c01089f6:	89 04 24             	mov    %eax,(%esp)
c01089f9:	e8 73 fc ff ff       	call   c0108671 <getuint>
c01089fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108a01:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0108a04:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0108a0b:	e9 84 00 00 00       	jmp    c0108a94 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0108a10:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108a13:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108a17:	8d 45 14             	lea    0x14(%ebp),%eax
c0108a1a:	89 04 24             	mov    %eax,(%esp)
c0108a1d:	e8 4f fc ff ff       	call   c0108671 <getuint>
c0108a22:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108a25:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0108a28:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0108a2f:	eb 63                	jmp    c0108a94 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c0108a31:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108a34:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108a38:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0108a3f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a42:	ff d0                	call   *%eax
            putch('x', putdat);
c0108a44:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108a47:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108a4b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0108a52:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a55:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0108a57:	8b 45 14             	mov    0x14(%ebp),%eax
c0108a5a:	8d 50 04             	lea    0x4(%eax),%edx
c0108a5d:	89 55 14             	mov    %edx,0x14(%ebp)
c0108a60:	8b 00                	mov    (%eax),%eax
c0108a62:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108a65:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0108a6c:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0108a73:	eb 1f                	jmp    c0108a94 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0108a75:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108a78:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108a7c:	8d 45 14             	lea    0x14(%ebp),%eax
c0108a7f:	89 04 24             	mov    %eax,(%esp)
c0108a82:	e8 ea fb ff ff       	call   c0108671 <getuint>
c0108a87:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108a8a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0108a8d:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0108a94:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0108a98:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108a9b:	89 54 24 18          	mov    %edx,0x18(%esp)
c0108a9f:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0108aa2:	89 54 24 14          	mov    %edx,0x14(%esp)
c0108aa6:	89 44 24 10          	mov    %eax,0x10(%esp)
c0108aaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108aad:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108ab0:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108ab4:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0108ab8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108abb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108abf:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ac2:	89 04 24             	mov    %eax,(%esp)
c0108ac5:	e8 a5 fa ff ff       	call   c010856f <printnum>
            break;
c0108aca:	eb 38                	jmp    c0108b04 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0108acc:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108acf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108ad3:	89 1c 24             	mov    %ebx,(%esp)
c0108ad6:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ad9:	ff d0                	call   *%eax
            break;
c0108adb:	eb 27                	jmp    c0108b04 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0108add:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108ae0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108ae4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0108aeb:	8b 45 08             	mov    0x8(%ebp),%eax
c0108aee:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0108af0:	ff 4d 10             	decl   0x10(%ebp)
c0108af3:	eb 03                	jmp    c0108af8 <vprintfmt+0x3c0>
c0108af5:	ff 4d 10             	decl   0x10(%ebp)
c0108af8:	8b 45 10             	mov    0x10(%ebp),%eax
c0108afb:	48                   	dec    %eax
c0108afc:	0f b6 00             	movzbl (%eax),%eax
c0108aff:	3c 25                	cmp    $0x25,%al
c0108b01:	75 f2                	jne    c0108af5 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c0108b03:	90                   	nop
    while (1) {
c0108b04:	e9 37 fc ff ff       	jmp    c0108740 <vprintfmt+0x8>
                return;
c0108b09:	90                   	nop
        }
    }
}
c0108b0a:	83 c4 40             	add    $0x40,%esp
c0108b0d:	5b                   	pop    %ebx
c0108b0e:	5e                   	pop    %esi
c0108b0f:	5d                   	pop    %ebp
c0108b10:	c3                   	ret    

c0108b11 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0108b11:	55                   	push   %ebp
c0108b12:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0108b14:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b17:	8b 40 08             	mov    0x8(%eax),%eax
c0108b1a:	8d 50 01             	lea    0x1(%eax),%edx
c0108b1d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b20:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0108b23:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b26:	8b 10                	mov    (%eax),%edx
c0108b28:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b2b:	8b 40 04             	mov    0x4(%eax),%eax
c0108b2e:	39 c2                	cmp    %eax,%edx
c0108b30:	73 12                	jae    c0108b44 <sprintputch+0x33>
        *b->buf ++ = ch;
c0108b32:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b35:	8b 00                	mov    (%eax),%eax
c0108b37:	8d 48 01             	lea    0x1(%eax),%ecx
c0108b3a:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108b3d:	89 0a                	mov    %ecx,(%edx)
c0108b3f:	8b 55 08             	mov    0x8(%ebp),%edx
c0108b42:	88 10                	mov    %dl,(%eax)
    }
}
c0108b44:	90                   	nop
c0108b45:	5d                   	pop    %ebp
c0108b46:	c3                   	ret    

c0108b47 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0108b47:	55                   	push   %ebp
c0108b48:	89 e5                	mov    %esp,%ebp
c0108b4a:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0108b4d:	8d 45 14             	lea    0x14(%ebp),%eax
c0108b50:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0108b53:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108b56:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108b5a:	8b 45 10             	mov    0x10(%ebp),%eax
c0108b5d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108b61:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b64:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108b68:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b6b:	89 04 24             	mov    %eax,(%esp)
c0108b6e:	e8 0a 00 00 00       	call   c0108b7d <vsnprintf>
c0108b73:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0108b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108b79:	89 ec                	mov    %ebp,%esp
c0108b7b:	5d                   	pop    %ebp
c0108b7c:	c3                   	ret    

c0108b7d <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0108b7d:	55                   	push   %ebp
c0108b7e:	89 e5                	mov    %esp,%ebp
c0108b80:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0108b83:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b86:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108b89:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b8c:	8d 50 ff             	lea    -0x1(%eax),%edx
c0108b8f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b92:	01 d0                	add    %edx,%eax
c0108b94:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108b97:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0108b9e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108ba2:	74 0a                	je     c0108bae <vsnprintf+0x31>
c0108ba4:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108ba7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108baa:	39 c2                	cmp    %eax,%edx
c0108bac:	76 07                	jbe    c0108bb5 <vsnprintf+0x38>
        return -E_INVAL;
c0108bae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0108bb3:	eb 2a                	jmp    c0108bdf <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0108bb5:	8b 45 14             	mov    0x14(%ebp),%eax
c0108bb8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108bbc:	8b 45 10             	mov    0x10(%ebp),%eax
c0108bbf:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108bc3:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0108bc6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108bca:	c7 04 24 11 8b 10 c0 	movl   $0xc0108b11,(%esp)
c0108bd1:	e8 62 fb ff ff       	call   c0108738 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0108bd6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108bd9:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0108bdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108bdf:	89 ec                	mov    %ebp,%esp
c0108be1:	5d                   	pop    %ebp
c0108be2:	c3                   	ret    

c0108be3 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c0108be3:	55                   	push   %ebp
c0108be4:	89 e5                	mov    %esp,%ebp
c0108be6:	57                   	push   %edi
c0108be7:	56                   	push   %esi
c0108be8:	53                   	push   %ebx
c0108be9:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c0108bec:	a1 60 3a 12 c0       	mov    0xc0123a60,%eax
c0108bf1:	8b 15 64 3a 12 c0    	mov    0xc0123a64,%edx
c0108bf7:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c0108bfd:	6b f0 05             	imul   $0x5,%eax,%esi
c0108c00:	01 fe                	add    %edi,%esi
c0108c02:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
c0108c07:	f7 e7                	mul    %edi
c0108c09:	01 d6                	add    %edx,%esi
c0108c0b:	89 f2                	mov    %esi,%edx
c0108c0d:	83 c0 0b             	add    $0xb,%eax
c0108c10:	83 d2 00             	adc    $0x0,%edx
c0108c13:	89 c7                	mov    %eax,%edi
c0108c15:	83 e7 ff             	and    $0xffffffff,%edi
c0108c18:	89 f9                	mov    %edi,%ecx
c0108c1a:	0f b7 da             	movzwl %dx,%ebx
c0108c1d:	89 0d 60 3a 12 c0    	mov    %ecx,0xc0123a60
c0108c23:	89 1d 64 3a 12 c0    	mov    %ebx,0xc0123a64
    unsigned long long result = (next >> 12);
c0108c29:	a1 60 3a 12 c0       	mov    0xc0123a60,%eax
c0108c2e:	8b 15 64 3a 12 c0    	mov    0xc0123a64,%edx
c0108c34:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0108c38:	c1 ea 0c             	shr    $0xc,%edx
c0108c3b:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108c3e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c0108c41:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c0108c48:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108c4b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108c4e:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108c51:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0108c54:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c57:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108c5a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108c5e:	74 1c                	je     c0108c7c <rand+0x99>
c0108c60:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c63:	ba 00 00 00 00       	mov    $0x0,%edx
c0108c68:	f7 75 dc             	divl   -0x24(%ebp)
c0108c6b:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0108c6e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c71:	ba 00 00 00 00       	mov    $0x0,%edx
c0108c76:	f7 75 dc             	divl   -0x24(%ebp)
c0108c79:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108c7c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108c7f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108c82:	f7 75 dc             	divl   -0x24(%ebp)
c0108c85:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108c88:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0108c8b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108c8e:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0108c91:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108c94:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0108c97:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c0108c9a:	83 c4 24             	add    $0x24,%esp
c0108c9d:	5b                   	pop    %ebx
c0108c9e:	5e                   	pop    %esi
c0108c9f:	5f                   	pop    %edi
c0108ca0:	5d                   	pop    %ebp
c0108ca1:	c3                   	ret    

c0108ca2 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c0108ca2:	55                   	push   %ebp
c0108ca3:	89 e5                	mov    %esp,%ebp
    next = seed;
c0108ca5:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ca8:	ba 00 00 00 00       	mov    $0x0,%edx
c0108cad:	a3 60 3a 12 c0       	mov    %eax,0xc0123a60
c0108cb2:	89 15 64 3a 12 c0    	mov    %edx,0xc0123a64
}
c0108cb8:	90                   	nop
c0108cb9:	5d                   	pop    %ebp
c0108cba:	c3                   	ret    

c0108cbb <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0108cbb:	55                   	push   %ebp
c0108cbc:	89 e5                	mov    %esp,%ebp
c0108cbe:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0108cc1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0108cc8:	eb 03                	jmp    c0108ccd <strlen+0x12>
        cnt ++;
c0108cca:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c0108ccd:	8b 45 08             	mov    0x8(%ebp),%eax
c0108cd0:	8d 50 01             	lea    0x1(%eax),%edx
c0108cd3:	89 55 08             	mov    %edx,0x8(%ebp)
c0108cd6:	0f b6 00             	movzbl (%eax),%eax
c0108cd9:	84 c0                	test   %al,%al
c0108cdb:	75 ed                	jne    c0108cca <strlen+0xf>
    }
    return cnt;
c0108cdd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0108ce0:	89 ec                	mov    %ebp,%esp
c0108ce2:	5d                   	pop    %ebp
c0108ce3:	c3                   	ret    

c0108ce4 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0108ce4:	55                   	push   %ebp
c0108ce5:	89 e5                	mov    %esp,%ebp
c0108ce7:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0108cea:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0108cf1:	eb 03                	jmp    c0108cf6 <strnlen+0x12>
        cnt ++;
c0108cf3:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0108cf6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108cf9:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108cfc:	73 10                	jae    c0108d0e <strnlen+0x2a>
c0108cfe:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d01:	8d 50 01             	lea    0x1(%eax),%edx
c0108d04:	89 55 08             	mov    %edx,0x8(%ebp)
c0108d07:	0f b6 00             	movzbl (%eax),%eax
c0108d0a:	84 c0                	test   %al,%al
c0108d0c:	75 e5                	jne    c0108cf3 <strnlen+0xf>
    }
    return cnt;
c0108d0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0108d11:	89 ec                	mov    %ebp,%esp
c0108d13:	5d                   	pop    %ebp
c0108d14:	c3                   	ret    

c0108d15 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0108d15:	55                   	push   %ebp
c0108d16:	89 e5                	mov    %esp,%ebp
c0108d18:	57                   	push   %edi
c0108d19:	56                   	push   %esi
c0108d1a:	83 ec 20             	sub    $0x20,%esp
c0108d1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d20:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108d23:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108d26:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0108d29:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108d2f:	89 d1                	mov    %edx,%ecx
c0108d31:	89 c2                	mov    %eax,%edx
c0108d33:	89 ce                	mov    %ecx,%esi
c0108d35:	89 d7                	mov    %edx,%edi
c0108d37:	ac                   	lods   %ds:(%esi),%al
c0108d38:	aa                   	stos   %al,%es:(%edi)
c0108d39:	84 c0                	test   %al,%al
c0108d3b:	75 fa                	jne    c0108d37 <strcpy+0x22>
c0108d3d:	89 fa                	mov    %edi,%edx
c0108d3f:	89 f1                	mov    %esi,%ecx
c0108d41:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0108d44:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0108d47:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0108d4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0108d4d:	83 c4 20             	add    $0x20,%esp
c0108d50:	5e                   	pop    %esi
c0108d51:	5f                   	pop    %edi
c0108d52:	5d                   	pop    %ebp
c0108d53:	c3                   	ret    

c0108d54 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0108d54:	55                   	push   %ebp
c0108d55:	89 e5                	mov    %esp,%ebp
c0108d57:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0108d5a:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d5d:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0108d60:	eb 1e                	jmp    c0108d80 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c0108d62:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108d65:	0f b6 10             	movzbl (%eax),%edx
c0108d68:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108d6b:	88 10                	mov    %dl,(%eax)
c0108d6d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108d70:	0f b6 00             	movzbl (%eax),%eax
c0108d73:	84 c0                	test   %al,%al
c0108d75:	74 03                	je     c0108d7a <strncpy+0x26>
            src ++;
c0108d77:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c0108d7a:	ff 45 fc             	incl   -0x4(%ebp)
c0108d7d:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c0108d80:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108d84:	75 dc                	jne    c0108d62 <strncpy+0xe>
    }
    return dst;
c0108d86:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0108d89:	89 ec                	mov    %ebp,%esp
c0108d8b:	5d                   	pop    %ebp
c0108d8c:	c3                   	ret    

c0108d8d <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0108d8d:	55                   	push   %ebp
c0108d8e:	89 e5                	mov    %esp,%ebp
c0108d90:	57                   	push   %edi
c0108d91:	56                   	push   %esi
c0108d92:	83 ec 20             	sub    $0x20,%esp
c0108d95:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d98:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108d9b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108d9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c0108da1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108da4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108da7:	89 d1                	mov    %edx,%ecx
c0108da9:	89 c2                	mov    %eax,%edx
c0108dab:	89 ce                	mov    %ecx,%esi
c0108dad:	89 d7                	mov    %edx,%edi
c0108daf:	ac                   	lods   %ds:(%esi),%al
c0108db0:	ae                   	scas   %es:(%edi),%al
c0108db1:	75 08                	jne    c0108dbb <strcmp+0x2e>
c0108db3:	84 c0                	test   %al,%al
c0108db5:	75 f8                	jne    c0108daf <strcmp+0x22>
c0108db7:	31 c0                	xor    %eax,%eax
c0108db9:	eb 04                	jmp    c0108dbf <strcmp+0x32>
c0108dbb:	19 c0                	sbb    %eax,%eax
c0108dbd:	0c 01                	or     $0x1,%al
c0108dbf:	89 fa                	mov    %edi,%edx
c0108dc1:	89 f1                	mov    %esi,%ecx
c0108dc3:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108dc6:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0108dc9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c0108dcc:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0108dcf:	83 c4 20             	add    $0x20,%esp
c0108dd2:	5e                   	pop    %esi
c0108dd3:	5f                   	pop    %edi
c0108dd4:	5d                   	pop    %ebp
c0108dd5:	c3                   	ret    

c0108dd6 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0108dd6:	55                   	push   %ebp
c0108dd7:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0108dd9:	eb 09                	jmp    c0108de4 <strncmp+0xe>
        n --, s1 ++, s2 ++;
c0108ddb:	ff 4d 10             	decl   0x10(%ebp)
c0108dde:	ff 45 08             	incl   0x8(%ebp)
c0108de1:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0108de4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108de8:	74 1a                	je     c0108e04 <strncmp+0x2e>
c0108dea:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ded:	0f b6 00             	movzbl (%eax),%eax
c0108df0:	84 c0                	test   %al,%al
c0108df2:	74 10                	je     c0108e04 <strncmp+0x2e>
c0108df4:	8b 45 08             	mov    0x8(%ebp),%eax
c0108df7:	0f b6 10             	movzbl (%eax),%edx
c0108dfa:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108dfd:	0f b6 00             	movzbl (%eax),%eax
c0108e00:	38 c2                	cmp    %al,%dl
c0108e02:	74 d7                	je     c0108ddb <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0108e04:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108e08:	74 18                	je     c0108e22 <strncmp+0x4c>
c0108e0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e0d:	0f b6 00             	movzbl (%eax),%eax
c0108e10:	0f b6 d0             	movzbl %al,%edx
c0108e13:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108e16:	0f b6 00             	movzbl (%eax),%eax
c0108e19:	0f b6 c8             	movzbl %al,%ecx
c0108e1c:	89 d0                	mov    %edx,%eax
c0108e1e:	29 c8                	sub    %ecx,%eax
c0108e20:	eb 05                	jmp    c0108e27 <strncmp+0x51>
c0108e22:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108e27:	5d                   	pop    %ebp
c0108e28:	c3                   	ret    

c0108e29 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0108e29:	55                   	push   %ebp
c0108e2a:	89 e5                	mov    %esp,%ebp
c0108e2c:	83 ec 04             	sub    $0x4,%esp
c0108e2f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108e32:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0108e35:	eb 13                	jmp    c0108e4a <strchr+0x21>
        if (*s == c) {
c0108e37:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e3a:	0f b6 00             	movzbl (%eax),%eax
c0108e3d:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0108e40:	75 05                	jne    c0108e47 <strchr+0x1e>
            return (char *)s;
c0108e42:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e45:	eb 12                	jmp    c0108e59 <strchr+0x30>
        }
        s ++;
c0108e47:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0108e4a:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e4d:	0f b6 00             	movzbl (%eax),%eax
c0108e50:	84 c0                	test   %al,%al
c0108e52:	75 e3                	jne    c0108e37 <strchr+0xe>
    }
    return NULL;
c0108e54:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108e59:	89 ec                	mov    %ebp,%esp
c0108e5b:	5d                   	pop    %ebp
c0108e5c:	c3                   	ret    

c0108e5d <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0108e5d:	55                   	push   %ebp
c0108e5e:	89 e5                	mov    %esp,%ebp
c0108e60:	83 ec 04             	sub    $0x4,%esp
c0108e63:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108e66:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0108e69:	eb 0e                	jmp    c0108e79 <strfind+0x1c>
        if (*s == c) {
c0108e6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e6e:	0f b6 00             	movzbl (%eax),%eax
c0108e71:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0108e74:	74 0f                	je     c0108e85 <strfind+0x28>
            break;
        }
        s ++;
c0108e76:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0108e79:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e7c:	0f b6 00             	movzbl (%eax),%eax
c0108e7f:	84 c0                	test   %al,%al
c0108e81:	75 e8                	jne    c0108e6b <strfind+0xe>
c0108e83:	eb 01                	jmp    c0108e86 <strfind+0x29>
            break;
c0108e85:	90                   	nop
    }
    return (char *)s;
c0108e86:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0108e89:	89 ec                	mov    %ebp,%esp
c0108e8b:	5d                   	pop    %ebp
c0108e8c:	c3                   	ret    

c0108e8d <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0108e8d:	55                   	push   %ebp
c0108e8e:	89 e5                	mov    %esp,%ebp
c0108e90:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0108e93:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0108e9a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0108ea1:	eb 03                	jmp    c0108ea6 <strtol+0x19>
        s ++;
c0108ea3:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c0108ea6:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ea9:	0f b6 00             	movzbl (%eax),%eax
c0108eac:	3c 20                	cmp    $0x20,%al
c0108eae:	74 f3                	je     c0108ea3 <strtol+0x16>
c0108eb0:	8b 45 08             	mov    0x8(%ebp),%eax
c0108eb3:	0f b6 00             	movzbl (%eax),%eax
c0108eb6:	3c 09                	cmp    $0x9,%al
c0108eb8:	74 e9                	je     c0108ea3 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c0108eba:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ebd:	0f b6 00             	movzbl (%eax),%eax
c0108ec0:	3c 2b                	cmp    $0x2b,%al
c0108ec2:	75 05                	jne    c0108ec9 <strtol+0x3c>
        s ++;
c0108ec4:	ff 45 08             	incl   0x8(%ebp)
c0108ec7:	eb 14                	jmp    c0108edd <strtol+0x50>
    }
    else if (*s == '-') {
c0108ec9:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ecc:	0f b6 00             	movzbl (%eax),%eax
c0108ecf:	3c 2d                	cmp    $0x2d,%al
c0108ed1:	75 0a                	jne    c0108edd <strtol+0x50>
        s ++, neg = 1;
c0108ed3:	ff 45 08             	incl   0x8(%ebp)
c0108ed6:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0108edd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108ee1:	74 06                	je     c0108ee9 <strtol+0x5c>
c0108ee3:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0108ee7:	75 22                	jne    c0108f0b <strtol+0x7e>
c0108ee9:	8b 45 08             	mov    0x8(%ebp),%eax
c0108eec:	0f b6 00             	movzbl (%eax),%eax
c0108eef:	3c 30                	cmp    $0x30,%al
c0108ef1:	75 18                	jne    c0108f0b <strtol+0x7e>
c0108ef3:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ef6:	40                   	inc    %eax
c0108ef7:	0f b6 00             	movzbl (%eax),%eax
c0108efa:	3c 78                	cmp    $0x78,%al
c0108efc:	75 0d                	jne    c0108f0b <strtol+0x7e>
        s += 2, base = 16;
c0108efe:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0108f02:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0108f09:	eb 29                	jmp    c0108f34 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c0108f0b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108f0f:	75 16                	jne    c0108f27 <strtol+0x9a>
c0108f11:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f14:	0f b6 00             	movzbl (%eax),%eax
c0108f17:	3c 30                	cmp    $0x30,%al
c0108f19:	75 0c                	jne    c0108f27 <strtol+0x9a>
        s ++, base = 8;
c0108f1b:	ff 45 08             	incl   0x8(%ebp)
c0108f1e:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0108f25:	eb 0d                	jmp    c0108f34 <strtol+0xa7>
    }
    else if (base == 0) {
c0108f27:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108f2b:	75 07                	jne    c0108f34 <strtol+0xa7>
        base = 10;
c0108f2d:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0108f34:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f37:	0f b6 00             	movzbl (%eax),%eax
c0108f3a:	3c 2f                	cmp    $0x2f,%al
c0108f3c:	7e 1b                	jle    c0108f59 <strtol+0xcc>
c0108f3e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f41:	0f b6 00             	movzbl (%eax),%eax
c0108f44:	3c 39                	cmp    $0x39,%al
c0108f46:	7f 11                	jg     c0108f59 <strtol+0xcc>
            dig = *s - '0';
c0108f48:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f4b:	0f b6 00             	movzbl (%eax),%eax
c0108f4e:	0f be c0             	movsbl %al,%eax
c0108f51:	83 e8 30             	sub    $0x30,%eax
c0108f54:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108f57:	eb 48                	jmp    c0108fa1 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0108f59:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f5c:	0f b6 00             	movzbl (%eax),%eax
c0108f5f:	3c 60                	cmp    $0x60,%al
c0108f61:	7e 1b                	jle    c0108f7e <strtol+0xf1>
c0108f63:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f66:	0f b6 00             	movzbl (%eax),%eax
c0108f69:	3c 7a                	cmp    $0x7a,%al
c0108f6b:	7f 11                	jg     c0108f7e <strtol+0xf1>
            dig = *s - 'a' + 10;
c0108f6d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f70:	0f b6 00             	movzbl (%eax),%eax
c0108f73:	0f be c0             	movsbl %al,%eax
c0108f76:	83 e8 57             	sub    $0x57,%eax
c0108f79:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108f7c:	eb 23                	jmp    c0108fa1 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0108f7e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f81:	0f b6 00             	movzbl (%eax),%eax
c0108f84:	3c 40                	cmp    $0x40,%al
c0108f86:	7e 3b                	jle    c0108fc3 <strtol+0x136>
c0108f88:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f8b:	0f b6 00             	movzbl (%eax),%eax
c0108f8e:	3c 5a                	cmp    $0x5a,%al
c0108f90:	7f 31                	jg     c0108fc3 <strtol+0x136>
            dig = *s - 'A' + 10;
c0108f92:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f95:	0f b6 00             	movzbl (%eax),%eax
c0108f98:	0f be c0             	movsbl %al,%eax
c0108f9b:	83 e8 37             	sub    $0x37,%eax
c0108f9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0108fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108fa4:	3b 45 10             	cmp    0x10(%ebp),%eax
c0108fa7:	7d 19                	jge    c0108fc2 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c0108fa9:	ff 45 08             	incl   0x8(%ebp)
c0108fac:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108faf:	0f af 45 10          	imul   0x10(%ebp),%eax
c0108fb3:	89 c2                	mov    %eax,%edx
c0108fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108fb8:	01 d0                	add    %edx,%eax
c0108fba:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c0108fbd:	e9 72 ff ff ff       	jmp    c0108f34 <strtol+0xa7>
            break;
c0108fc2:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c0108fc3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0108fc7:	74 08                	je     c0108fd1 <strtol+0x144>
        *endptr = (char *) s;
c0108fc9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108fcc:	8b 55 08             	mov    0x8(%ebp),%edx
c0108fcf:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0108fd1:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0108fd5:	74 07                	je     c0108fde <strtol+0x151>
c0108fd7:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108fda:	f7 d8                	neg    %eax
c0108fdc:	eb 03                	jmp    c0108fe1 <strtol+0x154>
c0108fde:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0108fe1:	89 ec                	mov    %ebp,%esp
c0108fe3:	5d                   	pop    %ebp
c0108fe4:	c3                   	ret    

c0108fe5 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0108fe5:	55                   	push   %ebp
c0108fe6:	89 e5                	mov    %esp,%ebp
c0108fe8:	83 ec 28             	sub    $0x28,%esp
c0108feb:	89 7d fc             	mov    %edi,-0x4(%ebp)
c0108fee:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108ff1:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0108ff4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
c0108ff8:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ffb:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0108ffe:	88 55 f7             	mov    %dl,-0x9(%ebp)
c0109001:	8b 45 10             	mov    0x10(%ebp),%eax
c0109004:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0109007:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010900a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c010900e:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0109011:	89 d7                	mov    %edx,%edi
c0109013:	f3 aa                	rep stos %al,%es:(%edi)
c0109015:	89 fa                	mov    %edi,%edx
c0109017:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010901a:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c010901d:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0109020:	8b 7d fc             	mov    -0x4(%ebp),%edi
c0109023:	89 ec                	mov    %ebp,%esp
c0109025:	5d                   	pop    %ebp
c0109026:	c3                   	ret    

c0109027 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0109027:	55                   	push   %ebp
c0109028:	89 e5                	mov    %esp,%ebp
c010902a:	57                   	push   %edi
c010902b:	56                   	push   %esi
c010902c:	53                   	push   %ebx
c010902d:	83 ec 30             	sub    $0x30,%esp
c0109030:	8b 45 08             	mov    0x8(%ebp),%eax
c0109033:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109036:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109039:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010903c:	8b 45 10             	mov    0x10(%ebp),%eax
c010903f:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0109042:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109045:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0109048:	73 42                	jae    c010908c <memmove+0x65>
c010904a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010904d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0109050:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109053:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0109056:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109059:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010905c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010905f:	c1 e8 02             	shr    $0x2,%eax
c0109062:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0109064:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109067:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010906a:	89 d7                	mov    %edx,%edi
c010906c:	89 c6                	mov    %eax,%esi
c010906e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0109070:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0109073:	83 e1 03             	and    $0x3,%ecx
c0109076:	74 02                	je     c010907a <memmove+0x53>
c0109078:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010907a:	89 f0                	mov    %esi,%eax
c010907c:	89 fa                	mov    %edi,%edx
c010907e:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0109081:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0109084:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c0109087:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
c010908a:	eb 36                	jmp    c01090c2 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c010908c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010908f:	8d 50 ff             	lea    -0x1(%eax),%edx
c0109092:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109095:	01 c2                	add    %eax,%edx
c0109097:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010909a:	8d 48 ff             	lea    -0x1(%eax),%ecx
c010909d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01090a0:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c01090a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01090a6:	89 c1                	mov    %eax,%ecx
c01090a8:	89 d8                	mov    %ebx,%eax
c01090aa:	89 d6                	mov    %edx,%esi
c01090ac:	89 c7                	mov    %eax,%edi
c01090ae:	fd                   	std    
c01090af:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01090b1:	fc                   	cld    
c01090b2:	89 f8                	mov    %edi,%eax
c01090b4:	89 f2                	mov    %esi,%edx
c01090b6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c01090b9:	89 55 c8             	mov    %edx,-0x38(%ebp)
c01090bc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c01090bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c01090c2:	83 c4 30             	add    $0x30,%esp
c01090c5:	5b                   	pop    %ebx
c01090c6:	5e                   	pop    %esi
c01090c7:	5f                   	pop    %edi
c01090c8:	5d                   	pop    %ebp
c01090c9:	c3                   	ret    

c01090ca <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c01090ca:	55                   	push   %ebp
c01090cb:	89 e5                	mov    %esp,%ebp
c01090cd:	57                   	push   %edi
c01090ce:	56                   	push   %esi
c01090cf:	83 ec 20             	sub    $0x20,%esp
c01090d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01090d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01090d8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01090db:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01090de:	8b 45 10             	mov    0x10(%ebp),%eax
c01090e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c01090e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01090e7:	c1 e8 02             	shr    $0x2,%eax
c01090ea:	89 c1                	mov    %eax,%ecx
    asm volatile (
c01090ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01090ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01090f2:	89 d7                	mov    %edx,%edi
c01090f4:	89 c6                	mov    %eax,%esi
c01090f6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c01090f8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c01090fb:	83 e1 03             	and    $0x3,%ecx
c01090fe:	74 02                	je     c0109102 <memcpy+0x38>
c0109100:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0109102:	89 f0                	mov    %esi,%eax
c0109104:	89 fa                	mov    %edi,%edx
c0109106:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0109109:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010910c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c010910f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0109112:	83 c4 20             	add    $0x20,%esp
c0109115:	5e                   	pop    %esi
c0109116:	5f                   	pop    %edi
c0109117:	5d                   	pop    %ebp
c0109118:	c3                   	ret    

c0109119 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0109119:	55                   	push   %ebp
c010911a:	89 e5                	mov    %esp,%ebp
c010911c:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c010911f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109122:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0109125:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109128:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c010912b:	eb 2e                	jmp    c010915b <memcmp+0x42>
        if (*s1 != *s2) {
c010912d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109130:	0f b6 10             	movzbl (%eax),%edx
c0109133:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109136:	0f b6 00             	movzbl (%eax),%eax
c0109139:	38 c2                	cmp    %al,%dl
c010913b:	74 18                	je     c0109155 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c010913d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109140:	0f b6 00             	movzbl (%eax),%eax
c0109143:	0f b6 d0             	movzbl %al,%edx
c0109146:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109149:	0f b6 00             	movzbl (%eax),%eax
c010914c:	0f b6 c8             	movzbl %al,%ecx
c010914f:	89 d0                	mov    %edx,%eax
c0109151:	29 c8                	sub    %ecx,%eax
c0109153:	eb 18                	jmp    c010916d <memcmp+0x54>
        }
        s1 ++, s2 ++;
c0109155:	ff 45 fc             	incl   -0x4(%ebp)
c0109158:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c010915b:	8b 45 10             	mov    0x10(%ebp),%eax
c010915e:	8d 50 ff             	lea    -0x1(%eax),%edx
c0109161:	89 55 10             	mov    %edx,0x10(%ebp)
c0109164:	85 c0                	test   %eax,%eax
c0109166:	75 c5                	jne    c010912d <memcmp+0x14>
    }
    return 0;
c0109168:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010916d:	89 ec                	mov    %ebp,%esp
c010916f:	5d                   	pop    %ebp
c0109170:	c3                   	ret    
