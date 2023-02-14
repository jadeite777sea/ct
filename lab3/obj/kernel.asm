
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
c0100059:	e8 83 8d 00 00       	call   c0108de1 <memset>

    cons_init();                // init the console
c010005e:	e8 1d 16 00 00       	call   c0101680 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100063:	c7 45 f4 80 8f 10 c0 	movl   $0xc0108f80,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010006d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100071:	c7 04 24 9c 8f 10 c0 	movl   $0xc0108f9c,(%esp)
c0100078:	e8 e8 02 00 00       	call   c0100365 <cprintf>

    print_kerninfo();
c010007d:	e8 06 08 00 00       	call   c0100888 <print_kerninfo>

    grade_backtrace();
c0100082:	e8 9f 00 00 00       	call   c0100126 <grade_backtrace>

    pmm_init();                 // init physical memory management
c0100087:	e8 a5 4e 00 00       	call   c0104f31 <pmm_init>

    pic_init();                 // init interrupt controller
c010008c:	e8 cd 1f 00 00       	call   c010205e <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100091:	e8 54 21 00 00       	call   c01021ea <idt_init>

    vmm_init();                 // init virtual memory management
c0100096:	e8 96 77 00 00       	call   c0107831 <vmm_init>

    ide_init();                 // init ide devices
c010009b:	e8 1a 17 00 00       	call   c01017ba <ide_init>
    swap_init();                // init swap
c01000a0:	e8 6f 62 00 00       	call   c0106314 <swap_init>

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
c0100176:	c7 04 24 a1 8f 10 c0 	movl   $0xc0108fa1,(%esp)
c010017d:	e8 e3 01 00 00       	call   c0100365 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100182:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100186:	89 c2                	mov    %eax,%edx
c0100188:	a1 00 60 12 c0       	mov    0xc0126000,%eax
c010018d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100191:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100195:	c7 04 24 af 8f 10 c0 	movl   $0xc0108faf,(%esp)
c010019c:	e8 c4 01 00 00       	call   c0100365 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c01001a1:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001a5:	89 c2                	mov    %eax,%edx
c01001a7:	a1 00 60 12 c0       	mov    0xc0126000,%eax
c01001ac:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001b0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001b4:	c7 04 24 bd 8f 10 c0 	movl   $0xc0108fbd,(%esp)
c01001bb:	e8 a5 01 00 00       	call   c0100365 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001c0:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001c4:	89 c2                	mov    %eax,%edx
c01001c6:	a1 00 60 12 c0       	mov    0xc0126000,%eax
c01001cb:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001cf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001d3:	c7 04 24 cb 8f 10 c0 	movl   $0xc0108fcb,(%esp)
c01001da:	e8 86 01 00 00       	call   c0100365 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001df:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001e3:	89 c2                	mov    %eax,%edx
c01001e5:	a1 00 60 12 c0       	mov    0xc0126000,%eax
c01001ea:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001ee:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001f2:	c7 04 24 d9 8f 10 c0 	movl   $0xc0108fd9,(%esp)
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
c0100225:	c7 04 24 e8 8f 10 c0 	movl   $0xc0108fe8,(%esp)
c010022c:	e8 34 01 00 00       	call   c0100365 <cprintf>
    lab1_switch_to_user();
c0100231:	e8 d8 ff ff ff       	call   c010020e <lab1_switch_to_user>
    lab1_print_cur_status();
c0100236:	e8 13 ff ff ff       	call   c010014e <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c010023b:	c7 04 24 08 90 10 c0 	movl   $0xc0109008,(%esp)
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
c0100269:	c7 04 24 27 90 10 c0 	movl   $0xc0109027,(%esp)
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
c0100359:	e8 d6 81 00 00       	call   c0108534 <vprintfmt>
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
c0100569:	c7 00 2c 90 10 c0    	movl   $0xc010902c,(%eax)
    info->eip_line = 0;
c010056f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100572:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100579:	8b 45 0c             	mov    0xc(%ebp),%eax
c010057c:	c7 40 08 2c 90 10 c0 	movl   $0xc010902c,0x8(%eax)
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
c01005a0:	c7 45 f4 28 b0 10 c0 	movl   $0xc010b028,-0xc(%ebp)
    stab_end = __STAB_END__;
c01005a7:	c7 45 f0 e0 b4 11 c0 	movl   $0xc011b4e0,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c01005ae:	c7 45 ec e1 b4 11 c0 	movl   $0xc011b4e1,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c01005b5:	c7 45 e8 c8 03 12 c0 	movl   $0xc01203c8,-0x18(%ebp)

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
c0100708:	e8 4c 85 00 00       	call   c0108c59 <strfind>
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
c010088e:	c7 04 24 36 90 10 c0 	movl   $0xc0109036,(%esp)
c0100895:	e8 cb fa ff ff       	call   c0100365 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010089a:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c01008a1:	c0 
c01008a2:	c7 04 24 4f 90 10 c0 	movl   $0xc010904f,(%esp)
c01008a9:	e8 b7 fa ff ff       	call   c0100365 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01008ae:	c7 44 24 04 6d 8f 10 	movl   $0xc0108f6d,0x4(%esp)
c01008b5:	c0 
c01008b6:	c7 04 24 67 90 10 c0 	movl   $0xc0109067,(%esp)
c01008bd:	e8 a3 fa ff ff       	call   c0100365 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01008c2:	c7 44 24 04 00 60 12 	movl   $0xc0126000,0x4(%esp)
c01008c9:	c0 
c01008ca:	c7 04 24 7f 90 10 c0 	movl   $0xc010907f,(%esp)
c01008d1:	e8 8f fa ff ff       	call   c0100365 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01008d6:	c7 44 24 04 14 71 12 	movl   $0xc0127114,0x4(%esp)
c01008dd:	c0 
c01008de:	c7 04 24 97 90 10 c0 	movl   $0xc0109097,(%esp)
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
c010090b:	c7 04 24 b0 90 10 c0 	movl   $0xc01090b0,(%esp)
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
c0100942:	c7 04 24 da 90 10 c0 	movl   $0xc01090da,(%esp)
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
c01009b0:	c7 04 24 f6 90 10 c0 	movl   $0xc01090f6,(%esp)
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
c0100a00:	c7 04 24 08 91 10 c0 	movl   $0xc0109108,(%esp)
c0100a07:	e8 59 f9 ff ff       	call   c0100365 <cprintf>
        cprintf(" ");
c0100a0c:	c7 04 24 0d 91 10 c0 	movl   $0xc010910d,(%esp)
c0100a13:	e8 4d f9 ff ff       	call   c0100365 <cprintf>
        cprintf("%08x",eip);
c0100a18:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a1b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a1f:	c7 04 24 08 91 10 c0 	movl   $0xc0109108,(%esp)
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
c0100a3d:	c7 04 24 0d 91 10 c0 	movl   $0xc010910d,(%esp)
c0100a44:	e8 1c f9 ff ff       	call   c0100365 <cprintf>
            cprintf("%08x",a[j]);
c0100a49:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a4c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100a53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100a56:	01 d0                	add    %edx,%eax
c0100a58:	8b 00                	mov    (%eax),%eax
c0100a5a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a5e:	c7 04 24 08 91 10 c0 	movl   $0xc0109108,(%esp)
c0100a65:	e8 fb f8 ff ff       	call   c0100365 <cprintf>
        for(j=0;j<4;j++)
c0100a6a:	ff 45 e8             	incl   -0x18(%ebp)
c0100a6d:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100a71:	7e ca                	jle    c0100a3d <print_stackframe+0x69>
        }
        cprintf("\n");
c0100a73:	c7 04 24 0f 91 10 c0 	movl   $0xc010910f,(%esp)
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
c0100ae8:	c7 04 24 94 91 10 c0 	movl   $0xc0109194,(%esp)
c0100aef:	e8 31 81 00 00       	call   c0108c25 <strchr>
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
c0100b10:	c7 04 24 99 91 10 c0 	movl   $0xc0109199,(%esp)
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
c0100b52:	c7 04 24 94 91 10 c0 	movl   $0xc0109194,(%esp)
c0100b59:	e8 c7 80 00 00       	call   c0108c25 <strchr>
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
c0100bc3:	e8 c1 7f 00 00       	call   c0108b89 <strcmp>
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
c0100c0f:	c7 04 24 b7 91 10 c0 	movl   $0xc01091b7,(%esp)
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
c0100c2d:	c7 04 24 d0 91 10 c0 	movl   $0xc01091d0,(%esp)
c0100c34:	e8 2c f7 ff ff       	call   c0100365 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100c39:	c7 04 24 f8 91 10 c0 	movl   $0xc01091f8,(%esp)
c0100c40:	e8 20 f7 ff ff       	call   c0100365 <cprintf>

    if (tf != NULL) {
c0100c45:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100c49:	74 0b                	je     c0100c56 <kmonitor+0x2f>
        print_trapframe(tf);
c0100c4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c4e:	89 04 24             	mov    %eax,(%esp)
c0100c51:	e8 4e 17 00 00       	call   c01023a4 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100c56:	c7 04 24 1d 92 10 c0 	movl   $0xc010921d,(%esp)
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
c0100cc6:	c7 04 24 21 92 10 c0 	movl   $0xc0109221,(%esp)
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
c0100d3b:	c7 04 24 2a 92 10 c0 	movl   $0xc010922a,(%esp)
c0100d42:	e8 1e f6 ff ff       	call   c0100365 <cprintf>
    vcprintf(fmt, ap);
c0100d47:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d4a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d4e:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d51:	89 04 24             	mov    %eax,(%esp)
c0100d54:	e8 d7 f5 ff ff       	call   c0100330 <vcprintf>
    cprintf("\n");
c0100d59:	c7 04 24 46 92 10 c0 	movl   $0xc0109246,(%esp)
c0100d60:	e8 00 f6 ff ff       	call   c0100365 <cprintf>
    
    cprintf("stack trackback:\n");
c0100d65:	c7 04 24 48 92 10 c0 	movl   $0xc0109248,(%esp)
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
c0100da6:	c7 04 24 5a 92 10 c0 	movl   $0xc010925a,(%esp)
c0100dad:	e8 b3 f5 ff ff       	call   c0100365 <cprintf>
    vcprintf(fmt, ap);
c0100db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100db5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100db9:	8b 45 10             	mov    0x10(%ebp),%eax
c0100dbc:	89 04 24             	mov    %eax,(%esp)
c0100dbf:	e8 6c f5 ff ff       	call   c0100330 <vcprintf>
    cprintf("\n");
c0100dc4:	c7 04 24 46 92 10 c0 	movl   $0xc0109246,(%esp)
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
c0100e2b:	c7 04 24 78 92 10 c0 	movl   $0xc0109278,(%esp)
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
c0101295:	e8 89 7b 00 00       	call   c0108e23 <memmove>
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
c0101627:	c7 04 24 93 92 10 c0 	movl   $0xc0109293,(%esp)
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
c010169e:	c7 04 24 9f 92 10 c0 	movl   $0xc010929f,(%esp)
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
c01017ef:	8b 04 85 c0 92 10 c0 	mov    -0x3fef6d40(,%eax,4),%eax
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
c0101981:	c7 44 24 0c c8 92 10 	movl   $0xc01092c8,0xc(%esp)
c0101988:	c0 
c0101989:	c7 44 24 08 0b 93 10 	movl   $0xc010930b,0x8(%esp)
c0101990:	c0 
c0101991:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0101998:	00 
c0101999:	c7 04 24 20 93 10 c0 	movl   $0xc0109320,(%esp)
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
c0101a75:	c7 04 24 32 93 10 c0 	movl   $0xc0109332,(%esp)
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
c0101b75:	c7 44 24 0c 50 93 10 	movl   $0xc0109350,0xc(%esp)
c0101b7c:	c0 
c0101b7d:	c7 44 24 08 0b 93 10 	movl   $0xc010930b,0x8(%esp)
c0101b84:	c0 
c0101b85:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c0101b8c:	00 
c0101b8d:	c7 04 24 20 93 10 c0 	movl   $0xc0109320,(%esp)
c0101b94:	e8 75 f1 ff ff       	call   c0100d0e <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101b99:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101ba0:	77 0f                	ja     c0101bb1 <ide_read_secs+0x77>
c0101ba2:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101ba5:	8b 45 14             	mov    0x14(%ebp),%eax
c0101ba8:	01 d0                	add    %edx,%eax
c0101baa:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101baf:	76 24                	jbe    c0101bd5 <ide_read_secs+0x9b>
c0101bb1:	c7 44 24 0c 78 93 10 	movl   $0xc0109378,0xc(%esp)
c0101bb8:	c0 
c0101bb9:	c7 44 24 08 0b 93 10 	movl   $0xc010930b,0x8(%esp)
c0101bc0:	c0 
c0101bc1:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0101bc8:	00 
c0101bc9:	c7 04 24 20 93 10 c0 	movl   $0xc0109320,(%esp)
c0101bd0:	e8 39 f1 ff ff       	call   c0100d0e <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101bd5:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101bd9:	d1 e8                	shr    %eax
c0101bdb:	0f b7 c0             	movzwl %ax,%eax
c0101bde:	8b 04 85 c0 92 10 c0 	mov    -0x3fef6d40(,%eax,4),%eax
c0101be5:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101be9:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101bed:	d1 e8                	shr    %eax
c0101bef:	0f b7 c0             	movzwl %ax,%eax
c0101bf2:	0f b7 04 85 c2 92 10 	movzwl -0x3fef6d3e(,%eax,4),%eax
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
c0101db6:	c7 44 24 0c 50 93 10 	movl   $0xc0109350,0xc(%esp)
c0101dbd:	c0 
c0101dbe:	c7 44 24 08 0b 93 10 	movl   $0xc010930b,0x8(%esp)
c0101dc5:	c0 
c0101dc6:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0101dcd:	00 
c0101dce:	c7 04 24 20 93 10 c0 	movl   $0xc0109320,(%esp)
c0101dd5:	e8 34 ef ff ff       	call   c0100d0e <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101dda:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101de1:	77 0f                	ja     c0101df2 <ide_write_secs+0x77>
c0101de3:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101de6:	8b 45 14             	mov    0x14(%ebp),%eax
c0101de9:	01 d0                	add    %edx,%eax
c0101deb:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101df0:	76 24                	jbe    c0101e16 <ide_write_secs+0x9b>
c0101df2:	c7 44 24 0c 78 93 10 	movl   $0xc0109378,0xc(%esp)
c0101df9:	c0 
c0101dfa:	c7 44 24 08 0b 93 10 	movl   $0xc010930b,0x8(%esp)
c0101e01:	c0 
c0101e02:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c0101e09:	00 
c0101e0a:	c7 04 24 20 93 10 c0 	movl   $0xc0109320,(%esp)
c0101e11:	e8 f8 ee ff ff       	call   c0100d0e <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101e16:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101e1a:	d1 e8                	shr    %eax
c0101e1c:	0f b7 c0             	movzwl %ax,%eax
c0101e1f:	8b 04 85 c0 92 10 c0 	mov    -0x3fef6d40(,%eax,4),%eax
c0101e26:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101e2a:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101e2e:	d1 e8                	shr    %eax
c0101e30:	0f b7 c0             	movzwl %ax,%eax
c0101e33:	0f b7 04 85 c2 92 10 	movzwl -0x3fef6d3e(,%eax,4),%eax
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
c01021b6:	c7 04 24 c0 93 10 c0 	movl   $0xc01093c0,(%esp)
c01021bd:	e8 a3 e1 ff ff       	call   c0100365 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c01021c2:	c7 04 24 ca 93 10 c0 	movl   $0xc01093ca,(%esp)
c01021c9:	e8 97 e1 ff ff       	call   c0100365 <cprintf>
    panic("EOT: kernel seems ok.");
c01021ce:	c7 44 24 08 d8 93 10 	movl   $0xc01093d8,0x8(%esp)
c01021d5:	c0 
c01021d6:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c01021dd:	00 
c01021de:	c7 04 24 ee 93 10 c0 	movl   $0xc01093ee,(%esp)
c01021e5:	e8 24 eb ff ff       	call   c0100d0e <__panic>

c01021ea <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01021ea:	55                   	push   %ebp
c01021eb:	89 e5                	mov    %esp,%ebp
c01021ed:	83 ec 10             	sub    $0x10,%esp
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */

     extern uintptr_t __vectors[];
     int i;
     for(i=0;i<256;i++)
c01021f0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01021f7:	e9 c4 00 00 00       	jmp    c01022c0 <idt_init+0xd6>
     {
        SETGATE(idt[i],0,GD_KTEXT,__vectors[i],0);
c01021fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021ff:	8b 04 85 e0 35 12 c0 	mov    -0x3fedca20(,%eax,4),%eax
c0102206:	0f b7 d0             	movzwl %ax,%edx
c0102209:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010220c:	66 89 14 c5 80 67 12 	mov    %dx,-0x3fed9880(,%eax,8)
c0102213:	c0 
c0102214:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102217:	66 c7 04 c5 82 67 12 	movw   $0x8,-0x3fed987e(,%eax,8)
c010221e:	c0 08 00 
c0102221:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102224:	0f b6 14 c5 84 67 12 	movzbl -0x3fed987c(,%eax,8),%edx
c010222b:	c0 
c010222c:	80 e2 e0             	and    $0xe0,%dl
c010222f:	88 14 c5 84 67 12 c0 	mov    %dl,-0x3fed987c(,%eax,8)
c0102236:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102239:	0f b6 14 c5 84 67 12 	movzbl -0x3fed987c(,%eax,8),%edx
c0102240:	c0 
c0102241:	80 e2 1f             	and    $0x1f,%dl
c0102244:	88 14 c5 84 67 12 c0 	mov    %dl,-0x3fed987c(,%eax,8)
c010224b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010224e:	0f b6 14 c5 85 67 12 	movzbl -0x3fed987b(,%eax,8),%edx
c0102255:	c0 
c0102256:	80 e2 f0             	and    $0xf0,%dl
c0102259:	80 ca 0e             	or     $0xe,%dl
c010225c:	88 14 c5 85 67 12 c0 	mov    %dl,-0x3fed987b(,%eax,8)
c0102263:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102266:	0f b6 14 c5 85 67 12 	movzbl -0x3fed987b(,%eax,8),%edx
c010226d:	c0 
c010226e:	80 e2 ef             	and    $0xef,%dl
c0102271:	88 14 c5 85 67 12 c0 	mov    %dl,-0x3fed987b(,%eax,8)
c0102278:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010227b:	0f b6 14 c5 85 67 12 	movzbl -0x3fed987b(,%eax,8),%edx
c0102282:	c0 
c0102283:	80 e2 9f             	and    $0x9f,%dl
c0102286:	88 14 c5 85 67 12 c0 	mov    %dl,-0x3fed987b(,%eax,8)
c010228d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102290:	0f b6 14 c5 85 67 12 	movzbl -0x3fed987b(,%eax,8),%edx
c0102297:	c0 
c0102298:	80 ca 80             	or     $0x80,%dl
c010229b:	88 14 c5 85 67 12 c0 	mov    %dl,-0x3fed987b(,%eax,8)
c01022a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022a5:	8b 04 85 e0 35 12 c0 	mov    -0x3fedca20(,%eax,4),%eax
c01022ac:	c1 e8 10             	shr    $0x10,%eax
c01022af:	0f b7 d0             	movzwl %ax,%edx
c01022b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022b5:	66 89 14 c5 86 67 12 	mov    %dx,-0x3fed987a(,%eax,8)
c01022bc:	c0 
     for(i=0;i<256;i++)
c01022bd:	ff 45 fc             	incl   -0x4(%ebp)
c01022c0:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
c01022c7:	0f 8e 2f ff ff ff    	jle    c01021fc <idt_init+0x12>
     }
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], 3);
c01022cd:	a1 c4 37 12 c0       	mov    0xc01237c4,%eax
c01022d2:	0f b7 c0             	movzwl %ax,%eax
c01022d5:	66 a3 48 6b 12 c0    	mov    %ax,0xc0126b48
c01022db:	66 c7 05 4a 6b 12 c0 	movw   $0x8,0xc0126b4a
c01022e2:	08 00 
c01022e4:	0f b6 05 4c 6b 12 c0 	movzbl 0xc0126b4c,%eax
c01022eb:	24 e0                	and    $0xe0,%al
c01022ed:	a2 4c 6b 12 c0       	mov    %al,0xc0126b4c
c01022f2:	0f b6 05 4c 6b 12 c0 	movzbl 0xc0126b4c,%eax
c01022f9:	24 1f                	and    $0x1f,%al
c01022fb:	a2 4c 6b 12 c0       	mov    %al,0xc0126b4c
c0102300:	0f b6 05 4d 6b 12 c0 	movzbl 0xc0126b4d,%eax
c0102307:	24 f0                	and    $0xf0,%al
c0102309:	0c 0e                	or     $0xe,%al
c010230b:	a2 4d 6b 12 c0       	mov    %al,0xc0126b4d
c0102310:	0f b6 05 4d 6b 12 c0 	movzbl 0xc0126b4d,%eax
c0102317:	24 ef                	and    $0xef,%al
c0102319:	a2 4d 6b 12 c0       	mov    %al,0xc0126b4d
c010231e:	0f b6 05 4d 6b 12 c0 	movzbl 0xc0126b4d,%eax
c0102325:	0c 60                	or     $0x60,%al
c0102327:	a2 4d 6b 12 c0       	mov    %al,0xc0126b4d
c010232c:	0f b6 05 4d 6b 12 c0 	movzbl 0xc0126b4d,%eax
c0102333:	0c 80                	or     $0x80,%al
c0102335:	a2 4d 6b 12 c0       	mov    %al,0xc0126b4d
c010233a:	a1 c4 37 12 c0       	mov    0xc01237c4,%eax
c010233f:	c1 e8 10             	shr    $0x10,%eax
c0102342:	0f b7 c0             	movzwl %ax,%eax
c0102345:	66 a3 4e 6b 12 c0    	mov    %ax,0xc0126b4e
c010234b:	c7 45 f8 60 35 12 c0 	movl   $0xc0123560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0102352:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0102355:	0f 01 18             	lidtl  (%eax)
}
c0102358:	90                   	nop





}
c0102359:	90                   	nop
c010235a:	89 ec                	mov    %ebp,%esp
c010235c:	5d                   	pop    %ebp
c010235d:	c3                   	ret    

c010235e <trapname>:

static const char *
trapname(int trapno) {
c010235e:	55                   	push   %ebp
c010235f:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0102361:	8b 45 08             	mov    0x8(%ebp),%eax
c0102364:	83 f8 13             	cmp    $0x13,%eax
c0102367:	77 0c                	ja     c0102375 <trapname+0x17>
        return excnames[trapno];
c0102369:	8b 45 08             	mov    0x8(%ebp),%eax
c010236c:	8b 04 85 40 98 10 c0 	mov    -0x3fef67c0(,%eax,4),%eax
c0102373:	eb 18                	jmp    c010238d <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0102375:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0102379:	7e 0d                	jle    c0102388 <trapname+0x2a>
c010237b:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c010237f:	7f 07                	jg     c0102388 <trapname+0x2a>
        return "Hardware Interrupt";
c0102381:	b8 ff 93 10 c0       	mov    $0xc01093ff,%eax
c0102386:	eb 05                	jmp    c010238d <trapname+0x2f>
    }
    return "(unknown trap)";
c0102388:	b8 12 94 10 c0       	mov    $0xc0109412,%eax
}
c010238d:	5d                   	pop    %ebp
c010238e:	c3                   	ret    

c010238f <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c010238f:	55                   	push   %ebp
c0102390:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0102392:	8b 45 08             	mov    0x8(%ebp),%eax
c0102395:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102399:	83 f8 08             	cmp    $0x8,%eax
c010239c:	0f 94 c0             	sete   %al
c010239f:	0f b6 c0             	movzbl %al,%eax
}
c01023a2:	5d                   	pop    %ebp
c01023a3:	c3                   	ret    

c01023a4 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c01023a4:	55                   	push   %ebp
c01023a5:	89 e5                	mov    %esp,%ebp
c01023a7:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c01023aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01023ad:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023b1:	c7 04 24 53 94 10 c0 	movl   $0xc0109453,(%esp)
c01023b8:	e8 a8 df ff ff       	call   c0100365 <cprintf>
    print_regs(&tf->tf_regs);
c01023bd:	8b 45 08             	mov    0x8(%ebp),%eax
c01023c0:	89 04 24             	mov    %eax,(%esp)
c01023c3:	e8 8f 01 00 00       	call   c0102557 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c01023c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01023cb:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c01023cf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023d3:	c7 04 24 64 94 10 c0 	movl   $0xc0109464,(%esp)
c01023da:	e8 86 df ff ff       	call   c0100365 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c01023df:	8b 45 08             	mov    0x8(%ebp),%eax
c01023e2:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c01023e6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023ea:	c7 04 24 77 94 10 c0 	movl   $0xc0109477,(%esp)
c01023f1:	e8 6f df ff ff       	call   c0100365 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c01023f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01023f9:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c01023fd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102401:	c7 04 24 8a 94 10 c0 	movl   $0xc010948a,(%esp)
c0102408:	e8 58 df ff ff       	call   c0100365 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c010240d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102410:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0102414:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102418:	c7 04 24 9d 94 10 c0 	movl   $0xc010949d,(%esp)
c010241f:	e8 41 df ff ff       	call   c0100365 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0102424:	8b 45 08             	mov    0x8(%ebp),%eax
c0102427:	8b 40 30             	mov    0x30(%eax),%eax
c010242a:	89 04 24             	mov    %eax,(%esp)
c010242d:	e8 2c ff ff ff       	call   c010235e <trapname>
c0102432:	8b 55 08             	mov    0x8(%ebp),%edx
c0102435:	8b 52 30             	mov    0x30(%edx),%edx
c0102438:	89 44 24 08          	mov    %eax,0x8(%esp)
c010243c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102440:	c7 04 24 b0 94 10 c0 	movl   $0xc01094b0,(%esp)
c0102447:	e8 19 df ff ff       	call   c0100365 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c010244c:	8b 45 08             	mov    0x8(%ebp),%eax
c010244f:	8b 40 34             	mov    0x34(%eax),%eax
c0102452:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102456:	c7 04 24 c2 94 10 c0 	movl   $0xc01094c2,(%esp)
c010245d:	e8 03 df ff ff       	call   c0100365 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0102462:	8b 45 08             	mov    0x8(%ebp),%eax
c0102465:	8b 40 38             	mov    0x38(%eax),%eax
c0102468:	89 44 24 04          	mov    %eax,0x4(%esp)
c010246c:	c7 04 24 d1 94 10 c0 	movl   $0xc01094d1,(%esp)
c0102473:	e8 ed de ff ff       	call   c0100365 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0102478:	8b 45 08             	mov    0x8(%ebp),%eax
c010247b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010247f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102483:	c7 04 24 e0 94 10 c0 	movl   $0xc01094e0,(%esp)
c010248a:	e8 d6 de ff ff       	call   c0100365 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c010248f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102492:	8b 40 40             	mov    0x40(%eax),%eax
c0102495:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102499:	c7 04 24 f3 94 10 c0 	movl   $0xc01094f3,(%esp)
c01024a0:	e8 c0 de ff ff       	call   c0100365 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c01024a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01024ac:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c01024b3:	eb 3d                	jmp    c01024f2 <print_trapframe+0x14e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c01024b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01024b8:	8b 50 40             	mov    0x40(%eax),%edx
c01024bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01024be:	21 d0                	and    %edx,%eax
c01024c0:	85 c0                	test   %eax,%eax
c01024c2:	74 28                	je     c01024ec <print_trapframe+0x148>
c01024c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01024c7:	8b 04 85 80 35 12 c0 	mov    -0x3fedca80(,%eax,4),%eax
c01024ce:	85 c0                	test   %eax,%eax
c01024d0:	74 1a                	je     c01024ec <print_trapframe+0x148>
            cprintf("%s,", IA32flags[i]);
c01024d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01024d5:	8b 04 85 80 35 12 c0 	mov    -0x3fedca80(,%eax,4),%eax
c01024dc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024e0:	c7 04 24 02 95 10 c0 	movl   $0xc0109502,(%esp)
c01024e7:	e8 79 de ff ff       	call   c0100365 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c01024ec:	ff 45 f4             	incl   -0xc(%ebp)
c01024ef:	d1 65 f0             	shll   -0x10(%ebp)
c01024f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01024f5:	83 f8 17             	cmp    $0x17,%eax
c01024f8:	76 bb                	jbe    c01024b5 <print_trapframe+0x111>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c01024fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01024fd:	8b 40 40             	mov    0x40(%eax),%eax
c0102500:	c1 e8 0c             	shr    $0xc,%eax
c0102503:	83 e0 03             	and    $0x3,%eax
c0102506:	89 44 24 04          	mov    %eax,0x4(%esp)
c010250a:	c7 04 24 06 95 10 c0 	movl   $0xc0109506,(%esp)
c0102511:	e8 4f de ff ff       	call   c0100365 <cprintf>

    if (!trap_in_kernel(tf)) {
c0102516:	8b 45 08             	mov    0x8(%ebp),%eax
c0102519:	89 04 24             	mov    %eax,(%esp)
c010251c:	e8 6e fe ff ff       	call   c010238f <trap_in_kernel>
c0102521:	85 c0                	test   %eax,%eax
c0102523:	75 2d                	jne    c0102552 <print_trapframe+0x1ae>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0102525:	8b 45 08             	mov    0x8(%ebp),%eax
c0102528:	8b 40 44             	mov    0x44(%eax),%eax
c010252b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010252f:	c7 04 24 0f 95 10 c0 	movl   $0xc010950f,(%esp)
c0102536:	e8 2a de ff ff       	call   c0100365 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c010253b:	8b 45 08             	mov    0x8(%ebp),%eax
c010253e:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0102542:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102546:	c7 04 24 1e 95 10 c0 	movl   $0xc010951e,(%esp)
c010254d:	e8 13 de ff ff       	call   c0100365 <cprintf>
    }
}
c0102552:	90                   	nop
c0102553:	89 ec                	mov    %ebp,%esp
c0102555:	5d                   	pop    %ebp
c0102556:	c3                   	ret    

c0102557 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0102557:	55                   	push   %ebp
c0102558:	89 e5                	mov    %esp,%ebp
c010255a:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c010255d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102560:	8b 00                	mov    (%eax),%eax
c0102562:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102566:	c7 04 24 31 95 10 c0 	movl   $0xc0109531,(%esp)
c010256d:	e8 f3 dd ff ff       	call   c0100365 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0102572:	8b 45 08             	mov    0x8(%ebp),%eax
c0102575:	8b 40 04             	mov    0x4(%eax),%eax
c0102578:	89 44 24 04          	mov    %eax,0x4(%esp)
c010257c:	c7 04 24 40 95 10 c0 	movl   $0xc0109540,(%esp)
c0102583:	e8 dd dd ff ff       	call   c0100365 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0102588:	8b 45 08             	mov    0x8(%ebp),%eax
c010258b:	8b 40 08             	mov    0x8(%eax),%eax
c010258e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102592:	c7 04 24 4f 95 10 c0 	movl   $0xc010954f,(%esp)
c0102599:	e8 c7 dd ff ff       	call   c0100365 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c010259e:	8b 45 08             	mov    0x8(%ebp),%eax
c01025a1:	8b 40 0c             	mov    0xc(%eax),%eax
c01025a4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025a8:	c7 04 24 5e 95 10 c0 	movl   $0xc010955e,(%esp)
c01025af:	e8 b1 dd ff ff       	call   c0100365 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c01025b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01025b7:	8b 40 10             	mov    0x10(%eax),%eax
c01025ba:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025be:	c7 04 24 6d 95 10 c0 	movl   $0xc010956d,(%esp)
c01025c5:	e8 9b dd ff ff       	call   c0100365 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c01025ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01025cd:	8b 40 14             	mov    0x14(%eax),%eax
c01025d0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025d4:	c7 04 24 7c 95 10 c0 	movl   $0xc010957c,(%esp)
c01025db:	e8 85 dd ff ff       	call   c0100365 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c01025e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01025e3:	8b 40 18             	mov    0x18(%eax),%eax
c01025e6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025ea:	c7 04 24 8b 95 10 c0 	movl   $0xc010958b,(%esp)
c01025f1:	e8 6f dd ff ff       	call   c0100365 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c01025f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01025f9:	8b 40 1c             	mov    0x1c(%eax),%eax
c01025fc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102600:	c7 04 24 9a 95 10 c0 	movl   $0xc010959a,(%esp)
c0102607:	e8 59 dd ff ff       	call   c0100365 <cprintf>
}
c010260c:	90                   	nop
c010260d:	89 ec                	mov    %ebp,%esp
c010260f:	5d                   	pop    %ebp
c0102610:	c3                   	ret    

c0102611 <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c0102611:	55                   	push   %ebp
c0102612:	89 e5                	mov    %esp,%ebp
c0102614:	83 ec 38             	sub    $0x38,%esp
c0102617:	89 5d fc             	mov    %ebx,-0x4(%ebp)
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c010261a:	8b 45 08             	mov    0x8(%ebp),%eax
c010261d:	8b 40 34             	mov    0x34(%eax),%eax
c0102620:	83 e0 01             	and    $0x1,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102623:	85 c0                	test   %eax,%eax
c0102625:	74 07                	je     c010262e <print_pgfault+0x1d>
c0102627:	bb a9 95 10 c0       	mov    $0xc01095a9,%ebx
c010262c:	eb 05                	jmp    c0102633 <print_pgfault+0x22>
c010262e:	bb ba 95 10 c0       	mov    $0xc01095ba,%ebx
            (tf->tf_err & 2) ? 'W' : 'R',
c0102633:	8b 45 08             	mov    0x8(%ebp),%eax
c0102636:	8b 40 34             	mov    0x34(%eax),%eax
c0102639:	83 e0 02             	and    $0x2,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c010263c:	85 c0                	test   %eax,%eax
c010263e:	74 07                	je     c0102647 <print_pgfault+0x36>
c0102640:	b9 57 00 00 00       	mov    $0x57,%ecx
c0102645:	eb 05                	jmp    c010264c <print_pgfault+0x3b>
c0102647:	b9 52 00 00 00       	mov    $0x52,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
c010264c:	8b 45 08             	mov    0x8(%ebp),%eax
c010264f:	8b 40 34             	mov    0x34(%eax),%eax
c0102652:	83 e0 04             	and    $0x4,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102655:	85 c0                	test   %eax,%eax
c0102657:	74 07                	je     c0102660 <print_pgfault+0x4f>
c0102659:	ba 55 00 00 00       	mov    $0x55,%edx
c010265e:	eb 05                	jmp    c0102665 <print_pgfault+0x54>
c0102660:	ba 4b 00 00 00       	mov    $0x4b,%edx
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c0102665:	0f 20 d0             	mov    %cr2,%eax
c0102668:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c010266b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010266e:	89 5c 24 10          	mov    %ebx,0x10(%esp)
c0102672:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0102676:	89 54 24 08          	mov    %edx,0x8(%esp)
c010267a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010267e:	c7 04 24 c8 95 10 c0 	movl   $0xc01095c8,(%esp)
c0102685:	e8 db dc ff ff       	call   c0100365 <cprintf>
}
c010268a:	90                   	nop
c010268b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010268e:	89 ec                	mov    %ebp,%esp
c0102690:	5d                   	pop    %ebp
c0102691:	c3                   	ret    

c0102692 <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c0102692:	55                   	push   %ebp
c0102693:	89 e5                	mov    %esp,%ebp
c0102695:	83 ec 28             	sub    $0x28,%esp
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
c0102698:	8b 45 08             	mov    0x8(%ebp),%eax
c010269b:	89 04 24             	mov    %eax,(%esp)
c010269e:	e8 6e ff ff ff       	call   c0102611 <print_pgfault>
    if (check_mm_struct != NULL) {
c01026a3:	a1 0c 71 12 c0       	mov    0xc012710c,%eax
c01026a8:	85 c0                	test   %eax,%eax
c01026aa:	74 26                	je     c01026d2 <pgfault_handler+0x40>
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01026ac:	0f 20 d0             	mov    %cr2,%eax
c01026af:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c01026b2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
        return do_pgfault(check_mm_struct, tf->tf_err, rcr2());
c01026b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01026b8:	8b 50 34             	mov    0x34(%eax),%edx
c01026bb:	a1 0c 71 12 c0       	mov    0xc012710c,%eax
c01026c0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01026c4:	89 54 24 04          	mov    %edx,0x4(%esp)
c01026c8:	89 04 24             	mov    %eax,(%esp)
c01026cb:	e8 d0 58 00 00       	call   c0107fa0 <do_pgfault>
c01026d0:	eb 1c                	jmp    c01026ee <pgfault_handler+0x5c>
    }
    panic("unhandled page fault.\n");
c01026d2:	c7 44 24 08 eb 95 10 	movl   $0xc01095eb,0x8(%esp)
c01026d9:	c0 
c01026da:	c7 44 24 04 b0 00 00 	movl   $0xb0,0x4(%esp)
c01026e1:	00 
c01026e2:	c7 04 24 ee 93 10 c0 	movl   $0xc01093ee,(%esp)
c01026e9:	e8 20 e6 ff ff       	call   c0100d0e <__panic>
}
c01026ee:	89 ec                	mov    %ebp,%esp
c01026f0:	5d                   	pop    %ebp
c01026f1:	c3                   	ret    

c01026f2 <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c01026f2:	55                   	push   %ebp
c01026f3:	89 e5                	mov    %esp,%ebp
c01026f5:	83 ec 28             	sub    $0x28,%esp
    char c;

    int ret;

    switch (tf->tf_trapno) {
c01026f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01026fb:	8b 40 30             	mov    0x30(%eax),%eax
c01026fe:	83 f8 2f             	cmp    $0x2f,%eax
c0102701:	77 1e                	ja     c0102721 <trap_dispatch+0x2f>
c0102703:	83 f8 0e             	cmp    $0xe,%eax
c0102706:	0f 82 1a 01 00 00    	jb     c0102826 <trap_dispatch+0x134>
c010270c:	83 e8 0e             	sub    $0xe,%eax
c010270f:	83 f8 21             	cmp    $0x21,%eax
c0102712:	0f 87 0e 01 00 00    	ja     c0102826 <trap_dispatch+0x134>
c0102718:	8b 04 85 6c 96 10 c0 	mov    -0x3fef6994(,%eax,4),%eax
c010271f:	ff e0                	jmp    *%eax
c0102721:	83 e8 78             	sub    $0x78,%eax
c0102724:	83 f8 01             	cmp    $0x1,%eax
c0102727:	0f 87 f9 00 00 00    	ja     c0102826 <trap_dispatch+0x134>
c010272d:	e9 d8 00 00 00       	jmp    c010280a <trap_dispatch+0x118>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c0102732:	8b 45 08             	mov    0x8(%ebp),%eax
c0102735:	89 04 24             	mov    %eax,(%esp)
c0102738:	e8 55 ff ff ff       	call   c0102692 <pgfault_handler>
c010273d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102740:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0102744:	0f 84 14 01 00 00    	je     c010285e <trap_dispatch+0x16c>
            print_trapframe(tf);
c010274a:	8b 45 08             	mov    0x8(%ebp),%eax
c010274d:	89 04 24             	mov    %eax,(%esp)
c0102750:	e8 4f fc ff ff       	call   c01023a4 <print_trapframe>
            panic("handle pgfault failed. %e\n", ret);
c0102755:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102758:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010275c:	c7 44 24 08 02 96 10 	movl   $0xc0109602,0x8(%esp)
c0102763:	c0 
c0102764:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
c010276b:	00 
c010276c:	c7 04 24 ee 93 10 c0 	movl   $0xc01093ee,(%esp)
c0102773:	e8 96 e5 ff ff       	call   c0100d0e <__panic>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
	    ticks+=1;
c0102778:	a1 24 64 12 c0       	mov    0xc0126424,%eax
c010277d:	40                   	inc    %eax
c010277e:	a3 24 64 12 c0       	mov    %eax,0xc0126424
        if (ticks % TICK_NUM == 0) {
c0102783:	8b 0d 24 64 12 c0    	mov    0xc0126424,%ecx
c0102789:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c010278e:	89 c8                	mov    %ecx,%eax
c0102790:	f7 e2                	mul    %edx
c0102792:	c1 ea 05             	shr    $0x5,%edx
c0102795:	89 d0                	mov    %edx,%eax
c0102797:	c1 e0 02             	shl    $0x2,%eax
c010279a:	01 d0                	add    %edx,%eax
c010279c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01027a3:	01 d0                	add    %edx,%eax
c01027a5:	c1 e0 02             	shl    $0x2,%eax
c01027a8:	29 c1                	sub    %eax,%ecx
c01027aa:	89 ca                	mov    %ecx,%edx
c01027ac:	85 d2                	test   %edx,%edx
c01027ae:	0f 85 ad 00 00 00    	jne    c0102861 <trap_dispatch+0x16f>
            print_ticks();
c01027b4:	e8 ef f9 ff ff       	call   c01021a8 <print_ticks>
        }
        break;
c01027b9:	e9 a3 00 00 00       	jmp    c0102861 <trap_dispatch+0x16f>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c01027be:	e8 2b ef ff ff       	call   c01016ee <cons_getc>
c01027c3:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c01027c6:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c01027ca:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01027ce:	89 54 24 08          	mov    %edx,0x8(%esp)
c01027d2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01027d6:	c7 04 24 1d 96 10 c0 	movl   $0xc010961d,(%esp)
c01027dd:	e8 83 db ff ff       	call   c0100365 <cprintf>
        break;
c01027e2:	eb 7e                	jmp    c0102862 <trap_dispatch+0x170>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c01027e4:	e8 05 ef ff ff       	call   c01016ee <cons_getc>
c01027e9:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c01027ec:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c01027f0:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01027f4:	89 54 24 08          	mov    %edx,0x8(%esp)
c01027f8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01027fc:	c7 04 24 2f 96 10 c0 	movl   $0xc010962f,(%esp)
c0102803:	e8 5d db ff ff       	call   c0100365 <cprintf>
        break;
c0102808:	eb 58                	jmp    c0102862 <trap_dispatch+0x170>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c010280a:	c7 44 24 08 3e 96 10 	movl   $0xc010963e,0x8(%esp)
c0102811:	c0 
c0102812:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c0102819:	00 
c010281a:	c7 04 24 ee 93 10 c0 	movl   $0xc01093ee,(%esp)
c0102821:	e8 e8 e4 ff ff       	call   c0100d0e <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0102826:	8b 45 08             	mov    0x8(%ebp),%eax
c0102829:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010282d:	83 e0 03             	and    $0x3,%eax
c0102830:	85 c0                	test   %eax,%eax
c0102832:	75 2e                	jne    c0102862 <trap_dispatch+0x170>
            print_trapframe(tf);
c0102834:	8b 45 08             	mov    0x8(%ebp),%eax
c0102837:	89 04 24             	mov    %eax,(%esp)
c010283a:	e8 65 fb ff ff       	call   c01023a4 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c010283f:	c7 44 24 08 4e 96 10 	movl   $0xc010964e,0x8(%esp)
c0102846:	c0 
c0102847:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
c010284e:	00 
c010284f:	c7 04 24 ee 93 10 c0 	movl   $0xc01093ee,(%esp)
c0102856:	e8 b3 e4 ff ff       	call   c0100d0e <__panic>
        break;
c010285b:	90                   	nop
c010285c:	eb 04                	jmp    c0102862 <trap_dispatch+0x170>
        break;
c010285e:	90                   	nop
c010285f:	eb 01                	jmp    c0102862 <trap_dispatch+0x170>
        break;
c0102861:	90                   	nop
        }
    }
}
c0102862:	90                   	nop
c0102863:	89 ec                	mov    %ebp,%esp
c0102865:	5d                   	pop    %ebp
c0102866:	c3                   	ret    

c0102867 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0102867:	55                   	push   %ebp
c0102868:	89 e5                	mov    %esp,%ebp
c010286a:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c010286d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102870:	89 04 24             	mov    %eax,(%esp)
c0102873:	e8 7a fe ff ff       	call   c01026f2 <trap_dispatch>
}
c0102878:	90                   	nop
c0102879:	89 ec                	mov    %ebp,%esp
c010287b:	5d                   	pop    %ebp
c010287c:	c3                   	ret    

c010287d <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c010287d:	1e                   	push   %ds
    pushl %es
c010287e:	06                   	push   %es
    pushl %fs
c010287f:	0f a0                	push   %fs
    pushl %gs
c0102881:	0f a8                	push   %gs
    pushal
c0102883:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0102884:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0102889:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c010288b:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c010288d:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c010288e:	e8 d4 ff ff ff       	call   c0102867 <trap>

    # pop the pushed stack pointer
    popl %esp
c0102893:	5c                   	pop    %esp

c0102894 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0102894:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0102895:	0f a9                	pop    %gs
    popl %fs
c0102897:	0f a1                	pop    %fs
    popl %es
c0102899:	07                   	pop    %es
    popl %ds
c010289a:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c010289b:	83 c4 08             	add    $0x8,%esp
    iret
c010289e:	cf                   	iret   

c010289f <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c010289f:	6a 00                	push   $0x0
  pushl $0
c01028a1:	6a 00                	push   $0x0
  jmp __alltraps
c01028a3:	e9 d5 ff ff ff       	jmp    c010287d <__alltraps>

c01028a8 <vector1>:
.globl vector1
vector1:
  pushl $0
c01028a8:	6a 00                	push   $0x0
  pushl $1
c01028aa:	6a 01                	push   $0x1
  jmp __alltraps
c01028ac:	e9 cc ff ff ff       	jmp    c010287d <__alltraps>

c01028b1 <vector2>:
.globl vector2
vector2:
  pushl $0
c01028b1:	6a 00                	push   $0x0
  pushl $2
c01028b3:	6a 02                	push   $0x2
  jmp __alltraps
c01028b5:	e9 c3 ff ff ff       	jmp    c010287d <__alltraps>

c01028ba <vector3>:
.globl vector3
vector3:
  pushl $0
c01028ba:	6a 00                	push   $0x0
  pushl $3
c01028bc:	6a 03                	push   $0x3
  jmp __alltraps
c01028be:	e9 ba ff ff ff       	jmp    c010287d <__alltraps>

c01028c3 <vector4>:
.globl vector4
vector4:
  pushl $0
c01028c3:	6a 00                	push   $0x0
  pushl $4
c01028c5:	6a 04                	push   $0x4
  jmp __alltraps
c01028c7:	e9 b1 ff ff ff       	jmp    c010287d <__alltraps>

c01028cc <vector5>:
.globl vector5
vector5:
  pushl $0
c01028cc:	6a 00                	push   $0x0
  pushl $5
c01028ce:	6a 05                	push   $0x5
  jmp __alltraps
c01028d0:	e9 a8 ff ff ff       	jmp    c010287d <__alltraps>

c01028d5 <vector6>:
.globl vector6
vector6:
  pushl $0
c01028d5:	6a 00                	push   $0x0
  pushl $6
c01028d7:	6a 06                	push   $0x6
  jmp __alltraps
c01028d9:	e9 9f ff ff ff       	jmp    c010287d <__alltraps>

c01028de <vector7>:
.globl vector7
vector7:
  pushl $0
c01028de:	6a 00                	push   $0x0
  pushl $7
c01028e0:	6a 07                	push   $0x7
  jmp __alltraps
c01028e2:	e9 96 ff ff ff       	jmp    c010287d <__alltraps>

c01028e7 <vector8>:
.globl vector8
vector8:
  pushl $8
c01028e7:	6a 08                	push   $0x8
  jmp __alltraps
c01028e9:	e9 8f ff ff ff       	jmp    c010287d <__alltraps>

c01028ee <vector9>:
.globl vector9
vector9:
  pushl $0
c01028ee:	6a 00                	push   $0x0
  pushl $9
c01028f0:	6a 09                	push   $0x9
  jmp __alltraps
c01028f2:	e9 86 ff ff ff       	jmp    c010287d <__alltraps>

c01028f7 <vector10>:
.globl vector10
vector10:
  pushl $10
c01028f7:	6a 0a                	push   $0xa
  jmp __alltraps
c01028f9:	e9 7f ff ff ff       	jmp    c010287d <__alltraps>

c01028fe <vector11>:
.globl vector11
vector11:
  pushl $11
c01028fe:	6a 0b                	push   $0xb
  jmp __alltraps
c0102900:	e9 78 ff ff ff       	jmp    c010287d <__alltraps>

c0102905 <vector12>:
.globl vector12
vector12:
  pushl $12
c0102905:	6a 0c                	push   $0xc
  jmp __alltraps
c0102907:	e9 71 ff ff ff       	jmp    c010287d <__alltraps>

c010290c <vector13>:
.globl vector13
vector13:
  pushl $13
c010290c:	6a 0d                	push   $0xd
  jmp __alltraps
c010290e:	e9 6a ff ff ff       	jmp    c010287d <__alltraps>

c0102913 <vector14>:
.globl vector14
vector14:
  pushl $14
c0102913:	6a 0e                	push   $0xe
  jmp __alltraps
c0102915:	e9 63 ff ff ff       	jmp    c010287d <__alltraps>

c010291a <vector15>:
.globl vector15
vector15:
  pushl $0
c010291a:	6a 00                	push   $0x0
  pushl $15
c010291c:	6a 0f                	push   $0xf
  jmp __alltraps
c010291e:	e9 5a ff ff ff       	jmp    c010287d <__alltraps>

c0102923 <vector16>:
.globl vector16
vector16:
  pushl $0
c0102923:	6a 00                	push   $0x0
  pushl $16
c0102925:	6a 10                	push   $0x10
  jmp __alltraps
c0102927:	e9 51 ff ff ff       	jmp    c010287d <__alltraps>

c010292c <vector17>:
.globl vector17
vector17:
  pushl $17
c010292c:	6a 11                	push   $0x11
  jmp __alltraps
c010292e:	e9 4a ff ff ff       	jmp    c010287d <__alltraps>

c0102933 <vector18>:
.globl vector18
vector18:
  pushl $0
c0102933:	6a 00                	push   $0x0
  pushl $18
c0102935:	6a 12                	push   $0x12
  jmp __alltraps
c0102937:	e9 41 ff ff ff       	jmp    c010287d <__alltraps>

c010293c <vector19>:
.globl vector19
vector19:
  pushl $0
c010293c:	6a 00                	push   $0x0
  pushl $19
c010293e:	6a 13                	push   $0x13
  jmp __alltraps
c0102940:	e9 38 ff ff ff       	jmp    c010287d <__alltraps>

c0102945 <vector20>:
.globl vector20
vector20:
  pushl $0
c0102945:	6a 00                	push   $0x0
  pushl $20
c0102947:	6a 14                	push   $0x14
  jmp __alltraps
c0102949:	e9 2f ff ff ff       	jmp    c010287d <__alltraps>

c010294e <vector21>:
.globl vector21
vector21:
  pushl $0
c010294e:	6a 00                	push   $0x0
  pushl $21
c0102950:	6a 15                	push   $0x15
  jmp __alltraps
c0102952:	e9 26 ff ff ff       	jmp    c010287d <__alltraps>

c0102957 <vector22>:
.globl vector22
vector22:
  pushl $0
c0102957:	6a 00                	push   $0x0
  pushl $22
c0102959:	6a 16                	push   $0x16
  jmp __alltraps
c010295b:	e9 1d ff ff ff       	jmp    c010287d <__alltraps>

c0102960 <vector23>:
.globl vector23
vector23:
  pushl $0
c0102960:	6a 00                	push   $0x0
  pushl $23
c0102962:	6a 17                	push   $0x17
  jmp __alltraps
c0102964:	e9 14 ff ff ff       	jmp    c010287d <__alltraps>

c0102969 <vector24>:
.globl vector24
vector24:
  pushl $0
c0102969:	6a 00                	push   $0x0
  pushl $24
c010296b:	6a 18                	push   $0x18
  jmp __alltraps
c010296d:	e9 0b ff ff ff       	jmp    c010287d <__alltraps>

c0102972 <vector25>:
.globl vector25
vector25:
  pushl $0
c0102972:	6a 00                	push   $0x0
  pushl $25
c0102974:	6a 19                	push   $0x19
  jmp __alltraps
c0102976:	e9 02 ff ff ff       	jmp    c010287d <__alltraps>

c010297b <vector26>:
.globl vector26
vector26:
  pushl $0
c010297b:	6a 00                	push   $0x0
  pushl $26
c010297d:	6a 1a                	push   $0x1a
  jmp __alltraps
c010297f:	e9 f9 fe ff ff       	jmp    c010287d <__alltraps>

c0102984 <vector27>:
.globl vector27
vector27:
  pushl $0
c0102984:	6a 00                	push   $0x0
  pushl $27
c0102986:	6a 1b                	push   $0x1b
  jmp __alltraps
c0102988:	e9 f0 fe ff ff       	jmp    c010287d <__alltraps>

c010298d <vector28>:
.globl vector28
vector28:
  pushl $0
c010298d:	6a 00                	push   $0x0
  pushl $28
c010298f:	6a 1c                	push   $0x1c
  jmp __alltraps
c0102991:	e9 e7 fe ff ff       	jmp    c010287d <__alltraps>

c0102996 <vector29>:
.globl vector29
vector29:
  pushl $0
c0102996:	6a 00                	push   $0x0
  pushl $29
c0102998:	6a 1d                	push   $0x1d
  jmp __alltraps
c010299a:	e9 de fe ff ff       	jmp    c010287d <__alltraps>

c010299f <vector30>:
.globl vector30
vector30:
  pushl $0
c010299f:	6a 00                	push   $0x0
  pushl $30
c01029a1:	6a 1e                	push   $0x1e
  jmp __alltraps
c01029a3:	e9 d5 fe ff ff       	jmp    c010287d <__alltraps>

c01029a8 <vector31>:
.globl vector31
vector31:
  pushl $0
c01029a8:	6a 00                	push   $0x0
  pushl $31
c01029aa:	6a 1f                	push   $0x1f
  jmp __alltraps
c01029ac:	e9 cc fe ff ff       	jmp    c010287d <__alltraps>

c01029b1 <vector32>:
.globl vector32
vector32:
  pushl $0
c01029b1:	6a 00                	push   $0x0
  pushl $32
c01029b3:	6a 20                	push   $0x20
  jmp __alltraps
c01029b5:	e9 c3 fe ff ff       	jmp    c010287d <__alltraps>

c01029ba <vector33>:
.globl vector33
vector33:
  pushl $0
c01029ba:	6a 00                	push   $0x0
  pushl $33
c01029bc:	6a 21                	push   $0x21
  jmp __alltraps
c01029be:	e9 ba fe ff ff       	jmp    c010287d <__alltraps>

c01029c3 <vector34>:
.globl vector34
vector34:
  pushl $0
c01029c3:	6a 00                	push   $0x0
  pushl $34
c01029c5:	6a 22                	push   $0x22
  jmp __alltraps
c01029c7:	e9 b1 fe ff ff       	jmp    c010287d <__alltraps>

c01029cc <vector35>:
.globl vector35
vector35:
  pushl $0
c01029cc:	6a 00                	push   $0x0
  pushl $35
c01029ce:	6a 23                	push   $0x23
  jmp __alltraps
c01029d0:	e9 a8 fe ff ff       	jmp    c010287d <__alltraps>

c01029d5 <vector36>:
.globl vector36
vector36:
  pushl $0
c01029d5:	6a 00                	push   $0x0
  pushl $36
c01029d7:	6a 24                	push   $0x24
  jmp __alltraps
c01029d9:	e9 9f fe ff ff       	jmp    c010287d <__alltraps>

c01029de <vector37>:
.globl vector37
vector37:
  pushl $0
c01029de:	6a 00                	push   $0x0
  pushl $37
c01029e0:	6a 25                	push   $0x25
  jmp __alltraps
c01029e2:	e9 96 fe ff ff       	jmp    c010287d <__alltraps>

c01029e7 <vector38>:
.globl vector38
vector38:
  pushl $0
c01029e7:	6a 00                	push   $0x0
  pushl $38
c01029e9:	6a 26                	push   $0x26
  jmp __alltraps
c01029eb:	e9 8d fe ff ff       	jmp    c010287d <__alltraps>

c01029f0 <vector39>:
.globl vector39
vector39:
  pushl $0
c01029f0:	6a 00                	push   $0x0
  pushl $39
c01029f2:	6a 27                	push   $0x27
  jmp __alltraps
c01029f4:	e9 84 fe ff ff       	jmp    c010287d <__alltraps>

c01029f9 <vector40>:
.globl vector40
vector40:
  pushl $0
c01029f9:	6a 00                	push   $0x0
  pushl $40
c01029fb:	6a 28                	push   $0x28
  jmp __alltraps
c01029fd:	e9 7b fe ff ff       	jmp    c010287d <__alltraps>

c0102a02 <vector41>:
.globl vector41
vector41:
  pushl $0
c0102a02:	6a 00                	push   $0x0
  pushl $41
c0102a04:	6a 29                	push   $0x29
  jmp __alltraps
c0102a06:	e9 72 fe ff ff       	jmp    c010287d <__alltraps>

c0102a0b <vector42>:
.globl vector42
vector42:
  pushl $0
c0102a0b:	6a 00                	push   $0x0
  pushl $42
c0102a0d:	6a 2a                	push   $0x2a
  jmp __alltraps
c0102a0f:	e9 69 fe ff ff       	jmp    c010287d <__alltraps>

c0102a14 <vector43>:
.globl vector43
vector43:
  pushl $0
c0102a14:	6a 00                	push   $0x0
  pushl $43
c0102a16:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102a18:	e9 60 fe ff ff       	jmp    c010287d <__alltraps>

c0102a1d <vector44>:
.globl vector44
vector44:
  pushl $0
c0102a1d:	6a 00                	push   $0x0
  pushl $44
c0102a1f:	6a 2c                	push   $0x2c
  jmp __alltraps
c0102a21:	e9 57 fe ff ff       	jmp    c010287d <__alltraps>

c0102a26 <vector45>:
.globl vector45
vector45:
  pushl $0
c0102a26:	6a 00                	push   $0x0
  pushl $45
c0102a28:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102a2a:	e9 4e fe ff ff       	jmp    c010287d <__alltraps>

c0102a2f <vector46>:
.globl vector46
vector46:
  pushl $0
c0102a2f:	6a 00                	push   $0x0
  pushl $46
c0102a31:	6a 2e                	push   $0x2e
  jmp __alltraps
c0102a33:	e9 45 fe ff ff       	jmp    c010287d <__alltraps>

c0102a38 <vector47>:
.globl vector47
vector47:
  pushl $0
c0102a38:	6a 00                	push   $0x0
  pushl $47
c0102a3a:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102a3c:	e9 3c fe ff ff       	jmp    c010287d <__alltraps>

c0102a41 <vector48>:
.globl vector48
vector48:
  pushl $0
c0102a41:	6a 00                	push   $0x0
  pushl $48
c0102a43:	6a 30                	push   $0x30
  jmp __alltraps
c0102a45:	e9 33 fe ff ff       	jmp    c010287d <__alltraps>

c0102a4a <vector49>:
.globl vector49
vector49:
  pushl $0
c0102a4a:	6a 00                	push   $0x0
  pushl $49
c0102a4c:	6a 31                	push   $0x31
  jmp __alltraps
c0102a4e:	e9 2a fe ff ff       	jmp    c010287d <__alltraps>

c0102a53 <vector50>:
.globl vector50
vector50:
  pushl $0
c0102a53:	6a 00                	push   $0x0
  pushl $50
c0102a55:	6a 32                	push   $0x32
  jmp __alltraps
c0102a57:	e9 21 fe ff ff       	jmp    c010287d <__alltraps>

c0102a5c <vector51>:
.globl vector51
vector51:
  pushl $0
c0102a5c:	6a 00                	push   $0x0
  pushl $51
c0102a5e:	6a 33                	push   $0x33
  jmp __alltraps
c0102a60:	e9 18 fe ff ff       	jmp    c010287d <__alltraps>

c0102a65 <vector52>:
.globl vector52
vector52:
  pushl $0
c0102a65:	6a 00                	push   $0x0
  pushl $52
c0102a67:	6a 34                	push   $0x34
  jmp __alltraps
c0102a69:	e9 0f fe ff ff       	jmp    c010287d <__alltraps>

c0102a6e <vector53>:
.globl vector53
vector53:
  pushl $0
c0102a6e:	6a 00                	push   $0x0
  pushl $53
c0102a70:	6a 35                	push   $0x35
  jmp __alltraps
c0102a72:	e9 06 fe ff ff       	jmp    c010287d <__alltraps>

c0102a77 <vector54>:
.globl vector54
vector54:
  pushl $0
c0102a77:	6a 00                	push   $0x0
  pushl $54
c0102a79:	6a 36                	push   $0x36
  jmp __alltraps
c0102a7b:	e9 fd fd ff ff       	jmp    c010287d <__alltraps>

c0102a80 <vector55>:
.globl vector55
vector55:
  pushl $0
c0102a80:	6a 00                	push   $0x0
  pushl $55
c0102a82:	6a 37                	push   $0x37
  jmp __alltraps
c0102a84:	e9 f4 fd ff ff       	jmp    c010287d <__alltraps>

c0102a89 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102a89:	6a 00                	push   $0x0
  pushl $56
c0102a8b:	6a 38                	push   $0x38
  jmp __alltraps
c0102a8d:	e9 eb fd ff ff       	jmp    c010287d <__alltraps>

c0102a92 <vector57>:
.globl vector57
vector57:
  pushl $0
c0102a92:	6a 00                	push   $0x0
  pushl $57
c0102a94:	6a 39                	push   $0x39
  jmp __alltraps
c0102a96:	e9 e2 fd ff ff       	jmp    c010287d <__alltraps>

c0102a9b <vector58>:
.globl vector58
vector58:
  pushl $0
c0102a9b:	6a 00                	push   $0x0
  pushl $58
c0102a9d:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102a9f:	e9 d9 fd ff ff       	jmp    c010287d <__alltraps>

c0102aa4 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102aa4:	6a 00                	push   $0x0
  pushl $59
c0102aa6:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102aa8:	e9 d0 fd ff ff       	jmp    c010287d <__alltraps>

c0102aad <vector60>:
.globl vector60
vector60:
  pushl $0
c0102aad:	6a 00                	push   $0x0
  pushl $60
c0102aaf:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102ab1:	e9 c7 fd ff ff       	jmp    c010287d <__alltraps>

c0102ab6 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102ab6:	6a 00                	push   $0x0
  pushl $61
c0102ab8:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102aba:	e9 be fd ff ff       	jmp    c010287d <__alltraps>

c0102abf <vector62>:
.globl vector62
vector62:
  pushl $0
c0102abf:	6a 00                	push   $0x0
  pushl $62
c0102ac1:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102ac3:	e9 b5 fd ff ff       	jmp    c010287d <__alltraps>

c0102ac8 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102ac8:	6a 00                	push   $0x0
  pushl $63
c0102aca:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102acc:	e9 ac fd ff ff       	jmp    c010287d <__alltraps>

c0102ad1 <vector64>:
.globl vector64
vector64:
  pushl $0
c0102ad1:	6a 00                	push   $0x0
  pushl $64
c0102ad3:	6a 40                	push   $0x40
  jmp __alltraps
c0102ad5:	e9 a3 fd ff ff       	jmp    c010287d <__alltraps>

c0102ada <vector65>:
.globl vector65
vector65:
  pushl $0
c0102ada:	6a 00                	push   $0x0
  pushl $65
c0102adc:	6a 41                	push   $0x41
  jmp __alltraps
c0102ade:	e9 9a fd ff ff       	jmp    c010287d <__alltraps>

c0102ae3 <vector66>:
.globl vector66
vector66:
  pushl $0
c0102ae3:	6a 00                	push   $0x0
  pushl $66
c0102ae5:	6a 42                	push   $0x42
  jmp __alltraps
c0102ae7:	e9 91 fd ff ff       	jmp    c010287d <__alltraps>

c0102aec <vector67>:
.globl vector67
vector67:
  pushl $0
c0102aec:	6a 00                	push   $0x0
  pushl $67
c0102aee:	6a 43                	push   $0x43
  jmp __alltraps
c0102af0:	e9 88 fd ff ff       	jmp    c010287d <__alltraps>

c0102af5 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102af5:	6a 00                	push   $0x0
  pushl $68
c0102af7:	6a 44                	push   $0x44
  jmp __alltraps
c0102af9:	e9 7f fd ff ff       	jmp    c010287d <__alltraps>

c0102afe <vector69>:
.globl vector69
vector69:
  pushl $0
c0102afe:	6a 00                	push   $0x0
  pushl $69
c0102b00:	6a 45                	push   $0x45
  jmp __alltraps
c0102b02:	e9 76 fd ff ff       	jmp    c010287d <__alltraps>

c0102b07 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102b07:	6a 00                	push   $0x0
  pushl $70
c0102b09:	6a 46                	push   $0x46
  jmp __alltraps
c0102b0b:	e9 6d fd ff ff       	jmp    c010287d <__alltraps>

c0102b10 <vector71>:
.globl vector71
vector71:
  pushl $0
c0102b10:	6a 00                	push   $0x0
  pushl $71
c0102b12:	6a 47                	push   $0x47
  jmp __alltraps
c0102b14:	e9 64 fd ff ff       	jmp    c010287d <__alltraps>

c0102b19 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102b19:	6a 00                	push   $0x0
  pushl $72
c0102b1b:	6a 48                	push   $0x48
  jmp __alltraps
c0102b1d:	e9 5b fd ff ff       	jmp    c010287d <__alltraps>

c0102b22 <vector73>:
.globl vector73
vector73:
  pushl $0
c0102b22:	6a 00                	push   $0x0
  pushl $73
c0102b24:	6a 49                	push   $0x49
  jmp __alltraps
c0102b26:	e9 52 fd ff ff       	jmp    c010287d <__alltraps>

c0102b2b <vector74>:
.globl vector74
vector74:
  pushl $0
c0102b2b:	6a 00                	push   $0x0
  pushl $74
c0102b2d:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102b2f:	e9 49 fd ff ff       	jmp    c010287d <__alltraps>

c0102b34 <vector75>:
.globl vector75
vector75:
  pushl $0
c0102b34:	6a 00                	push   $0x0
  pushl $75
c0102b36:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102b38:	e9 40 fd ff ff       	jmp    c010287d <__alltraps>

c0102b3d <vector76>:
.globl vector76
vector76:
  pushl $0
c0102b3d:	6a 00                	push   $0x0
  pushl $76
c0102b3f:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102b41:	e9 37 fd ff ff       	jmp    c010287d <__alltraps>

c0102b46 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102b46:	6a 00                	push   $0x0
  pushl $77
c0102b48:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102b4a:	e9 2e fd ff ff       	jmp    c010287d <__alltraps>

c0102b4f <vector78>:
.globl vector78
vector78:
  pushl $0
c0102b4f:	6a 00                	push   $0x0
  pushl $78
c0102b51:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102b53:	e9 25 fd ff ff       	jmp    c010287d <__alltraps>

c0102b58 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102b58:	6a 00                	push   $0x0
  pushl $79
c0102b5a:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102b5c:	e9 1c fd ff ff       	jmp    c010287d <__alltraps>

c0102b61 <vector80>:
.globl vector80
vector80:
  pushl $0
c0102b61:	6a 00                	push   $0x0
  pushl $80
c0102b63:	6a 50                	push   $0x50
  jmp __alltraps
c0102b65:	e9 13 fd ff ff       	jmp    c010287d <__alltraps>

c0102b6a <vector81>:
.globl vector81
vector81:
  pushl $0
c0102b6a:	6a 00                	push   $0x0
  pushl $81
c0102b6c:	6a 51                	push   $0x51
  jmp __alltraps
c0102b6e:	e9 0a fd ff ff       	jmp    c010287d <__alltraps>

c0102b73 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102b73:	6a 00                	push   $0x0
  pushl $82
c0102b75:	6a 52                	push   $0x52
  jmp __alltraps
c0102b77:	e9 01 fd ff ff       	jmp    c010287d <__alltraps>

c0102b7c <vector83>:
.globl vector83
vector83:
  pushl $0
c0102b7c:	6a 00                	push   $0x0
  pushl $83
c0102b7e:	6a 53                	push   $0x53
  jmp __alltraps
c0102b80:	e9 f8 fc ff ff       	jmp    c010287d <__alltraps>

c0102b85 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102b85:	6a 00                	push   $0x0
  pushl $84
c0102b87:	6a 54                	push   $0x54
  jmp __alltraps
c0102b89:	e9 ef fc ff ff       	jmp    c010287d <__alltraps>

c0102b8e <vector85>:
.globl vector85
vector85:
  pushl $0
c0102b8e:	6a 00                	push   $0x0
  pushl $85
c0102b90:	6a 55                	push   $0x55
  jmp __alltraps
c0102b92:	e9 e6 fc ff ff       	jmp    c010287d <__alltraps>

c0102b97 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102b97:	6a 00                	push   $0x0
  pushl $86
c0102b99:	6a 56                	push   $0x56
  jmp __alltraps
c0102b9b:	e9 dd fc ff ff       	jmp    c010287d <__alltraps>

c0102ba0 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102ba0:	6a 00                	push   $0x0
  pushl $87
c0102ba2:	6a 57                	push   $0x57
  jmp __alltraps
c0102ba4:	e9 d4 fc ff ff       	jmp    c010287d <__alltraps>

c0102ba9 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102ba9:	6a 00                	push   $0x0
  pushl $88
c0102bab:	6a 58                	push   $0x58
  jmp __alltraps
c0102bad:	e9 cb fc ff ff       	jmp    c010287d <__alltraps>

c0102bb2 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102bb2:	6a 00                	push   $0x0
  pushl $89
c0102bb4:	6a 59                	push   $0x59
  jmp __alltraps
c0102bb6:	e9 c2 fc ff ff       	jmp    c010287d <__alltraps>

c0102bbb <vector90>:
.globl vector90
vector90:
  pushl $0
c0102bbb:	6a 00                	push   $0x0
  pushl $90
c0102bbd:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102bbf:	e9 b9 fc ff ff       	jmp    c010287d <__alltraps>

c0102bc4 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102bc4:	6a 00                	push   $0x0
  pushl $91
c0102bc6:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102bc8:	e9 b0 fc ff ff       	jmp    c010287d <__alltraps>

c0102bcd <vector92>:
.globl vector92
vector92:
  pushl $0
c0102bcd:	6a 00                	push   $0x0
  pushl $92
c0102bcf:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102bd1:	e9 a7 fc ff ff       	jmp    c010287d <__alltraps>

c0102bd6 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102bd6:	6a 00                	push   $0x0
  pushl $93
c0102bd8:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102bda:	e9 9e fc ff ff       	jmp    c010287d <__alltraps>

c0102bdf <vector94>:
.globl vector94
vector94:
  pushl $0
c0102bdf:	6a 00                	push   $0x0
  pushl $94
c0102be1:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102be3:	e9 95 fc ff ff       	jmp    c010287d <__alltraps>

c0102be8 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102be8:	6a 00                	push   $0x0
  pushl $95
c0102bea:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102bec:	e9 8c fc ff ff       	jmp    c010287d <__alltraps>

c0102bf1 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102bf1:	6a 00                	push   $0x0
  pushl $96
c0102bf3:	6a 60                	push   $0x60
  jmp __alltraps
c0102bf5:	e9 83 fc ff ff       	jmp    c010287d <__alltraps>

c0102bfa <vector97>:
.globl vector97
vector97:
  pushl $0
c0102bfa:	6a 00                	push   $0x0
  pushl $97
c0102bfc:	6a 61                	push   $0x61
  jmp __alltraps
c0102bfe:	e9 7a fc ff ff       	jmp    c010287d <__alltraps>

c0102c03 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102c03:	6a 00                	push   $0x0
  pushl $98
c0102c05:	6a 62                	push   $0x62
  jmp __alltraps
c0102c07:	e9 71 fc ff ff       	jmp    c010287d <__alltraps>

c0102c0c <vector99>:
.globl vector99
vector99:
  pushl $0
c0102c0c:	6a 00                	push   $0x0
  pushl $99
c0102c0e:	6a 63                	push   $0x63
  jmp __alltraps
c0102c10:	e9 68 fc ff ff       	jmp    c010287d <__alltraps>

c0102c15 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102c15:	6a 00                	push   $0x0
  pushl $100
c0102c17:	6a 64                	push   $0x64
  jmp __alltraps
c0102c19:	e9 5f fc ff ff       	jmp    c010287d <__alltraps>

c0102c1e <vector101>:
.globl vector101
vector101:
  pushl $0
c0102c1e:	6a 00                	push   $0x0
  pushl $101
c0102c20:	6a 65                	push   $0x65
  jmp __alltraps
c0102c22:	e9 56 fc ff ff       	jmp    c010287d <__alltraps>

c0102c27 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102c27:	6a 00                	push   $0x0
  pushl $102
c0102c29:	6a 66                	push   $0x66
  jmp __alltraps
c0102c2b:	e9 4d fc ff ff       	jmp    c010287d <__alltraps>

c0102c30 <vector103>:
.globl vector103
vector103:
  pushl $0
c0102c30:	6a 00                	push   $0x0
  pushl $103
c0102c32:	6a 67                	push   $0x67
  jmp __alltraps
c0102c34:	e9 44 fc ff ff       	jmp    c010287d <__alltraps>

c0102c39 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102c39:	6a 00                	push   $0x0
  pushl $104
c0102c3b:	6a 68                	push   $0x68
  jmp __alltraps
c0102c3d:	e9 3b fc ff ff       	jmp    c010287d <__alltraps>

c0102c42 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102c42:	6a 00                	push   $0x0
  pushl $105
c0102c44:	6a 69                	push   $0x69
  jmp __alltraps
c0102c46:	e9 32 fc ff ff       	jmp    c010287d <__alltraps>

c0102c4b <vector106>:
.globl vector106
vector106:
  pushl $0
c0102c4b:	6a 00                	push   $0x0
  pushl $106
c0102c4d:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102c4f:	e9 29 fc ff ff       	jmp    c010287d <__alltraps>

c0102c54 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102c54:	6a 00                	push   $0x0
  pushl $107
c0102c56:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102c58:	e9 20 fc ff ff       	jmp    c010287d <__alltraps>

c0102c5d <vector108>:
.globl vector108
vector108:
  pushl $0
c0102c5d:	6a 00                	push   $0x0
  pushl $108
c0102c5f:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102c61:	e9 17 fc ff ff       	jmp    c010287d <__alltraps>

c0102c66 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102c66:	6a 00                	push   $0x0
  pushl $109
c0102c68:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102c6a:	e9 0e fc ff ff       	jmp    c010287d <__alltraps>

c0102c6f <vector110>:
.globl vector110
vector110:
  pushl $0
c0102c6f:	6a 00                	push   $0x0
  pushl $110
c0102c71:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102c73:	e9 05 fc ff ff       	jmp    c010287d <__alltraps>

c0102c78 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102c78:	6a 00                	push   $0x0
  pushl $111
c0102c7a:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102c7c:	e9 fc fb ff ff       	jmp    c010287d <__alltraps>

c0102c81 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102c81:	6a 00                	push   $0x0
  pushl $112
c0102c83:	6a 70                	push   $0x70
  jmp __alltraps
c0102c85:	e9 f3 fb ff ff       	jmp    c010287d <__alltraps>

c0102c8a <vector113>:
.globl vector113
vector113:
  pushl $0
c0102c8a:	6a 00                	push   $0x0
  pushl $113
c0102c8c:	6a 71                	push   $0x71
  jmp __alltraps
c0102c8e:	e9 ea fb ff ff       	jmp    c010287d <__alltraps>

c0102c93 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102c93:	6a 00                	push   $0x0
  pushl $114
c0102c95:	6a 72                	push   $0x72
  jmp __alltraps
c0102c97:	e9 e1 fb ff ff       	jmp    c010287d <__alltraps>

c0102c9c <vector115>:
.globl vector115
vector115:
  pushl $0
c0102c9c:	6a 00                	push   $0x0
  pushl $115
c0102c9e:	6a 73                	push   $0x73
  jmp __alltraps
c0102ca0:	e9 d8 fb ff ff       	jmp    c010287d <__alltraps>

c0102ca5 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102ca5:	6a 00                	push   $0x0
  pushl $116
c0102ca7:	6a 74                	push   $0x74
  jmp __alltraps
c0102ca9:	e9 cf fb ff ff       	jmp    c010287d <__alltraps>

c0102cae <vector117>:
.globl vector117
vector117:
  pushl $0
c0102cae:	6a 00                	push   $0x0
  pushl $117
c0102cb0:	6a 75                	push   $0x75
  jmp __alltraps
c0102cb2:	e9 c6 fb ff ff       	jmp    c010287d <__alltraps>

c0102cb7 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102cb7:	6a 00                	push   $0x0
  pushl $118
c0102cb9:	6a 76                	push   $0x76
  jmp __alltraps
c0102cbb:	e9 bd fb ff ff       	jmp    c010287d <__alltraps>

c0102cc0 <vector119>:
.globl vector119
vector119:
  pushl $0
c0102cc0:	6a 00                	push   $0x0
  pushl $119
c0102cc2:	6a 77                	push   $0x77
  jmp __alltraps
c0102cc4:	e9 b4 fb ff ff       	jmp    c010287d <__alltraps>

c0102cc9 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102cc9:	6a 00                	push   $0x0
  pushl $120
c0102ccb:	6a 78                	push   $0x78
  jmp __alltraps
c0102ccd:	e9 ab fb ff ff       	jmp    c010287d <__alltraps>

c0102cd2 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102cd2:	6a 00                	push   $0x0
  pushl $121
c0102cd4:	6a 79                	push   $0x79
  jmp __alltraps
c0102cd6:	e9 a2 fb ff ff       	jmp    c010287d <__alltraps>

c0102cdb <vector122>:
.globl vector122
vector122:
  pushl $0
c0102cdb:	6a 00                	push   $0x0
  pushl $122
c0102cdd:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102cdf:	e9 99 fb ff ff       	jmp    c010287d <__alltraps>

c0102ce4 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102ce4:	6a 00                	push   $0x0
  pushl $123
c0102ce6:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102ce8:	e9 90 fb ff ff       	jmp    c010287d <__alltraps>

c0102ced <vector124>:
.globl vector124
vector124:
  pushl $0
c0102ced:	6a 00                	push   $0x0
  pushl $124
c0102cef:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102cf1:	e9 87 fb ff ff       	jmp    c010287d <__alltraps>

c0102cf6 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102cf6:	6a 00                	push   $0x0
  pushl $125
c0102cf8:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102cfa:	e9 7e fb ff ff       	jmp    c010287d <__alltraps>

c0102cff <vector126>:
.globl vector126
vector126:
  pushl $0
c0102cff:	6a 00                	push   $0x0
  pushl $126
c0102d01:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102d03:	e9 75 fb ff ff       	jmp    c010287d <__alltraps>

c0102d08 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102d08:	6a 00                	push   $0x0
  pushl $127
c0102d0a:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102d0c:	e9 6c fb ff ff       	jmp    c010287d <__alltraps>

c0102d11 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102d11:	6a 00                	push   $0x0
  pushl $128
c0102d13:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102d18:	e9 60 fb ff ff       	jmp    c010287d <__alltraps>

c0102d1d <vector129>:
.globl vector129
vector129:
  pushl $0
c0102d1d:	6a 00                	push   $0x0
  pushl $129
c0102d1f:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102d24:	e9 54 fb ff ff       	jmp    c010287d <__alltraps>

c0102d29 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102d29:	6a 00                	push   $0x0
  pushl $130
c0102d2b:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102d30:	e9 48 fb ff ff       	jmp    c010287d <__alltraps>

c0102d35 <vector131>:
.globl vector131
vector131:
  pushl $0
c0102d35:	6a 00                	push   $0x0
  pushl $131
c0102d37:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102d3c:	e9 3c fb ff ff       	jmp    c010287d <__alltraps>

c0102d41 <vector132>:
.globl vector132
vector132:
  pushl $0
c0102d41:	6a 00                	push   $0x0
  pushl $132
c0102d43:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102d48:	e9 30 fb ff ff       	jmp    c010287d <__alltraps>

c0102d4d <vector133>:
.globl vector133
vector133:
  pushl $0
c0102d4d:	6a 00                	push   $0x0
  pushl $133
c0102d4f:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102d54:	e9 24 fb ff ff       	jmp    c010287d <__alltraps>

c0102d59 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102d59:	6a 00                	push   $0x0
  pushl $134
c0102d5b:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102d60:	e9 18 fb ff ff       	jmp    c010287d <__alltraps>

c0102d65 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102d65:	6a 00                	push   $0x0
  pushl $135
c0102d67:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102d6c:	e9 0c fb ff ff       	jmp    c010287d <__alltraps>

c0102d71 <vector136>:
.globl vector136
vector136:
  pushl $0
c0102d71:	6a 00                	push   $0x0
  pushl $136
c0102d73:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102d78:	e9 00 fb ff ff       	jmp    c010287d <__alltraps>

c0102d7d <vector137>:
.globl vector137
vector137:
  pushl $0
c0102d7d:	6a 00                	push   $0x0
  pushl $137
c0102d7f:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102d84:	e9 f4 fa ff ff       	jmp    c010287d <__alltraps>

c0102d89 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102d89:	6a 00                	push   $0x0
  pushl $138
c0102d8b:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102d90:	e9 e8 fa ff ff       	jmp    c010287d <__alltraps>

c0102d95 <vector139>:
.globl vector139
vector139:
  pushl $0
c0102d95:	6a 00                	push   $0x0
  pushl $139
c0102d97:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102d9c:	e9 dc fa ff ff       	jmp    c010287d <__alltraps>

c0102da1 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102da1:	6a 00                	push   $0x0
  pushl $140
c0102da3:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102da8:	e9 d0 fa ff ff       	jmp    c010287d <__alltraps>

c0102dad <vector141>:
.globl vector141
vector141:
  pushl $0
c0102dad:	6a 00                	push   $0x0
  pushl $141
c0102daf:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102db4:	e9 c4 fa ff ff       	jmp    c010287d <__alltraps>

c0102db9 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102db9:	6a 00                	push   $0x0
  pushl $142
c0102dbb:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102dc0:	e9 b8 fa ff ff       	jmp    c010287d <__alltraps>

c0102dc5 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102dc5:	6a 00                	push   $0x0
  pushl $143
c0102dc7:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102dcc:	e9 ac fa ff ff       	jmp    c010287d <__alltraps>

c0102dd1 <vector144>:
.globl vector144
vector144:
  pushl $0
c0102dd1:	6a 00                	push   $0x0
  pushl $144
c0102dd3:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102dd8:	e9 a0 fa ff ff       	jmp    c010287d <__alltraps>

c0102ddd <vector145>:
.globl vector145
vector145:
  pushl $0
c0102ddd:	6a 00                	push   $0x0
  pushl $145
c0102ddf:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102de4:	e9 94 fa ff ff       	jmp    c010287d <__alltraps>

c0102de9 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102de9:	6a 00                	push   $0x0
  pushl $146
c0102deb:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102df0:	e9 88 fa ff ff       	jmp    c010287d <__alltraps>

c0102df5 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102df5:	6a 00                	push   $0x0
  pushl $147
c0102df7:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102dfc:	e9 7c fa ff ff       	jmp    c010287d <__alltraps>

c0102e01 <vector148>:
.globl vector148
vector148:
  pushl $0
c0102e01:	6a 00                	push   $0x0
  pushl $148
c0102e03:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102e08:	e9 70 fa ff ff       	jmp    c010287d <__alltraps>

c0102e0d <vector149>:
.globl vector149
vector149:
  pushl $0
c0102e0d:	6a 00                	push   $0x0
  pushl $149
c0102e0f:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102e14:	e9 64 fa ff ff       	jmp    c010287d <__alltraps>

c0102e19 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102e19:	6a 00                	push   $0x0
  pushl $150
c0102e1b:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102e20:	e9 58 fa ff ff       	jmp    c010287d <__alltraps>

c0102e25 <vector151>:
.globl vector151
vector151:
  pushl $0
c0102e25:	6a 00                	push   $0x0
  pushl $151
c0102e27:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102e2c:	e9 4c fa ff ff       	jmp    c010287d <__alltraps>

c0102e31 <vector152>:
.globl vector152
vector152:
  pushl $0
c0102e31:	6a 00                	push   $0x0
  pushl $152
c0102e33:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102e38:	e9 40 fa ff ff       	jmp    c010287d <__alltraps>

c0102e3d <vector153>:
.globl vector153
vector153:
  pushl $0
c0102e3d:	6a 00                	push   $0x0
  pushl $153
c0102e3f:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102e44:	e9 34 fa ff ff       	jmp    c010287d <__alltraps>

c0102e49 <vector154>:
.globl vector154
vector154:
  pushl $0
c0102e49:	6a 00                	push   $0x0
  pushl $154
c0102e4b:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102e50:	e9 28 fa ff ff       	jmp    c010287d <__alltraps>

c0102e55 <vector155>:
.globl vector155
vector155:
  pushl $0
c0102e55:	6a 00                	push   $0x0
  pushl $155
c0102e57:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102e5c:	e9 1c fa ff ff       	jmp    c010287d <__alltraps>

c0102e61 <vector156>:
.globl vector156
vector156:
  pushl $0
c0102e61:	6a 00                	push   $0x0
  pushl $156
c0102e63:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102e68:	e9 10 fa ff ff       	jmp    c010287d <__alltraps>

c0102e6d <vector157>:
.globl vector157
vector157:
  pushl $0
c0102e6d:	6a 00                	push   $0x0
  pushl $157
c0102e6f:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102e74:	e9 04 fa ff ff       	jmp    c010287d <__alltraps>

c0102e79 <vector158>:
.globl vector158
vector158:
  pushl $0
c0102e79:	6a 00                	push   $0x0
  pushl $158
c0102e7b:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102e80:	e9 f8 f9 ff ff       	jmp    c010287d <__alltraps>

c0102e85 <vector159>:
.globl vector159
vector159:
  pushl $0
c0102e85:	6a 00                	push   $0x0
  pushl $159
c0102e87:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102e8c:	e9 ec f9 ff ff       	jmp    c010287d <__alltraps>

c0102e91 <vector160>:
.globl vector160
vector160:
  pushl $0
c0102e91:	6a 00                	push   $0x0
  pushl $160
c0102e93:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102e98:	e9 e0 f9 ff ff       	jmp    c010287d <__alltraps>

c0102e9d <vector161>:
.globl vector161
vector161:
  pushl $0
c0102e9d:	6a 00                	push   $0x0
  pushl $161
c0102e9f:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102ea4:	e9 d4 f9 ff ff       	jmp    c010287d <__alltraps>

c0102ea9 <vector162>:
.globl vector162
vector162:
  pushl $0
c0102ea9:	6a 00                	push   $0x0
  pushl $162
c0102eab:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102eb0:	e9 c8 f9 ff ff       	jmp    c010287d <__alltraps>

c0102eb5 <vector163>:
.globl vector163
vector163:
  pushl $0
c0102eb5:	6a 00                	push   $0x0
  pushl $163
c0102eb7:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102ebc:	e9 bc f9 ff ff       	jmp    c010287d <__alltraps>

c0102ec1 <vector164>:
.globl vector164
vector164:
  pushl $0
c0102ec1:	6a 00                	push   $0x0
  pushl $164
c0102ec3:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102ec8:	e9 b0 f9 ff ff       	jmp    c010287d <__alltraps>

c0102ecd <vector165>:
.globl vector165
vector165:
  pushl $0
c0102ecd:	6a 00                	push   $0x0
  pushl $165
c0102ecf:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102ed4:	e9 a4 f9 ff ff       	jmp    c010287d <__alltraps>

c0102ed9 <vector166>:
.globl vector166
vector166:
  pushl $0
c0102ed9:	6a 00                	push   $0x0
  pushl $166
c0102edb:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0102ee0:	e9 98 f9 ff ff       	jmp    c010287d <__alltraps>

c0102ee5 <vector167>:
.globl vector167
vector167:
  pushl $0
c0102ee5:	6a 00                	push   $0x0
  pushl $167
c0102ee7:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102eec:	e9 8c f9 ff ff       	jmp    c010287d <__alltraps>

c0102ef1 <vector168>:
.globl vector168
vector168:
  pushl $0
c0102ef1:	6a 00                	push   $0x0
  pushl $168
c0102ef3:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102ef8:	e9 80 f9 ff ff       	jmp    c010287d <__alltraps>

c0102efd <vector169>:
.globl vector169
vector169:
  pushl $0
c0102efd:	6a 00                	push   $0x0
  pushl $169
c0102eff:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102f04:	e9 74 f9 ff ff       	jmp    c010287d <__alltraps>

c0102f09 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102f09:	6a 00                	push   $0x0
  pushl $170
c0102f0b:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102f10:	e9 68 f9 ff ff       	jmp    c010287d <__alltraps>

c0102f15 <vector171>:
.globl vector171
vector171:
  pushl $0
c0102f15:	6a 00                	push   $0x0
  pushl $171
c0102f17:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102f1c:	e9 5c f9 ff ff       	jmp    c010287d <__alltraps>

c0102f21 <vector172>:
.globl vector172
vector172:
  pushl $0
c0102f21:	6a 00                	push   $0x0
  pushl $172
c0102f23:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102f28:	e9 50 f9 ff ff       	jmp    c010287d <__alltraps>

c0102f2d <vector173>:
.globl vector173
vector173:
  pushl $0
c0102f2d:	6a 00                	push   $0x0
  pushl $173
c0102f2f:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102f34:	e9 44 f9 ff ff       	jmp    c010287d <__alltraps>

c0102f39 <vector174>:
.globl vector174
vector174:
  pushl $0
c0102f39:	6a 00                	push   $0x0
  pushl $174
c0102f3b:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102f40:	e9 38 f9 ff ff       	jmp    c010287d <__alltraps>

c0102f45 <vector175>:
.globl vector175
vector175:
  pushl $0
c0102f45:	6a 00                	push   $0x0
  pushl $175
c0102f47:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102f4c:	e9 2c f9 ff ff       	jmp    c010287d <__alltraps>

c0102f51 <vector176>:
.globl vector176
vector176:
  pushl $0
c0102f51:	6a 00                	push   $0x0
  pushl $176
c0102f53:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102f58:	e9 20 f9 ff ff       	jmp    c010287d <__alltraps>

c0102f5d <vector177>:
.globl vector177
vector177:
  pushl $0
c0102f5d:	6a 00                	push   $0x0
  pushl $177
c0102f5f:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102f64:	e9 14 f9 ff ff       	jmp    c010287d <__alltraps>

c0102f69 <vector178>:
.globl vector178
vector178:
  pushl $0
c0102f69:	6a 00                	push   $0x0
  pushl $178
c0102f6b:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102f70:	e9 08 f9 ff ff       	jmp    c010287d <__alltraps>

c0102f75 <vector179>:
.globl vector179
vector179:
  pushl $0
c0102f75:	6a 00                	push   $0x0
  pushl $179
c0102f77:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102f7c:	e9 fc f8 ff ff       	jmp    c010287d <__alltraps>

c0102f81 <vector180>:
.globl vector180
vector180:
  pushl $0
c0102f81:	6a 00                	push   $0x0
  pushl $180
c0102f83:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102f88:	e9 f0 f8 ff ff       	jmp    c010287d <__alltraps>

c0102f8d <vector181>:
.globl vector181
vector181:
  pushl $0
c0102f8d:	6a 00                	push   $0x0
  pushl $181
c0102f8f:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0102f94:	e9 e4 f8 ff ff       	jmp    c010287d <__alltraps>

c0102f99 <vector182>:
.globl vector182
vector182:
  pushl $0
c0102f99:	6a 00                	push   $0x0
  pushl $182
c0102f9b:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102fa0:	e9 d8 f8 ff ff       	jmp    c010287d <__alltraps>

c0102fa5 <vector183>:
.globl vector183
vector183:
  pushl $0
c0102fa5:	6a 00                	push   $0x0
  pushl $183
c0102fa7:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0102fac:	e9 cc f8 ff ff       	jmp    c010287d <__alltraps>

c0102fb1 <vector184>:
.globl vector184
vector184:
  pushl $0
c0102fb1:	6a 00                	push   $0x0
  pushl $184
c0102fb3:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0102fb8:	e9 c0 f8 ff ff       	jmp    c010287d <__alltraps>

c0102fbd <vector185>:
.globl vector185
vector185:
  pushl $0
c0102fbd:	6a 00                	push   $0x0
  pushl $185
c0102fbf:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102fc4:	e9 b4 f8 ff ff       	jmp    c010287d <__alltraps>

c0102fc9 <vector186>:
.globl vector186
vector186:
  pushl $0
c0102fc9:	6a 00                	push   $0x0
  pushl $186
c0102fcb:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0102fd0:	e9 a8 f8 ff ff       	jmp    c010287d <__alltraps>

c0102fd5 <vector187>:
.globl vector187
vector187:
  pushl $0
c0102fd5:	6a 00                	push   $0x0
  pushl $187
c0102fd7:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0102fdc:	e9 9c f8 ff ff       	jmp    c010287d <__alltraps>

c0102fe1 <vector188>:
.globl vector188
vector188:
  pushl $0
c0102fe1:	6a 00                	push   $0x0
  pushl $188
c0102fe3:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0102fe8:	e9 90 f8 ff ff       	jmp    c010287d <__alltraps>

c0102fed <vector189>:
.globl vector189
vector189:
  pushl $0
c0102fed:	6a 00                	push   $0x0
  pushl $189
c0102fef:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102ff4:	e9 84 f8 ff ff       	jmp    c010287d <__alltraps>

c0102ff9 <vector190>:
.globl vector190
vector190:
  pushl $0
c0102ff9:	6a 00                	push   $0x0
  pushl $190
c0102ffb:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0103000:	e9 78 f8 ff ff       	jmp    c010287d <__alltraps>

c0103005 <vector191>:
.globl vector191
vector191:
  pushl $0
c0103005:	6a 00                	push   $0x0
  pushl $191
c0103007:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c010300c:	e9 6c f8 ff ff       	jmp    c010287d <__alltraps>

c0103011 <vector192>:
.globl vector192
vector192:
  pushl $0
c0103011:	6a 00                	push   $0x0
  pushl $192
c0103013:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0103018:	e9 60 f8 ff ff       	jmp    c010287d <__alltraps>

c010301d <vector193>:
.globl vector193
vector193:
  pushl $0
c010301d:	6a 00                	push   $0x0
  pushl $193
c010301f:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0103024:	e9 54 f8 ff ff       	jmp    c010287d <__alltraps>

c0103029 <vector194>:
.globl vector194
vector194:
  pushl $0
c0103029:	6a 00                	push   $0x0
  pushl $194
c010302b:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0103030:	e9 48 f8 ff ff       	jmp    c010287d <__alltraps>

c0103035 <vector195>:
.globl vector195
vector195:
  pushl $0
c0103035:	6a 00                	push   $0x0
  pushl $195
c0103037:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c010303c:	e9 3c f8 ff ff       	jmp    c010287d <__alltraps>

c0103041 <vector196>:
.globl vector196
vector196:
  pushl $0
c0103041:	6a 00                	push   $0x0
  pushl $196
c0103043:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0103048:	e9 30 f8 ff ff       	jmp    c010287d <__alltraps>

c010304d <vector197>:
.globl vector197
vector197:
  pushl $0
c010304d:	6a 00                	push   $0x0
  pushl $197
c010304f:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0103054:	e9 24 f8 ff ff       	jmp    c010287d <__alltraps>

c0103059 <vector198>:
.globl vector198
vector198:
  pushl $0
c0103059:	6a 00                	push   $0x0
  pushl $198
c010305b:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0103060:	e9 18 f8 ff ff       	jmp    c010287d <__alltraps>

c0103065 <vector199>:
.globl vector199
vector199:
  pushl $0
c0103065:	6a 00                	push   $0x0
  pushl $199
c0103067:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c010306c:	e9 0c f8 ff ff       	jmp    c010287d <__alltraps>

c0103071 <vector200>:
.globl vector200
vector200:
  pushl $0
c0103071:	6a 00                	push   $0x0
  pushl $200
c0103073:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0103078:	e9 00 f8 ff ff       	jmp    c010287d <__alltraps>

c010307d <vector201>:
.globl vector201
vector201:
  pushl $0
c010307d:	6a 00                	push   $0x0
  pushl $201
c010307f:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0103084:	e9 f4 f7 ff ff       	jmp    c010287d <__alltraps>

c0103089 <vector202>:
.globl vector202
vector202:
  pushl $0
c0103089:	6a 00                	push   $0x0
  pushl $202
c010308b:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0103090:	e9 e8 f7 ff ff       	jmp    c010287d <__alltraps>

c0103095 <vector203>:
.globl vector203
vector203:
  pushl $0
c0103095:	6a 00                	push   $0x0
  pushl $203
c0103097:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c010309c:	e9 dc f7 ff ff       	jmp    c010287d <__alltraps>

c01030a1 <vector204>:
.globl vector204
vector204:
  pushl $0
c01030a1:	6a 00                	push   $0x0
  pushl $204
c01030a3:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c01030a8:	e9 d0 f7 ff ff       	jmp    c010287d <__alltraps>

c01030ad <vector205>:
.globl vector205
vector205:
  pushl $0
c01030ad:	6a 00                	push   $0x0
  pushl $205
c01030af:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c01030b4:	e9 c4 f7 ff ff       	jmp    c010287d <__alltraps>

c01030b9 <vector206>:
.globl vector206
vector206:
  pushl $0
c01030b9:	6a 00                	push   $0x0
  pushl $206
c01030bb:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c01030c0:	e9 b8 f7 ff ff       	jmp    c010287d <__alltraps>

c01030c5 <vector207>:
.globl vector207
vector207:
  pushl $0
c01030c5:	6a 00                	push   $0x0
  pushl $207
c01030c7:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01030cc:	e9 ac f7 ff ff       	jmp    c010287d <__alltraps>

c01030d1 <vector208>:
.globl vector208
vector208:
  pushl $0
c01030d1:	6a 00                	push   $0x0
  pushl $208
c01030d3:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c01030d8:	e9 a0 f7 ff ff       	jmp    c010287d <__alltraps>

c01030dd <vector209>:
.globl vector209
vector209:
  pushl $0
c01030dd:	6a 00                	push   $0x0
  pushl $209
c01030df:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01030e4:	e9 94 f7 ff ff       	jmp    c010287d <__alltraps>

c01030e9 <vector210>:
.globl vector210
vector210:
  pushl $0
c01030e9:	6a 00                	push   $0x0
  pushl $210
c01030eb:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c01030f0:	e9 88 f7 ff ff       	jmp    c010287d <__alltraps>

c01030f5 <vector211>:
.globl vector211
vector211:
  pushl $0
c01030f5:	6a 00                	push   $0x0
  pushl $211
c01030f7:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c01030fc:	e9 7c f7 ff ff       	jmp    c010287d <__alltraps>

c0103101 <vector212>:
.globl vector212
vector212:
  pushl $0
c0103101:	6a 00                	push   $0x0
  pushl $212
c0103103:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0103108:	e9 70 f7 ff ff       	jmp    c010287d <__alltraps>

c010310d <vector213>:
.globl vector213
vector213:
  pushl $0
c010310d:	6a 00                	push   $0x0
  pushl $213
c010310f:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0103114:	e9 64 f7 ff ff       	jmp    c010287d <__alltraps>

c0103119 <vector214>:
.globl vector214
vector214:
  pushl $0
c0103119:	6a 00                	push   $0x0
  pushl $214
c010311b:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0103120:	e9 58 f7 ff ff       	jmp    c010287d <__alltraps>

c0103125 <vector215>:
.globl vector215
vector215:
  pushl $0
c0103125:	6a 00                	push   $0x0
  pushl $215
c0103127:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c010312c:	e9 4c f7 ff ff       	jmp    c010287d <__alltraps>

c0103131 <vector216>:
.globl vector216
vector216:
  pushl $0
c0103131:	6a 00                	push   $0x0
  pushl $216
c0103133:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0103138:	e9 40 f7 ff ff       	jmp    c010287d <__alltraps>

c010313d <vector217>:
.globl vector217
vector217:
  pushl $0
c010313d:	6a 00                	push   $0x0
  pushl $217
c010313f:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0103144:	e9 34 f7 ff ff       	jmp    c010287d <__alltraps>

c0103149 <vector218>:
.globl vector218
vector218:
  pushl $0
c0103149:	6a 00                	push   $0x0
  pushl $218
c010314b:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0103150:	e9 28 f7 ff ff       	jmp    c010287d <__alltraps>

c0103155 <vector219>:
.globl vector219
vector219:
  pushl $0
c0103155:	6a 00                	push   $0x0
  pushl $219
c0103157:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c010315c:	e9 1c f7 ff ff       	jmp    c010287d <__alltraps>

c0103161 <vector220>:
.globl vector220
vector220:
  pushl $0
c0103161:	6a 00                	push   $0x0
  pushl $220
c0103163:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0103168:	e9 10 f7 ff ff       	jmp    c010287d <__alltraps>

c010316d <vector221>:
.globl vector221
vector221:
  pushl $0
c010316d:	6a 00                	push   $0x0
  pushl $221
c010316f:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0103174:	e9 04 f7 ff ff       	jmp    c010287d <__alltraps>

c0103179 <vector222>:
.globl vector222
vector222:
  pushl $0
c0103179:	6a 00                	push   $0x0
  pushl $222
c010317b:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0103180:	e9 f8 f6 ff ff       	jmp    c010287d <__alltraps>

c0103185 <vector223>:
.globl vector223
vector223:
  pushl $0
c0103185:	6a 00                	push   $0x0
  pushl $223
c0103187:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c010318c:	e9 ec f6 ff ff       	jmp    c010287d <__alltraps>

c0103191 <vector224>:
.globl vector224
vector224:
  pushl $0
c0103191:	6a 00                	push   $0x0
  pushl $224
c0103193:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0103198:	e9 e0 f6 ff ff       	jmp    c010287d <__alltraps>

c010319d <vector225>:
.globl vector225
vector225:
  pushl $0
c010319d:	6a 00                	push   $0x0
  pushl $225
c010319f:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c01031a4:	e9 d4 f6 ff ff       	jmp    c010287d <__alltraps>

c01031a9 <vector226>:
.globl vector226
vector226:
  pushl $0
c01031a9:	6a 00                	push   $0x0
  pushl $226
c01031ab:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c01031b0:	e9 c8 f6 ff ff       	jmp    c010287d <__alltraps>

c01031b5 <vector227>:
.globl vector227
vector227:
  pushl $0
c01031b5:	6a 00                	push   $0x0
  pushl $227
c01031b7:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c01031bc:	e9 bc f6 ff ff       	jmp    c010287d <__alltraps>

c01031c1 <vector228>:
.globl vector228
vector228:
  pushl $0
c01031c1:	6a 00                	push   $0x0
  pushl $228
c01031c3:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c01031c8:	e9 b0 f6 ff ff       	jmp    c010287d <__alltraps>

c01031cd <vector229>:
.globl vector229
vector229:
  pushl $0
c01031cd:	6a 00                	push   $0x0
  pushl $229
c01031cf:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01031d4:	e9 a4 f6 ff ff       	jmp    c010287d <__alltraps>

c01031d9 <vector230>:
.globl vector230
vector230:
  pushl $0
c01031d9:	6a 00                	push   $0x0
  pushl $230
c01031db:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01031e0:	e9 98 f6 ff ff       	jmp    c010287d <__alltraps>

c01031e5 <vector231>:
.globl vector231
vector231:
  pushl $0
c01031e5:	6a 00                	push   $0x0
  pushl $231
c01031e7:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01031ec:	e9 8c f6 ff ff       	jmp    c010287d <__alltraps>

c01031f1 <vector232>:
.globl vector232
vector232:
  pushl $0
c01031f1:	6a 00                	push   $0x0
  pushl $232
c01031f3:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c01031f8:	e9 80 f6 ff ff       	jmp    c010287d <__alltraps>

c01031fd <vector233>:
.globl vector233
vector233:
  pushl $0
c01031fd:	6a 00                	push   $0x0
  pushl $233
c01031ff:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0103204:	e9 74 f6 ff ff       	jmp    c010287d <__alltraps>

c0103209 <vector234>:
.globl vector234
vector234:
  pushl $0
c0103209:	6a 00                	push   $0x0
  pushl $234
c010320b:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0103210:	e9 68 f6 ff ff       	jmp    c010287d <__alltraps>

c0103215 <vector235>:
.globl vector235
vector235:
  pushl $0
c0103215:	6a 00                	push   $0x0
  pushl $235
c0103217:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c010321c:	e9 5c f6 ff ff       	jmp    c010287d <__alltraps>

c0103221 <vector236>:
.globl vector236
vector236:
  pushl $0
c0103221:	6a 00                	push   $0x0
  pushl $236
c0103223:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0103228:	e9 50 f6 ff ff       	jmp    c010287d <__alltraps>

c010322d <vector237>:
.globl vector237
vector237:
  pushl $0
c010322d:	6a 00                	push   $0x0
  pushl $237
c010322f:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0103234:	e9 44 f6 ff ff       	jmp    c010287d <__alltraps>

c0103239 <vector238>:
.globl vector238
vector238:
  pushl $0
c0103239:	6a 00                	push   $0x0
  pushl $238
c010323b:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0103240:	e9 38 f6 ff ff       	jmp    c010287d <__alltraps>

c0103245 <vector239>:
.globl vector239
vector239:
  pushl $0
c0103245:	6a 00                	push   $0x0
  pushl $239
c0103247:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c010324c:	e9 2c f6 ff ff       	jmp    c010287d <__alltraps>

c0103251 <vector240>:
.globl vector240
vector240:
  pushl $0
c0103251:	6a 00                	push   $0x0
  pushl $240
c0103253:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0103258:	e9 20 f6 ff ff       	jmp    c010287d <__alltraps>

c010325d <vector241>:
.globl vector241
vector241:
  pushl $0
c010325d:	6a 00                	push   $0x0
  pushl $241
c010325f:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0103264:	e9 14 f6 ff ff       	jmp    c010287d <__alltraps>

c0103269 <vector242>:
.globl vector242
vector242:
  pushl $0
c0103269:	6a 00                	push   $0x0
  pushl $242
c010326b:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0103270:	e9 08 f6 ff ff       	jmp    c010287d <__alltraps>

c0103275 <vector243>:
.globl vector243
vector243:
  pushl $0
c0103275:	6a 00                	push   $0x0
  pushl $243
c0103277:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c010327c:	e9 fc f5 ff ff       	jmp    c010287d <__alltraps>

c0103281 <vector244>:
.globl vector244
vector244:
  pushl $0
c0103281:	6a 00                	push   $0x0
  pushl $244
c0103283:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0103288:	e9 f0 f5 ff ff       	jmp    c010287d <__alltraps>

c010328d <vector245>:
.globl vector245
vector245:
  pushl $0
c010328d:	6a 00                	push   $0x0
  pushl $245
c010328f:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0103294:	e9 e4 f5 ff ff       	jmp    c010287d <__alltraps>

c0103299 <vector246>:
.globl vector246
vector246:
  pushl $0
c0103299:	6a 00                	push   $0x0
  pushl $246
c010329b:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c01032a0:	e9 d8 f5 ff ff       	jmp    c010287d <__alltraps>

c01032a5 <vector247>:
.globl vector247
vector247:
  pushl $0
c01032a5:	6a 00                	push   $0x0
  pushl $247
c01032a7:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c01032ac:	e9 cc f5 ff ff       	jmp    c010287d <__alltraps>

c01032b1 <vector248>:
.globl vector248
vector248:
  pushl $0
c01032b1:	6a 00                	push   $0x0
  pushl $248
c01032b3:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c01032b8:	e9 c0 f5 ff ff       	jmp    c010287d <__alltraps>

c01032bd <vector249>:
.globl vector249
vector249:
  pushl $0
c01032bd:	6a 00                	push   $0x0
  pushl $249
c01032bf:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c01032c4:	e9 b4 f5 ff ff       	jmp    c010287d <__alltraps>

c01032c9 <vector250>:
.globl vector250
vector250:
  pushl $0
c01032c9:	6a 00                	push   $0x0
  pushl $250
c01032cb:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01032d0:	e9 a8 f5 ff ff       	jmp    c010287d <__alltraps>

c01032d5 <vector251>:
.globl vector251
vector251:
  pushl $0
c01032d5:	6a 00                	push   $0x0
  pushl $251
c01032d7:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01032dc:	e9 9c f5 ff ff       	jmp    c010287d <__alltraps>

c01032e1 <vector252>:
.globl vector252
vector252:
  pushl $0
c01032e1:	6a 00                	push   $0x0
  pushl $252
c01032e3:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01032e8:	e9 90 f5 ff ff       	jmp    c010287d <__alltraps>

c01032ed <vector253>:
.globl vector253
vector253:
  pushl $0
c01032ed:	6a 00                	push   $0x0
  pushl $253
c01032ef:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c01032f4:	e9 84 f5 ff ff       	jmp    c010287d <__alltraps>

c01032f9 <vector254>:
.globl vector254
vector254:
  pushl $0
c01032f9:	6a 00                	push   $0x0
  pushl $254
c01032fb:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c0103300:	e9 78 f5 ff ff       	jmp    c010287d <__alltraps>

c0103305 <vector255>:
.globl vector255
vector255:
  pushl $0
c0103305:	6a 00                	push   $0x0
  pushl $255
c0103307:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c010330c:	e9 6c f5 ff ff       	jmp    c010287d <__alltraps>

c0103311 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0103311:	55                   	push   %ebp
c0103312:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0103314:	8b 15 a0 6f 12 c0    	mov    0xc0126fa0,%edx
c010331a:	8b 45 08             	mov    0x8(%ebp),%eax
c010331d:	29 d0                	sub    %edx,%eax
c010331f:	c1 f8 05             	sar    $0x5,%eax
}
c0103322:	5d                   	pop    %ebp
c0103323:	c3                   	ret    

c0103324 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0103324:	55                   	push   %ebp
c0103325:	89 e5                	mov    %esp,%ebp
c0103327:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c010332a:	8b 45 08             	mov    0x8(%ebp),%eax
c010332d:	89 04 24             	mov    %eax,(%esp)
c0103330:	e8 dc ff ff ff       	call   c0103311 <page2ppn>
c0103335:	c1 e0 0c             	shl    $0xc,%eax
}
c0103338:	89 ec                	mov    %ebp,%esp
c010333a:	5d                   	pop    %ebp
c010333b:	c3                   	ret    

c010333c <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c010333c:	55                   	push   %ebp
c010333d:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010333f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103342:	8b 00                	mov    (%eax),%eax
}
c0103344:	5d                   	pop    %ebp
c0103345:	c3                   	ret    

c0103346 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0103346:	55                   	push   %ebp
c0103347:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0103349:	8b 45 08             	mov    0x8(%ebp),%eax
c010334c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010334f:	89 10                	mov    %edx,(%eax)
}
c0103351:	90                   	nop
c0103352:	5d                   	pop    %ebp
c0103353:	c3                   	ret    

c0103354 <default_init>:
//free_list本身不会对应Page结构
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0103354:	55                   	push   %ebp
c0103355:	89 e5                	mov    %esp,%ebp
c0103357:	83 ec 10             	sub    $0x10,%esp
c010335a:	c7 45 fc 84 6f 12 c0 	movl   $0xc0126f84,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103361:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103364:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0103367:	89 50 04             	mov    %edx,0x4(%eax)
c010336a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010336d:	8b 50 04             	mov    0x4(%eax),%edx
c0103370:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103373:	89 10                	mov    %edx,(%eax)
}
c0103375:	90                   	nop
    list_init(&free_list);
    nr_free = 0;
c0103376:	c7 05 8c 6f 12 c0 00 	movl   $0x0,0xc0126f8c
c010337d:	00 00 00 
}
c0103380:	90                   	nop
c0103381:	89 ec                	mov    %ebp,%esp
c0103383:	5d                   	pop    %ebp
c0103384:	c3                   	ret    

c0103385 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0103385:	55                   	push   %ebp
c0103386:	89 e5                	mov    %esp,%ebp
c0103388:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
c010338b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010338f:	75 24                	jne    c01033b5 <default_init_memmap+0x30>
c0103391:	c7 44 24 0c 90 98 10 	movl   $0xc0109890,0xc(%esp)
c0103398:	c0 
c0103399:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c01033a0:	c0 
c01033a1:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
c01033a8:	00 
c01033a9:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c01033b0:	e8 59 d9 ff ff       	call   c0100d0e <__panic>
    struct Page *p = base;
c01033b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01033b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    //相邻的page结构在内存上也是相邻的
    for (; p != base + n; p ++) {
c01033bb:	e9 97 00 00 00       	jmp    c0103457 <default_init_memmap+0xd2>
        //检查是否被保留,是否有问题，
        assert(PageReserved(p));
c01033c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033c3:	83 c0 04             	add    $0x4,%eax
c01033c6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01033cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01033d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01033d3:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01033d6:	0f a3 10             	bt     %edx,(%eax)
c01033d9:	19 c0                	sbb    %eax,%eax
c01033db:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c01033de:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01033e2:	0f 95 c0             	setne  %al
c01033e5:	0f b6 c0             	movzbl %al,%eax
c01033e8:	85 c0                	test   %eax,%eax
c01033ea:	75 24                	jne    c0103410 <default_init_memmap+0x8b>
c01033ec:	c7 44 24 0c c1 98 10 	movl   $0xc01098c1,0xc(%esp)
c01033f3:	c0 
c01033f4:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c01033fb:	c0 
c01033fc:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
c0103403:	00 
c0103404:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c010340b:	e8 fe d8 ff ff       	call   c0100d0e <__panic>
        p->flags = p->property = 0;
c0103410:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103413:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c010341a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010341d:	8b 50 08             	mov    0x8(%eax),%edx
c0103420:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103423:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c0103426:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010342d:	00 
c010342e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103431:	89 04 24             	mov    %eax,(%esp)
c0103434:	e8 0d ff ff ff       	call   c0103346 <set_page_ref>
        //my_add
        SetPageProperty(p);
c0103439:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010343c:	83 c0 04             	add    $0x4,%eax
c010343f:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c0103446:	89 45 e0             	mov    %eax,-0x20(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103449:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010344c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010344f:	0f ab 10             	bts    %edx,(%eax)
}
c0103452:	90                   	nop
    for (; p != base + n; p ++) {
c0103453:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0103457:	8b 45 0c             	mov    0xc(%ebp),%eax
c010345a:	c1 e0 05             	shl    $0x5,%eax
c010345d:	89 c2                	mov    %eax,%edx
c010345f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103462:	01 d0                	add    %edx,%eax
c0103464:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103467:	0f 85 53 ff ff ff    	jne    c01033c0 <default_init_memmap+0x3b>

    }
    base->property = n;
c010346d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103470:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103473:	89 50 08             	mov    %edx,0x8(%eax)
    //置位标志位代表可以分配
   //SetPageProperty(base);
    nr_free += n;
c0103476:	8b 15 8c 6f 12 c0    	mov    0xc0126f8c,%edx
c010347c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010347f:	01 d0                	add    %edx,%eax
c0103481:	a3 8c 6f 12 c0       	mov    %eax,0xc0126f8c
    list_add(&free_list, &(base->page_link));
c0103486:	8b 45 08             	mov    0x8(%ebp),%eax
c0103489:	83 c0 0c             	add    $0xc,%eax
c010348c:	c7 45 dc 84 6f 12 c0 	movl   $0xc0126f84,-0x24(%ebp)
c0103493:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0103496:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103499:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c010349c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010349f:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c01034a2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01034a5:	8b 40 04             	mov    0x4(%eax),%eax
c01034a8:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01034ab:	89 55 cc             	mov    %edx,-0x34(%ebp)
c01034ae:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01034b1:	89 55 c8             	mov    %edx,-0x38(%ebp)
c01034b4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01034b7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01034ba:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01034bd:	89 10                	mov    %edx,(%eax)
c01034bf:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01034c2:	8b 10                	mov    (%eax),%edx
c01034c4:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01034c7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01034ca:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01034cd:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01034d0:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01034d3:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01034d6:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01034d9:	89 10                	mov    %edx,(%eax)
}
c01034db:	90                   	nop
}
c01034dc:	90                   	nop
}
c01034dd:	90                   	nop
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;
    list_add(&free_list, &(base->page_link));*/
}
c01034de:	90                   	nop
c01034df:	89 ec                	mov    %ebp,%esp
c01034e1:	5d                   	pop    %ebp
c01034e2:	c3                   	ret    

c01034e3 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c01034e3:	55                   	push   %ebp
c01034e4:	89 e5                	mov    %esp,%ebp
c01034e6:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c01034e9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01034ed:	75 24                	jne    c0103513 <default_alloc_pages+0x30>
c01034ef:	c7 44 24 0c 90 98 10 	movl   $0xc0109890,0xc(%esp)
c01034f6:	c0 
c01034f7:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c01034fe:	c0 
c01034ff:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
c0103506:	00 
c0103507:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c010350e:	e8 fb d7 ff ff       	call   c0100d0e <__panic>
    if (n > nr_free) {
c0103513:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
c0103518:	39 45 08             	cmp    %eax,0x8(%ebp)
c010351b:	76 0a                	jbe    c0103527 <default_alloc_pages+0x44>
        return NULL;
c010351d:	b8 00 00 00 00       	mov    $0x0,%eax
c0103522:	e9 74 01 00 00       	jmp    c010369b <default_alloc_pages+0x1b8>
    }
    struct Page *page = NULL;
c0103527:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c010352e:	c7 45 f0 84 6f 12 c0 	movl   $0xc0126f84,-0x10(%ebp)

    //遍历free_list
    while ((le = list_next(le)) != &free_list) {
c0103535:	eb 1c                	jmp    c0103553 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c0103537:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010353a:	83 e8 0c             	sub    $0xc,%eax
c010353d:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (p->property >= n) {
c0103540:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103543:	8b 40 08             	mov    0x8(%eax),%eax
c0103546:	39 45 08             	cmp    %eax,0x8(%ebp)
c0103549:	77 08                	ja     c0103553 <default_alloc_pages+0x70>
            page = p;
c010354b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010354e:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c0103551:	eb 18                	jmp    c010356b <default_alloc_pages+0x88>
c0103553:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103556:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c0103559:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010355c:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c010355f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103562:	81 7d f0 84 6f 12 c0 	cmpl   $0xc0126f84,-0x10(%ebp)
c0103569:	75 cc                	jne    c0103537 <default_alloc_pages+0x54>
        }
    }
    if (page != NULL) {
c010356b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010356f:	0f 84 23 01 00 00    	je     c0103698 <default_alloc_pages+0x1b5>
        struct Page *temp=page;
c0103575:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103578:	89 45 ec             	mov    %eax,-0x14(%ebp)
        for(;temp!=page+n;temp++)
c010357b:	eb 1e                	jmp    c010359b <default_alloc_pages+0xb8>
            ClearPageProperty(temp);
c010357d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103580:	83 c0 04             	add    $0x4,%eax
c0103583:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
c010358a:	89 45 d8             	mov    %eax,-0x28(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010358d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103590:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103593:	0f b3 10             	btr    %edx,(%eax)
}
c0103596:	90                   	nop
        for(;temp!=page+n;temp++)
c0103597:	83 45 ec 20          	addl   $0x20,-0x14(%ebp)
c010359b:	8b 45 08             	mov    0x8(%ebp),%eax
c010359e:	c1 e0 05             	shl    $0x5,%eax
c01035a1:	89 c2                	mov    %eax,%edx
c01035a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035a6:	01 d0                	add    %edx,%eax
c01035a8:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c01035ab:	75 d0                	jne    c010357d <default_alloc_pages+0x9a>
        if (page->property > n) {
c01035ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035b0:	8b 40 08             	mov    0x8(%eax),%eax
c01035b3:	39 45 08             	cmp    %eax,0x8(%ebp)
c01035b6:	0f 83 88 00 00 00    	jae    c0103644 <default_alloc_pages+0x161>
            struct Page *p = page + n;
c01035bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01035bf:	c1 e0 05             	shl    $0x5,%eax
c01035c2:	89 c2                	mov    %eax,%edx
c01035c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035c7:	01 d0                	add    %edx,%eax
c01035c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            p->property = page->property - n;
c01035cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035cf:	8b 40 08             	mov    0x8(%eax),%eax
c01035d2:	2b 45 08             	sub    0x8(%ebp),%eax
c01035d5:	89 c2                	mov    %eax,%edx
c01035d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01035da:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
c01035dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01035e0:	83 c0 04             	add    $0x4,%eax
c01035e3:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c01035ea:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01035ed:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01035f0:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01035f3:	0f ab 10             	bts    %edx,(%eax)
}
c01035f6:	90                   	nop
            list_add_after(&(page->page_link), &(p->page_link));
c01035f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01035fa:	83 c0 0c             	add    $0xc,%eax
c01035fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103600:	83 c2 0c             	add    $0xc,%edx
c0103603:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103606:	89 45 d0             	mov    %eax,-0x30(%ebp)
    __list_add(elm, listelm, listelm->next);
c0103609:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010360c:	8b 40 04             	mov    0x4(%eax),%eax
c010360f:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103612:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0103615:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103618:	89 55 c8             	mov    %edx,-0x38(%ebp)
c010361b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    prev->next = next->prev = elm;
c010361e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103621:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103624:	89 10                	mov    %edx,(%eax)
c0103626:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103629:	8b 10                	mov    (%eax),%edx
c010362b:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010362e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103631:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103634:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0103637:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010363a:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010363d:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0103640:	89 10                	mov    %edx,(%eax)
}
c0103642:	90                   	nop
}
c0103643:	90                   	nop
        }
        list_del(&(page->page_link));
c0103644:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103647:	83 c0 0c             	add    $0xc,%eax
c010364a:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
c010364d:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103650:	8b 40 04             	mov    0x4(%eax),%eax
c0103653:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0103656:	8b 12                	mov    (%edx),%edx
c0103658:	89 55 ac             	mov    %edx,-0x54(%ebp)
c010365b:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c010365e:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0103661:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0103664:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103667:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010366a:	8b 55 ac             	mov    -0x54(%ebp),%edx
c010366d:	89 10                	mov    %edx,(%eax)
}
c010366f:	90                   	nop
}
c0103670:	90                   	nop
        nr_free -= n;
c0103671:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
c0103676:	2b 45 08             	sub    0x8(%ebp),%eax
c0103679:	a3 8c 6f 12 c0       	mov    %eax,0xc0126f8c
        ClearPageProperty(page);
c010367e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103681:	83 c0 04             	add    $0x4,%eax
c0103684:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c010368b:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010368e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103691:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0103694:	0f b3 10             	btr    %edx,(%eax)
}
c0103697:	90                   	nop
    }
    return page;
c0103698:	8b 45 f4             	mov    -0xc(%ebp),%eax
        list_del(&(page->page_link));
        nr_free -= n;
        ClearPageProperty(page);
    }
    return page;*/
}
c010369b:	89 ec                	mov    %ebp,%esp
c010369d:	5d                   	pop    %ebp
c010369e:	c3                   	ret    

c010369f <merge_backward>:

static bool merge_backward(struct  Page*base)
{
c010369f:	55                   	push   %ebp
c01036a0:	89 e5                	mov    %esp,%ebp
c01036a2:	83 ec 30             	sub    $0x30,%esp
    list_entry_t *le=list_next(&(base->page_link));
c01036a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01036a8:	83 c0 0c             	add    $0xc,%eax
c01036ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return listelm->next;
c01036ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036b1:	8b 40 04             	mov    0x4(%eax),%eax
c01036b4:	89 45 fc             	mov    %eax,-0x4(%ebp)
    //判断是否为头节点
    if (le==&free_list)
c01036b7:	81 7d fc 84 6f 12 c0 	cmpl   $0xc0126f84,-0x4(%ebp)
c01036be:	75 0a                	jne    c01036ca <merge_backward+0x2b>
    return 0;
c01036c0:	b8 00 00 00 00       	mov    $0x0,%eax
c01036c5:	e9 a5 00 00 00       	jmp    c010376f <merge_backward+0xd0>
    struct Page*p=le2page(le,page_link);
c01036ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01036cd:	83 e8 0c             	sub    $0xc,%eax
c01036d0:	89 45 f8             	mov    %eax,-0x8(%ebp)
    
    //判断是否为空闲块
    if(PageProperty(p)==0) return 0;
c01036d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01036d6:	83 c0 04             	add    $0x4,%eax
c01036d9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c01036e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01036e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01036e6:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01036e9:	0f a3 10             	bt     %edx,(%eax)
c01036ec:	19 c0                	sbb    %eax,%eax
c01036ee:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c01036f1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01036f5:	0f 95 c0             	setne  %al
c01036f8:	0f b6 c0             	movzbl %al,%eax
c01036fb:	85 c0                	test   %eax,%eax
c01036fd:	75 07                	jne    c0103706 <merge_backward+0x67>
c01036ff:	b8 00 00 00 00       	mov    $0x0,%eax
c0103704:	eb 69                	jmp    c010376f <merge_backward+0xd0>
    //判断地址是否连续
    if(base+base->property==p)
c0103706:	8b 45 08             	mov    0x8(%ebp),%eax
c0103709:	8b 40 08             	mov    0x8(%eax),%eax
c010370c:	c1 e0 05             	shl    $0x5,%eax
c010370f:	89 c2                	mov    %eax,%edx
c0103711:	8b 45 08             	mov    0x8(%ebp),%eax
c0103714:	01 d0                	add    %edx,%eax
c0103716:	39 45 f8             	cmp    %eax,-0x8(%ebp)
c0103719:	75 4f                	jne    c010376a <merge_backward+0xcb>
    {
        base->property+=p->property;
c010371b:	8b 45 08             	mov    0x8(%ebp),%eax
c010371e:	8b 50 08             	mov    0x8(%eax),%edx
c0103721:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0103724:	8b 40 08             	mov    0x8(%eax),%eax
c0103727:	01 c2                	add    %eax,%edx
c0103729:	8b 45 08             	mov    0x8(%ebp),%eax
c010372c:	89 50 08             	mov    %edx,0x8(%eax)
        p->property=0;
c010372f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0103732:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0103739:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010373c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    __list_del(listelm->prev, listelm->next);
c010373f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103742:	8b 40 04             	mov    0x4(%eax),%eax
c0103745:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103748:	8b 12                	mov    (%edx),%edx
c010374a:	89 55 e0             	mov    %edx,-0x20(%ebp)
c010374d:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next;
c0103750:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103753:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103756:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103759:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010375c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010375f:	89 10                	mov    %edx,(%eax)
}
c0103761:	90                   	nop
}
c0103762:	90                   	nop
        list_del(le);
        return 1;
c0103763:	b8 01 00 00 00       	mov    $0x1,%eax
c0103768:	eb 05                	jmp    c010376f <merge_backward+0xd0>
        
    }
    else
    {
        return 0;
c010376a:	b8 00 00 00 00       	mov    $0x0,%eax
    }

}
c010376f:	89 ec                	mov    %ebp,%esp
c0103771:	5d                   	pop    %ebp
c0103772:	c3                   	ret    

c0103773 <merge_beforeward>:
static bool merge_beforeward(struct Page*base)
{
c0103773:	55                   	push   %ebp
c0103774:	89 e5                	mov    %esp,%ebp
c0103776:	83 ec 30             	sub    $0x30,%esp
    list_entry_t *le=list_prev(&(base->page_link));
c0103779:	8b 45 08             	mov    0x8(%ebp),%eax
c010377c:	83 c0 0c             	add    $0xc,%eax
c010377f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return listelm->prev;
c0103782:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103785:	8b 00                	mov    (%eax),%eax
c0103787:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (le==&free_list)
c010378a:	81 7d fc 84 6f 12 c0 	cmpl   $0xc0126f84,-0x4(%ebp)
c0103791:	75 0a                	jne    c010379d <merge_beforeward+0x2a>
    return 0;
c0103793:	b8 00 00 00 00       	mov    $0x0,%eax
c0103798:	e9 ae 00 00 00       	jmp    c010384b <merge_beforeward+0xd8>
    struct Page*p=le2page(le,page_link);
c010379d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01037a0:	83 e8 0c             	sub    $0xc,%eax
c01037a3:	89 45 f8             	mov    %eax,-0x8(%ebp)

    //判断是否为空闲块
    if(PageProperty(p)==0) return 0;
c01037a6:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01037a9:	83 c0 04             	add    $0x4,%eax
c01037ac:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c01037b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01037b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01037b9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01037bc:	0f a3 10             	bt     %edx,(%eax)
c01037bf:	19 c0                	sbb    %eax,%eax
c01037c1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c01037c4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01037c8:	0f 95 c0             	setne  %al
c01037cb:	0f b6 c0             	movzbl %al,%eax
c01037ce:	85 c0                	test   %eax,%eax
c01037d0:	75 07                	jne    c01037d9 <merge_beforeward+0x66>
c01037d2:	b8 00 00 00 00       	mov    $0x0,%eax
c01037d7:	eb 72                	jmp    c010384b <merge_beforeward+0xd8>
    //判断地址是否连续
    if(p+p->property==base)
c01037d9:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01037dc:	8b 40 08             	mov    0x8(%eax),%eax
c01037df:	c1 e0 05             	shl    $0x5,%eax
c01037e2:	89 c2                	mov    %eax,%edx
c01037e4:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01037e7:	01 d0                	add    %edx,%eax
c01037e9:	39 45 08             	cmp    %eax,0x8(%ebp)
c01037ec:	75 58                	jne    c0103846 <merge_beforeward+0xd3>
    {
        p->property+=base->property;
c01037ee:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01037f1:	8b 50 08             	mov    0x8(%eax),%edx
c01037f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01037f7:	8b 40 08             	mov    0x8(%eax),%eax
c01037fa:	01 c2                	add    %eax,%edx
c01037fc:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01037ff:	89 50 08             	mov    %edx,0x8(%eax)
        base->property=0;
c0103802:	8b 45 08             	mov    0x8(%ebp),%eax
c0103805:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        list_del(&(base->page_link));
c010380c:	8b 45 08             	mov    0x8(%ebp),%eax
c010380f:	83 c0 0c             	add    $0xc,%eax
c0103812:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    __list_del(listelm->prev, listelm->next);
c0103815:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103818:	8b 40 04             	mov    0x4(%eax),%eax
c010381b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010381e:	8b 12                	mov    (%edx),%edx
c0103820:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0103823:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next;
c0103826:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103829:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010382c:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010382f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103832:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103835:	89 10                	mov    %edx,(%eax)
}
c0103837:	90                   	nop
}
c0103838:	90                   	nop
        base=p;
c0103839:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010383c:	89 45 08             	mov    %eax,0x8(%ebp)
        return 1;   
c010383f:	b8 01 00 00 00       	mov    $0x1,%eax
c0103844:	eb 05                	jmp    c010384b <merge_beforeward+0xd8>
    }
    else
    {
        return 0;
c0103846:	b8 00 00 00 00       	mov    $0x0,%eax
    }
    

}
c010384b:	89 ec                	mov    %ebp,%esp
c010384d:	5d                   	pop    %ebp
c010384e:	c3                   	ret    

c010384f <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c010384f:	55                   	push   %ebp
c0103850:	89 e5                	mov    %esp,%ebp
c0103852:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0103855:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0103859:	75 24                	jne    c010387f <default_free_pages+0x30>
c010385b:	c7 44 24 0c 90 98 10 	movl   $0xc0109890,0xc(%esp)
c0103862:	c0 
c0103863:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c010386a:	c0 
c010386b:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c0103872:	00 
c0103873:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c010387a:	e8 8f d4 ff ff       	call   c0100d0e <__panic>
    struct Page *p = base;
c010387f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103882:	89 45 f4             	mov    %eax,-0xc(%ebp)

    for (; p != base + n; p ++) {
c0103885:	e9 ad 00 00 00       	jmp    c0103937 <default_free_pages+0xe8>
        
        //需要满足不是给内核的且不是空闲的
        assert(!PageReserved(p) && !PageProperty(p));
c010388a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010388d:	83 c0 04             	add    $0x4,%eax
c0103890:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0103897:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010389a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010389d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01038a0:	0f a3 10             	bt     %edx,(%eax)
c01038a3:	19 c0                	sbb    %eax,%eax
c01038a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c01038a8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01038ac:	0f 95 c0             	setne  %al
c01038af:	0f b6 c0             	movzbl %al,%eax
c01038b2:	85 c0                	test   %eax,%eax
c01038b4:	75 2c                	jne    c01038e2 <default_free_pages+0x93>
c01038b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038b9:	83 c0 04             	add    $0x4,%eax
c01038bc:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01038c3:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01038c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01038c9:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01038cc:	0f a3 10             	bt     %edx,(%eax)
c01038cf:	19 c0                	sbb    %eax,%eax
c01038d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c01038d4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01038d8:	0f 95 c0             	setne  %al
c01038db:	0f b6 c0             	movzbl %al,%eax
c01038de:	85 c0                	test   %eax,%eax
c01038e0:	74 24                	je     c0103906 <default_free_pages+0xb7>
c01038e2:	c7 44 24 0c d4 98 10 	movl   $0xc01098d4,0xc(%esp)
c01038e9:	c0 
c01038ea:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c01038f1:	c0 
c01038f2:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
c01038f9:	00 
c01038fa:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c0103901:	e8 08 d4 ff ff       	call   c0100d0e <__panic>
        //p->flags = 0;
        SetPageProperty(p);
c0103906:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103909:	83 c0 04             	add    $0x4,%eax
c010390c:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0103913:	89 45 d0             	mov    %eax,-0x30(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103916:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103919:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010391c:	0f ab 10             	bts    %edx,(%eax)
}
c010391f:	90                   	nop
        set_page_ref(p, 0);
c0103920:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103927:	00 
c0103928:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010392b:	89 04 24             	mov    %eax,(%esp)
c010392e:	e8 13 fa ff ff       	call   c0103346 <set_page_ref>
    for (; p != base + n; p ++) {
c0103933:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0103937:	8b 45 0c             	mov    0xc(%ebp),%eax
c010393a:	c1 e0 05             	shl    $0x5,%eax
c010393d:	89 c2                	mov    %eax,%edx
c010393f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103942:	01 d0                	add    %edx,%eax
c0103944:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103947:	0f 85 3d ff ff ff    	jne    c010388a <default_free_pages+0x3b>
    }

    base->property = n;
c010394d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103950:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103953:	89 50 08             	mov    %edx,0x8(%eax)
c0103956:	c7 45 cc 84 6f 12 c0 	movl   $0xc0126f84,-0x34(%ebp)
    return listelm->next;
c010395d:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103960:	8b 40 04             	mov    0x4(%eax),%eax
    //SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
c0103963:	89 45 f0             	mov    %eax,-0x10(%ebp)
    
    for(;le!=&free_list && le<&(base->page_link);le=list_next(le));
c0103966:	eb 0f                	jmp    c0103977 <default_free_pages+0x128>
c0103968:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010396b:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010396e:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103971:	8b 40 04             	mov    0x4(%eax),%eax
c0103974:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103977:	81 7d f0 84 6f 12 c0 	cmpl   $0xc0126f84,-0x10(%ebp)
c010397e:	74 0b                	je     c010398b <default_free_pages+0x13c>
c0103980:	8b 45 08             	mov    0x8(%ebp),%eax
c0103983:	83 c0 0c             	add    $0xc,%eax
c0103986:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0103989:	72 dd                	jb     c0103968 <default_free_pages+0x119>

     nr_free += n;
c010398b:	8b 15 8c 6f 12 c0    	mov    0xc0126f8c,%edx
c0103991:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103994:	01 d0                	add    %edx,%eax
c0103996:	a3 8c 6f 12 c0       	mov    %eax,0xc0126f8c
    list_add_before(le,&base->page_link);
c010399b:	8b 45 08             	mov    0x8(%ebp),%eax
c010399e:	8d 50 0c             	lea    0xc(%eax),%edx
c01039a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01039a4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c01039a7:	89 55 c0             	mov    %edx,-0x40(%ebp)
    __list_add(elm, listelm->prev, listelm);
c01039aa:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01039ad:	8b 00                	mov    (%eax),%eax
c01039af:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01039b2:	89 55 bc             	mov    %edx,-0x44(%ebp)
c01039b5:	89 45 b8             	mov    %eax,-0x48(%ebp)
c01039b8:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01039bb:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    prev->next = next->prev = elm;
c01039be:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01039c1:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01039c4:	89 10                	mov    %edx,(%eax)
c01039c6:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01039c9:	8b 10                	mov    (%eax),%edx
c01039cb:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01039ce:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01039d1:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01039d4:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01039d7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01039da:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01039dd:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01039e0:	89 10                	mov    %edx,(%eax)
}
c01039e2:	90                   	nop
}
c01039e3:	90                   	nop
    while(merge_backward(base));
c01039e4:	90                   	nop
c01039e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01039e8:	89 04 24             	mov    %eax,(%esp)
c01039eb:	e8 af fc ff ff       	call   c010369f <merge_backward>
c01039f0:	85 c0                	test   %eax,%eax
c01039f2:	75 f1                	jne    c01039e5 <default_free_pages+0x196>
    while(merge_beforeward(base));
c01039f4:	90                   	nop
c01039f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01039f8:	89 04 24             	mov    %eax,(%esp)
c01039fb:	e8 73 fd ff ff       	call   c0103773 <merge_beforeward>
c0103a00:	85 c0                	test   %eax,%eax
c0103a02:	75 f1                	jne    c01039f5 <default_free_pages+0x1a6>
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));*/


}
c0103a04:	90                   	nop
c0103a05:	90                   	nop
c0103a06:	89 ec                	mov    %ebp,%esp
c0103a08:	5d                   	pop    %ebp
c0103a09:	c3                   	ret    

c0103a0a <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0103a0a:	55                   	push   %ebp
c0103a0b:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0103a0d:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
}
c0103a12:	5d                   	pop    %ebp
c0103a13:	c3                   	ret    

c0103a14 <basic_check>:

static void
basic_check(void) {
c0103a14:	55                   	push   %ebp
c0103a15:	89 e5                	mov    %esp,%ebp
c0103a17:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0103a1a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103a21:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a24:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a27:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a2a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0103a2d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103a34:	e8 2a 0f 00 00       	call   c0104963 <alloc_pages>
c0103a39:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103a3c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103a40:	75 24                	jne    c0103a66 <basic_check+0x52>
c0103a42:	c7 44 24 0c f9 98 10 	movl   $0xc01098f9,0xc(%esp)
c0103a49:	c0 
c0103a4a:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c0103a51:	c0 
c0103a52:	c7 44 24 04 49 01 00 	movl   $0x149,0x4(%esp)
c0103a59:	00 
c0103a5a:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c0103a61:	e8 a8 d2 ff ff       	call   c0100d0e <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103a66:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103a6d:	e8 f1 0e 00 00       	call   c0104963 <alloc_pages>
c0103a72:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a75:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103a79:	75 24                	jne    c0103a9f <basic_check+0x8b>
c0103a7b:	c7 44 24 0c 15 99 10 	movl   $0xc0109915,0xc(%esp)
c0103a82:	c0 
c0103a83:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c0103a8a:	c0 
c0103a8b:	c7 44 24 04 4a 01 00 	movl   $0x14a,0x4(%esp)
c0103a92:	00 
c0103a93:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c0103a9a:	e8 6f d2 ff ff       	call   c0100d0e <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103a9f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103aa6:	e8 b8 0e 00 00       	call   c0104963 <alloc_pages>
c0103aab:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103aae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103ab2:	75 24                	jne    c0103ad8 <basic_check+0xc4>
c0103ab4:	c7 44 24 0c 31 99 10 	movl   $0xc0109931,0xc(%esp)
c0103abb:	c0 
c0103abc:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c0103ac3:	c0 
c0103ac4:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
c0103acb:	00 
c0103acc:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c0103ad3:	e8 36 d2 ff ff       	call   c0100d0e <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0103ad8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103adb:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103ade:	74 10                	je     c0103af0 <basic_check+0xdc>
c0103ae0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103ae3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103ae6:	74 08                	je     c0103af0 <basic_check+0xdc>
c0103ae8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103aeb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103aee:	75 24                	jne    c0103b14 <basic_check+0x100>
c0103af0:	c7 44 24 0c 50 99 10 	movl   $0xc0109950,0xc(%esp)
c0103af7:	c0 
c0103af8:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c0103aff:	c0 
c0103b00:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
c0103b07:	00 
c0103b08:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c0103b0f:	e8 fa d1 ff ff       	call   c0100d0e <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0103b14:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b17:	89 04 24             	mov    %eax,(%esp)
c0103b1a:	e8 1d f8 ff ff       	call   c010333c <page_ref>
c0103b1f:	85 c0                	test   %eax,%eax
c0103b21:	75 1e                	jne    c0103b41 <basic_check+0x12d>
c0103b23:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b26:	89 04 24             	mov    %eax,(%esp)
c0103b29:	e8 0e f8 ff ff       	call   c010333c <page_ref>
c0103b2e:	85 c0                	test   %eax,%eax
c0103b30:	75 0f                	jne    c0103b41 <basic_check+0x12d>
c0103b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b35:	89 04 24             	mov    %eax,(%esp)
c0103b38:	e8 ff f7 ff ff       	call   c010333c <page_ref>
c0103b3d:	85 c0                	test   %eax,%eax
c0103b3f:	74 24                	je     c0103b65 <basic_check+0x151>
c0103b41:	c7 44 24 0c 74 99 10 	movl   $0xc0109974,0xc(%esp)
c0103b48:	c0 
c0103b49:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c0103b50:	c0 
c0103b51:	c7 44 24 04 4e 01 00 	movl   $0x14e,0x4(%esp)
c0103b58:	00 
c0103b59:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c0103b60:	e8 a9 d1 ff ff       	call   c0100d0e <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0103b65:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b68:	89 04 24             	mov    %eax,(%esp)
c0103b6b:	e8 b4 f7 ff ff       	call   c0103324 <page2pa>
c0103b70:	8b 15 a4 6f 12 c0    	mov    0xc0126fa4,%edx
c0103b76:	c1 e2 0c             	shl    $0xc,%edx
c0103b79:	39 d0                	cmp    %edx,%eax
c0103b7b:	72 24                	jb     c0103ba1 <basic_check+0x18d>
c0103b7d:	c7 44 24 0c b0 99 10 	movl   $0xc01099b0,0xc(%esp)
c0103b84:	c0 
c0103b85:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c0103b8c:	c0 
c0103b8d:	c7 44 24 04 50 01 00 	movl   $0x150,0x4(%esp)
c0103b94:	00 
c0103b95:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c0103b9c:	e8 6d d1 ff ff       	call   c0100d0e <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0103ba1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103ba4:	89 04 24             	mov    %eax,(%esp)
c0103ba7:	e8 78 f7 ff ff       	call   c0103324 <page2pa>
c0103bac:	8b 15 a4 6f 12 c0    	mov    0xc0126fa4,%edx
c0103bb2:	c1 e2 0c             	shl    $0xc,%edx
c0103bb5:	39 d0                	cmp    %edx,%eax
c0103bb7:	72 24                	jb     c0103bdd <basic_check+0x1c9>
c0103bb9:	c7 44 24 0c cd 99 10 	movl   $0xc01099cd,0xc(%esp)
c0103bc0:	c0 
c0103bc1:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c0103bc8:	c0 
c0103bc9:	c7 44 24 04 51 01 00 	movl   $0x151,0x4(%esp)
c0103bd0:	00 
c0103bd1:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c0103bd8:	e8 31 d1 ff ff       	call   c0100d0e <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0103bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103be0:	89 04 24             	mov    %eax,(%esp)
c0103be3:	e8 3c f7 ff ff       	call   c0103324 <page2pa>
c0103be8:	8b 15 a4 6f 12 c0    	mov    0xc0126fa4,%edx
c0103bee:	c1 e2 0c             	shl    $0xc,%edx
c0103bf1:	39 d0                	cmp    %edx,%eax
c0103bf3:	72 24                	jb     c0103c19 <basic_check+0x205>
c0103bf5:	c7 44 24 0c ea 99 10 	movl   $0xc01099ea,0xc(%esp)
c0103bfc:	c0 
c0103bfd:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c0103c04:	c0 
c0103c05:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
c0103c0c:	00 
c0103c0d:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c0103c14:	e8 f5 d0 ff ff       	call   c0100d0e <__panic>

    list_entry_t free_list_store = free_list;
c0103c19:	a1 84 6f 12 c0       	mov    0xc0126f84,%eax
c0103c1e:	8b 15 88 6f 12 c0    	mov    0xc0126f88,%edx
c0103c24:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103c27:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103c2a:	c7 45 dc 84 6f 12 c0 	movl   $0xc0126f84,-0x24(%ebp)
    elm->prev = elm->next = elm;
c0103c31:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103c34:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103c37:	89 50 04             	mov    %edx,0x4(%eax)
c0103c3a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103c3d:	8b 50 04             	mov    0x4(%eax),%edx
c0103c40:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103c43:	89 10                	mov    %edx,(%eax)
}
c0103c45:	90                   	nop
c0103c46:	c7 45 e0 84 6f 12 c0 	movl   $0xc0126f84,-0x20(%ebp)
    return list->next == list;
c0103c4d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103c50:	8b 40 04             	mov    0x4(%eax),%eax
c0103c53:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0103c56:	0f 94 c0             	sete   %al
c0103c59:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103c5c:	85 c0                	test   %eax,%eax
c0103c5e:	75 24                	jne    c0103c84 <basic_check+0x270>
c0103c60:	c7 44 24 0c 07 9a 10 	movl   $0xc0109a07,0xc(%esp)
c0103c67:	c0 
c0103c68:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c0103c6f:	c0 
c0103c70:	c7 44 24 04 56 01 00 	movl   $0x156,0x4(%esp)
c0103c77:	00 
c0103c78:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c0103c7f:	e8 8a d0 ff ff       	call   c0100d0e <__panic>

    unsigned int nr_free_store = nr_free;
c0103c84:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
c0103c89:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0103c8c:	c7 05 8c 6f 12 c0 00 	movl   $0x0,0xc0126f8c
c0103c93:	00 00 00 

    assert(alloc_page() == NULL);
c0103c96:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103c9d:	e8 c1 0c 00 00       	call   c0104963 <alloc_pages>
c0103ca2:	85 c0                	test   %eax,%eax
c0103ca4:	74 24                	je     c0103cca <basic_check+0x2b6>
c0103ca6:	c7 44 24 0c 1e 9a 10 	movl   $0xc0109a1e,0xc(%esp)
c0103cad:	c0 
c0103cae:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c0103cb5:	c0 
c0103cb6:	c7 44 24 04 5b 01 00 	movl   $0x15b,0x4(%esp)
c0103cbd:	00 
c0103cbe:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c0103cc5:	e8 44 d0 ff ff       	call   c0100d0e <__panic>

    free_page(p0);
c0103cca:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103cd1:	00 
c0103cd2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103cd5:	89 04 24             	mov    %eax,(%esp)
c0103cd8:	e8 f3 0c 00 00       	call   c01049d0 <free_pages>
    free_page(p1);
c0103cdd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103ce4:	00 
c0103ce5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103ce8:	89 04 24             	mov    %eax,(%esp)
c0103ceb:	e8 e0 0c 00 00       	call   c01049d0 <free_pages>
    free_page(p2);
c0103cf0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103cf7:	00 
c0103cf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103cfb:	89 04 24             	mov    %eax,(%esp)
c0103cfe:	e8 cd 0c 00 00       	call   c01049d0 <free_pages>
    assert(nr_free == 3);
c0103d03:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
c0103d08:	83 f8 03             	cmp    $0x3,%eax
c0103d0b:	74 24                	je     c0103d31 <basic_check+0x31d>
c0103d0d:	c7 44 24 0c 33 9a 10 	movl   $0xc0109a33,0xc(%esp)
c0103d14:	c0 
c0103d15:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c0103d1c:	c0 
c0103d1d:	c7 44 24 04 60 01 00 	movl   $0x160,0x4(%esp)
c0103d24:	00 
c0103d25:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c0103d2c:	e8 dd cf ff ff       	call   c0100d0e <__panic>

    assert((p0 = alloc_page()) != NULL);
c0103d31:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103d38:	e8 26 0c 00 00       	call   c0104963 <alloc_pages>
c0103d3d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103d40:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103d44:	75 24                	jne    c0103d6a <basic_check+0x356>
c0103d46:	c7 44 24 0c f9 98 10 	movl   $0xc01098f9,0xc(%esp)
c0103d4d:	c0 
c0103d4e:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c0103d55:	c0 
c0103d56:	c7 44 24 04 62 01 00 	movl   $0x162,0x4(%esp)
c0103d5d:	00 
c0103d5e:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c0103d65:	e8 a4 cf ff ff       	call   c0100d0e <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103d6a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103d71:	e8 ed 0b 00 00       	call   c0104963 <alloc_pages>
c0103d76:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103d79:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103d7d:	75 24                	jne    c0103da3 <basic_check+0x38f>
c0103d7f:	c7 44 24 0c 15 99 10 	movl   $0xc0109915,0xc(%esp)
c0103d86:	c0 
c0103d87:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c0103d8e:	c0 
c0103d8f:	c7 44 24 04 63 01 00 	movl   $0x163,0x4(%esp)
c0103d96:	00 
c0103d97:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c0103d9e:	e8 6b cf ff ff       	call   c0100d0e <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103da3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103daa:	e8 b4 0b 00 00       	call   c0104963 <alloc_pages>
c0103daf:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103db2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103db6:	75 24                	jne    c0103ddc <basic_check+0x3c8>
c0103db8:	c7 44 24 0c 31 99 10 	movl   $0xc0109931,0xc(%esp)
c0103dbf:	c0 
c0103dc0:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c0103dc7:	c0 
c0103dc8:	c7 44 24 04 64 01 00 	movl   $0x164,0x4(%esp)
c0103dcf:	00 
c0103dd0:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c0103dd7:	e8 32 cf ff ff       	call   c0100d0e <__panic>

    assert(alloc_page() == NULL);
c0103ddc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103de3:	e8 7b 0b 00 00       	call   c0104963 <alloc_pages>
c0103de8:	85 c0                	test   %eax,%eax
c0103dea:	74 24                	je     c0103e10 <basic_check+0x3fc>
c0103dec:	c7 44 24 0c 1e 9a 10 	movl   $0xc0109a1e,0xc(%esp)
c0103df3:	c0 
c0103df4:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c0103dfb:	c0 
c0103dfc:	c7 44 24 04 66 01 00 	movl   $0x166,0x4(%esp)
c0103e03:	00 
c0103e04:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c0103e0b:	e8 fe ce ff ff       	call   c0100d0e <__panic>

    free_page(p0);
c0103e10:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103e17:	00 
c0103e18:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103e1b:	89 04 24             	mov    %eax,(%esp)
c0103e1e:	e8 ad 0b 00 00       	call   c01049d0 <free_pages>
c0103e23:	c7 45 d8 84 6f 12 c0 	movl   $0xc0126f84,-0x28(%ebp)
c0103e2a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103e2d:	8b 40 04             	mov    0x4(%eax),%eax
c0103e30:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0103e33:	0f 94 c0             	sete   %al
c0103e36:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0103e39:	85 c0                	test   %eax,%eax
c0103e3b:	74 24                	je     c0103e61 <basic_check+0x44d>
c0103e3d:	c7 44 24 0c 40 9a 10 	movl   $0xc0109a40,0xc(%esp)
c0103e44:	c0 
c0103e45:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c0103e4c:	c0 
c0103e4d:	c7 44 24 04 69 01 00 	movl   $0x169,0x4(%esp)
c0103e54:	00 
c0103e55:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c0103e5c:	e8 ad ce ff ff       	call   c0100d0e <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0103e61:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103e68:	e8 f6 0a 00 00       	call   c0104963 <alloc_pages>
c0103e6d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103e70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103e73:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103e76:	74 24                	je     c0103e9c <basic_check+0x488>
c0103e78:	c7 44 24 0c 58 9a 10 	movl   $0xc0109a58,0xc(%esp)
c0103e7f:	c0 
c0103e80:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c0103e87:	c0 
c0103e88:	c7 44 24 04 6c 01 00 	movl   $0x16c,0x4(%esp)
c0103e8f:	00 
c0103e90:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c0103e97:	e8 72 ce ff ff       	call   c0100d0e <__panic>
    assert(alloc_page() == NULL);
c0103e9c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103ea3:	e8 bb 0a 00 00       	call   c0104963 <alloc_pages>
c0103ea8:	85 c0                	test   %eax,%eax
c0103eaa:	74 24                	je     c0103ed0 <basic_check+0x4bc>
c0103eac:	c7 44 24 0c 1e 9a 10 	movl   $0xc0109a1e,0xc(%esp)
c0103eb3:	c0 
c0103eb4:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c0103ebb:	c0 
c0103ebc:	c7 44 24 04 6d 01 00 	movl   $0x16d,0x4(%esp)
c0103ec3:	00 
c0103ec4:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c0103ecb:	e8 3e ce ff ff       	call   c0100d0e <__panic>

    assert(nr_free == 0);
c0103ed0:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
c0103ed5:	85 c0                	test   %eax,%eax
c0103ed7:	74 24                	je     c0103efd <basic_check+0x4e9>
c0103ed9:	c7 44 24 0c 71 9a 10 	movl   $0xc0109a71,0xc(%esp)
c0103ee0:	c0 
c0103ee1:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c0103ee8:	c0 
c0103ee9:	c7 44 24 04 6f 01 00 	movl   $0x16f,0x4(%esp)
c0103ef0:	00 
c0103ef1:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c0103ef8:	e8 11 ce ff ff       	call   c0100d0e <__panic>
    free_list = free_list_store;
c0103efd:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103f00:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103f03:	a3 84 6f 12 c0       	mov    %eax,0xc0126f84
c0103f08:	89 15 88 6f 12 c0    	mov    %edx,0xc0126f88
    nr_free = nr_free_store;
c0103f0e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103f11:	a3 8c 6f 12 c0       	mov    %eax,0xc0126f8c

    free_page(p);
c0103f16:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f1d:	00 
c0103f1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103f21:	89 04 24             	mov    %eax,(%esp)
c0103f24:	e8 a7 0a 00 00       	call   c01049d0 <free_pages>
    free_page(p1);
c0103f29:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f30:	00 
c0103f31:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f34:	89 04 24             	mov    %eax,(%esp)
c0103f37:	e8 94 0a 00 00       	call   c01049d0 <free_pages>
    free_page(p2);
c0103f3c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f43:	00 
c0103f44:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f47:	89 04 24             	mov    %eax,(%esp)
c0103f4a:	e8 81 0a 00 00       	call   c01049d0 <free_pages>
}
c0103f4f:	90                   	nop
c0103f50:	89 ec                	mov    %ebp,%esp
c0103f52:	5d                   	pop    %ebp
c0103f53:	c3                   	ret    

c0103f54 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0103f54:	55                   	push   %ebp
c0103f55:	89 e5                	mov    %esp,%ebp
c0103f57:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0103f5d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103f64:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0103f6b:	c7 45 ec 84 6f 12 c0 	movl   $0xc0126f84,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0103f72:	eb 6a                	jmp    c0103fde <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c0103f74:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103f77:	83 e8 0c             	sub    $0xc,%eax
c0103f7a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c0103f7d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103f80:	83 c0 04             	add    $0x4,%eax
c0103f83:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0103f8a:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103f8d:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103f90:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103f93:	0f a3 10             	bt     %edx,(%eax)
c0103f96:	19 c0                	sbb    %eax,%eax
c0103f98:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0103f9b:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0103f9f:	0f 95 c0             	setne  %al
c0103fa2:	0f b6 c0             	movzbl %al,%eax
c0103fa5:	85 c0                	test   %eax,%eax
c0103fa7:	75 24                	jne    c0103fcd <default_check+0x79>
c0103fa9:	c7 44 24 0c 7e 9a 10 	movl   $0xc0109a7e,0xc(%esp)
c0103fb0:	c0 
c0103fb1:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c0103fb8:	c0 
c0103fb9:	c7 44 24 04 80 01 00 	movl   $0x180,0x4(%esp)
c0103fc0:	00 
c0103fc1:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c0103fc8:	e8 41 cd ff ff       	call   c0100d0e <__panic>
        count ++, total += p->property;
c0103fcd:	ff 45 f4             	incl   -0xc(%ebp)
c0103fd0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103fd3:	8b 50 08             	mov    0x8(%eax),%edx
c0103fd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103fd9:	01 d0                	add    %edx,%eax
c0103fdb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103fde:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103fe1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c0103fe4:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103fe7:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0103fea:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103fed:	81 7d ec 84 6f 12 c0 	cmpl   $0xc0126f84,-0x14(%ebp)
c0103ff4:	0f 85 7a ff ff ff    	jne    c0103f74 <default_check+0x20>
    }
    assert(total == nr_free_pages());
c0103ffa:	e8 06 0a 00 00       	call   c0104a05 <nr_free_pages>
c0103fff:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104002:	39 d0                	cmp    %edx,%eax
c0104004:	74 24                	je     c010402a <default_check+0xd6>
c0104006:	c7 44 24 0c 8e 9a 10 	movl   $0xc0109a8e,0xc(%esp)
c010400d:	c0 
c010400e:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c0104015:	c0 
c0104016:	c7 44 24 04 83 01 00 	movl   $0x183,0x4(%esp)
c010401d:	00 
c010401e:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c0104025:	e8 e4 cc ff ff       	call   c0100d0e <__panic>

    basic_check();
c010402a:	e8 e5 f9 ff ff       	call   c0103a14 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c010402f:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0104036:	e8 28 09 00 00       	call   c0104963 <alloc_pages>
c010403b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c010403e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104042:	75 24                	jne    c0104068 <default_check+0x114>
c0104044:	c7 44 24 0c a7 9a 10 	movl   $0xc0109aa7,0xc(%esp)
c010404b:	c0 
c010404c:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c0104053:	c0 
c0104054:	c7 44 24 04 88 01 00 	movl   $0x188,0x4(%esp)
c010405b:	00 
c010405c:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c0104063:	e8 a6 cc ff ff       	call   c0100d0e <__panic>
    assert(!PageProperty(p0));
c0104068:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010406b:	83 c0 04             	add    $0x4,%eax
c010406e:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0104075:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104078:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010407b:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010407e:	0f a3 10             	bt     %edx,(%eax)
c0104081:	19 c0                	sbb    %eax,%eax
c0104083:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0104086:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c010408a:	0f 95 c0             	setne  %al
c010408d:	0f b6 c0             	movzbl %al,%eax
c0104090:	85 c0                	test   %eax,%eax
c0104092:	74 24                	je     c01040b8 <default_check+0x164>
c0104094:	c7 44 24 0c b2 9a 10 	movl   $0xc0109ab2,0xc(%esp)
c010409b:	c0 
c010409c:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c01040a3:	c0 
c01040a4:	c7 44 24 04 89 01 00 	movl   $0x189,0x4(%esp)
c01040ab:	00 
c01040ac:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c01040b3:	e8 56 cc ff ff       	call   c0100d0e <__panic>

    list_entry_t free_list_store = free_list;
c01040b8:	a1 84 6f 12 c0       	mov    0xc0126f84,%eax
c01040bd:	8b 15 88 6f 12 c0    	mov    0xc0126f88,%edx
c01040c3:	89 45 80             	mov    %eax,-0x80(%ebp)
c01040c6:	89 55 84             	mov    %edx,-0x7c(%ebp)
c01040c9:	c7 45 b0 84 6f 12 c0 	movl   $0xc0126f84,-0x50(%ebp)
    elm->prev = elm->next = elm;
c01040d0:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01040d3:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01040d6:	89 50 04             	mov    %edx,0x4(%eax)
c01040d9:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01040dc:	8b 50 04             	mov    0x4(%eax),%edx
c01040df:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01040e2:	89 10                	mov    %edx,(%eax)
}
c01040e4:	90                   	nop
c01040e5:	c7 45 b4 84 6f 12 c0 	movl   $0xc0126f84,-0x4c(%ebp)
    return list->next == list;
c01040ec:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01040ef:	8b 40 04             	mov    0x4(%eax),%eax
c01040f2:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c01040f5:	0f 94 c0             	sete   %al
c01040f8:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c01040fb:	85 c0                	test   %eax,%eax
c01040fd:	75 24                	jne    c0104123 <default_check+0x1cf>
c01040ff:	c7 44 24 0c 07 9a 10 	movl   $0xc0109a07,0xc(%esp)
c0104106:	c0 
c0104107:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c010410e:	c0 
c010410f:	c7 44 24 04 8d 01 00 	movl   $0x18d,0x4(%esp)
c0104116:	00 
c0104117:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c010411e:	e8 eb cb ff ff       	call   c0100d0e <__panic>
    assert(alloc_page() == NULL);
c0104123:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010412a:	e8 34 08 00 00       	call   c0104963 <alloc_pages>
c010412f:	85 c0                	test   %eax,%eax
c0104131:	74 24                	je     c0104157 <default_check+0x203>
c0104133:	c7 44 24 0c 1e 9a 10 	movl   $0xc0109a1e,0xc(%esp)
c010413a:	c0 
c010413b:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c0104142:	c0 
c0104143:	c7 44 24 04 8e 01 00 	movl   $0x18e,0x4(%esp)
c010414a:	00 
c010414b:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c0104152:	e8 b7 cb ff ff       	call   c0100d0e <__panic>

    unsigned int nr_free_store = nr_free;
c0104157:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
c010415c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c010415f:	c7 05 8c 6f 12 c0 00 	movl   $0x0,0xc0126f8c
c0104166:	00 00 00 

    free_pages(p0 + 2, 3);
c0104169:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010416c:	83 c0 40             	add    $0x40,%eax
c010416f:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0104176:	00 
c0104177:	89 04 24             	mov    %eax,(%esp)
c010417a:	e8 51 08 00 00       	call   c01049d0 <free_pages>
    assert(alloc_pages(4) == NULL);
c010417f:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0104186:	e8 d8 07 00 00       	call   c0104963 <alloc_pages>
c010418b:	85 c0                	test   %eax,%eax
c010418d:	74 24                	je     c01041b3 <default_check+0x25f>
c010418f:	c7 44 24 0c c4 9a 10 	movl   $0xc0109ac4,0xc(%esp)
c0104196:	c0 
c0104197:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c010419e:	c0 
c010419f:	c7 44 24 04 94 01 00 	movl   $0x194,0x4(%esp)
c01041a6:	00 
c01041a7:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c01041ae:	e8 5b cb ff ff       	call   c0100d0e <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c01041b3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01041b6:	83 c0 40             	add    $0x40,%eax
c01041b9:	83 c0 04             	add    $0x4,%eax
c01041bc:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c01041c3:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01041c6:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01041c9:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01041cc:	0f a3 10             	bt     %edx,(%eax)
c01041cf:	19 c0                	sbb    %eax,%eax
c01041d1:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c01041d4:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c01041d8:	0f 95 c0             	setne  %al
c01041db:	0f b6 c0             	movzbl %al,%eax
c01041de:	85 c0                	test   %eax,%eax
c01041e0:	74 0e                	je     c01041f0 <default_check+0x29c>
c01041e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01041e5:	83 c0 40             	add    $0x40,%eax
c01041e8:	8b 40 08             	mov    0x8(%eax),%eax
c01041eb:	83 f8 03             	cmp    $0x3,%eax
c01041ee:	74 24                	je     c0104214 <default_check+0x2c0>
c01041f0:	c7 44 24 0c dc 9a 10 	movl   $0xc0109adc,0xc(%esp)
c01041f7:	c0 
c01041f8:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c01041ff:	c0 
c0104200:	c7 44 24 04 95 01 00 	movl   $0x195,0x4(%esp)
c0104207:	00 
c0104208:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c010420f:	e8 fa ca ff ff       	call   c0100d0e <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0104214:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c010421b:	e8 43 07 00 00       	call   c0104963 <alloc_pages>
c0104220:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104223:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0104227:	75 24                	jne    c010424d <default_check+0x2f9>
c0104229:	c7 44 24 0c 08 9b 10 	movl   $0xc0109b08,0xc(%esp)
c0104230:	c0 
c0104231:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c0104238:	c0 
c0104239:	c7 44 24 04 96 01 00 	movl   $0x196,0x4(%esp)
c0104240:	00 
c0104241:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c0104248:	e8 c1 ca ff ff       	call   c0100d0e <__panic>
    assert(alloc_page() == NULL);
c010424d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104254:	e8 0a 07 00 00       	call   c0104963 <alloc_pages>
c0104259:	85 c0                	test   %eax,%eax
c010425b:	74 24                	je     c0104281 <default_check+0x32d>
c010425d:	c7 44 24 0c 1e 9a 10 	movl   $0xc0109a1e,0xc(%esp)
c0104264:	c0 
c0104265:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c010426c:	c0 
c010426d:	c7 44 24 04 97 01 00 	movl   $0x197,0x4(%esp)
c0104274:	00 
c0104275:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c010427c:	e8 8d ca ff ff       	call   c0100d0e <__panic>
    assert(p0 + 2 == p1);
c0104281:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104284:	83 c0 40             	add    $0x40,%eax
c0104287:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c010428a:	74 24                	je     c01042b0 <default_check+0x35c>
c010428c:	c7 44 24 0c 26 9b 10 	movl   $0xc0109b26,0xc(%esp)
c0104293:	c0 
c0104294:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c010429b:	c0 
c010429c:	c7 44 24 04 98 01 00 	movl   $0x198,0x4(%esp)
c01042a3:	00 
c01042a4:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c01042ab:	e8 5e ca ff ff       	call   c0100d0e <__panic>

    p2 = p0 + 1;
c01042b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01042b3:	83 c0 20             	add    $0x20,%eax
c01042b6:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c01042b9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01042c0:	00 
c01042c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01042c4:	89 04 24             	mov    %eax,(%esp)
c01042c7:	e8 04 07 00 00       	call   c01049d0 <free_pages>
    free_pages(p1, 3);
c01042cc:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01042d3:	00 
c01042d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01042d7:	89 04 24             	mov    %eax,(%esp)
c01042da:	e8 f1 06 00 00       	call   c01049d0 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c01042df:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01042e2:	83 c0 04             	add    $0x4,%eax
c01042e5:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c01042ec:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01042ef:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01042f2:	8b 55 a0             	mov    -0x60(%ebp),%edx
c01042f5:	0f a3 10             	bt     %edx,(%eax)
c01042f8:	19 c0                	sbb    %eax,%eax
c01042fa:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c01042fd:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0104301:	0f 95 c0             	setne  %al
c0104304:	0f b6 c0             	movzbl %al,%eax
c0104307:	85 c0                	test   %eax,%eax
c0104309:	74 0b                	je     c0104316 <default_check+0x3c2>
c010430b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010430e:	8b 40 08             	mov    0x8(%eax),%eax
c0104311:	83 f8 01             	cmp    $0x1,%eax
c0104314:	74 24                	je     c010433a <default_check+0x3e6>
c0104316:	c7 44 24 0c 34 9b 10 	movl   $0xc0109b34,0xc(%esp)
c010431d:	c0 
c010431e:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c0104325:	c0 
c0104326:	c7 44 24 04 9d 01 00 	movl   $0x19d,0x4(%esp)
c010432d:	00 
c010432e:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c0104335:	e8 d4 c9 ff ff       	call   c0100d0e <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c010433a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010433d:	83 c0 04             	add    $0x4,%eax
c0104340:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0104347:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010434a:	8b 45 90             	mov    -0x70(%ebp),%eax
c010434d:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0104350:	0f a3 10             	bt     %edx,(%eax)
c0104353:	19 c0                	sbb    %eax,%eax
c0104355:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0104358:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c010435c:	0f 95 c0             	setne  %al
c010435f:	0f b6 c0             	movzbl %al,%eax
c0104362:	85 c0                	test   %eax,%eax
c0104364:	74 0b                	je     c0104371 <default_check+0x41d>
c0104366:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104369:	8b 40 08             	mov    0x8(%eax),%eax
c010436c:	83 f8 03             	cmp    $0x3,%eax
c010436f:	74 24                	je     c0104395 <default_check+0x441>
c0104371:	c7 44 24 0c 5c 9b 10 	movl   $0xc0109b5c,0xc(%esp)
c0104378:	c0 
c0104379:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c0104380:	c0 
c0104381:	c7 44 24 04 9e 01 00 	movl   $0x19e,0x4(%esp)
c0104388:	00 
c0104389:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c0104390:	e8 79 c9 ff ff       	call   c0100d0e <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0104395:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010439c:	e8 c2 05 00 00       	call   c0104963 <alloc_pages>
c01043a1:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01043a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01043a7:	83 e8 20             	sub    $0x20,%eax
c01043aa:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01043ad:	74 24                	je     c01043d3 <default_check+0x47f>
c01043af:	c7 44 24 0c 82 9b 10 	movl   $0xc0109b82,0xc(%esp)
c01043b6:	c0 
c01043b7:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c01043be:	c0 
c01043bf:	c7 44 24 04 a0 01 00 	movl   $0x1a0,0x4(%esp)
c01043c6:	00 
c01043c7:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c01043ce:	e8 3b c9 ff ff       	call   c0100d0e <__panic>
    free_page(p0);
c01043d3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01043da:	00 
c01043db:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01043de:	89 04 24             	mov    %eax,(%esp)
c01043e1:	e8 ea 05 00 00       	call   c01049d0 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c01043e6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c01043ed:	e8 71 05 00 00       	call   c0104963 <alloc_pages>
c01043f2:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01043f5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01043f8:	83 c0 20             	add    $0x20,%eax
c01043fb:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01043fe:	74 24                	je     c0104424 <default_check+0x4d0>
c0104400:	c7 44 24 0c a0 9b 10 	movl   $0xc0109ba0,0xc(%esp)
c0104407:	c0 
c0104408:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c010440f:	c0 
c0104410:	c7 44 24 04 a2 01 00 	movl   $0x1a2,0x4(%esp)
c0104417:	00 
c0104418:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c010441f:	e8 ea c8 ff ff       	call   c0100d0e <__panic>

    free_pages(p0, 2);
c0104424:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c010442b:	00 
c010442c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010442f:	89 04 24             	mov    %eax,(%esp)
c0104432:	e8 99 05 00 00       	call   c01049d0 <free_pages>
    free_page(p2);
c0104437:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010443e:	00 
c010443f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104442:	89 04 24             	mov    %eax,(%esp)
c0104445:	e8 86 05 00 00       	call   c01049d0 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c010444a:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0104451:	e8 0d 05 00 00       	call   c0104963 <alloc_pages>
c0104456:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104459:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010445d:	75 24                	jne    c0104483 <default_check+0x52f>
c010445f:	c7 44 24 0c c0 9b 10 	movl   $0xc0109bc0,0xc(%esp)
c0104466:	c0 
c0104467:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c010446e:	c0 
c010446f:	c7 44 24 04 a7 01 00 	movl   $0x1a7,0x4(%esp)
c0104476:	00 
c0104477:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c010447e:	e8 8b c8 ff ff       	call   c0100d0e <__panic>
    assert(alloc_page() == NULL);
c0104483:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010448a:	e8 d4 04 00 00       	call   c0104963 <alloc_pages>
c010448f:	85 c0                	test   %eax,%eax
c0104491:	74 24                	je     c01044b7 <default_check+0x563>
c0104493:	c7 44 24 0c 1e 9a 10 	movl   $0xc0109a1e,0xc(%esp)
c010449a:	c0 
c010449b:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c01044a2:	c0 
c01044a3:	c7 44 24 04 a8 01 00 	movl   $0x1a8,0x4(%esp)
c01044aa:	00 
c01044ab:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c01044b2:	e8 57 c8 ff ff       	call   c0100d0e <__panic>

    assert(nr_free == 0);
c01044b7:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
c01044bc:	85 c0                	test   %eax,%eax
c01044be:	74 24                	je     c01044e4 <default_check+0x590>
c01044c0:	c7 44 24 0c 71 9a 10 	movl   $0xc0109a71,0xc(%esp)
c01044c7:	c0 
c01044c8:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c01044cf:	c0 
c01044d0:	c7 44 24 04 aa 01 00 	movl   $0x1aa,0x4(%esp)
c01044d7:	00 
c01044d8:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c01044df:	e8 2a c8 ff ff       	call   c0100d0e <__panic>
    nr_free = nr_free_store;
c01044e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01044e7:	a3 8c 6f 12 c0       	mov    %eax,0xc0126f8c

    free_list = free_list_store;
c01044ec:	8b 45 80             	mov    -0x80(%ebp),%eax
c01044ef:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01044f2:	a3 84 6f 12 c0       	mov    %eax,0xc0126f84
c01044f7:	89 15 88 6f 12 c0    	mov    %edx,0xc0126f88
    free_pages(p0, 5);
c01044fd:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0104504:	00 
c0104505:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104508:	89 04 24             	mov    %eax,(%esp)
c010450b:	e8 c0 04 00 00       	call   c01049d0 <free_pages>

    le = &free_list;
c0104510:	c7 45 ec 84 6f 12 c0 	movl   $0xc0126f84,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104517:	eb 5a                	jmp    c0104573 <default_check+0x61f>
        assert(le->next->prev == le && le->prev->next == le);
c0104519:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010451c:	8b 40 04             	mov    0x4(%eax),%eax
c010451f:	8b 00                	mov    (%eax),%eax
c0104521:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0104524:	75 0d                	jne    c0104533 <default_check+0x5df>
c0104526:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104529:	8b 00                	mov    (%eax),%eax
c010452b:	8b 40 04             	mov    0x4(%eax),%eax
c010452e:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0104531:	74 24                	je     c0104557 <default_check+0x603>
c0104533:	c7 44 24 0c e0 9b 10 	movl   $0xc0109be0,0xc(%esp)
c010453a:	c0 
c010453b:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c0104542:	c0 
c0104543:	c7 44 24 04 b2 01 00 	movl   $0x1b2,0x4(%esp)
c010454a:	00 
c010454b:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c0104552:	e8 b7 c7 ff ff       	call   c0100d0e <__panic>
        struct Page *p = le2page(le, page_link);
c0104557:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010455a:	83 e8 0c             	sub    $0xc,%eax
c010455d:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
c0104560:	ff 4d f4             	decl   -0xc(%ebp)
c0104563:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104566:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104569:	8b 48 08             	mov    0x8(%eax),%ecx
c010456c:	89 d0                	mov    %edx,%eax
c010456e:	29 c8                	sub    %ecx,%eax
c0104570:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104573:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104576:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c0104579:	8b 45 88             	mov    -0x78(%ebp),%eax
c010457c:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c010457f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104582:	81 7d ec 84 6f 12 c0 	cmpl   $0xc0126f84,-0x14(%ebp)
c0104589:	75 8e                	jne    c0104519 <default_check+0x5c5>
    }
    assert(count == 0);
c010458b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010458f:	74 24                	je     c01045b5 <default_check+0x661>
c0104591:	c7 44 24 0c 0d 9c 10 	movl   $0xc0109c0d,0xc(%esp)
c0104598:	c0 
c0104599:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c01045a0:	c0 
c01045a1:	c7 44 24 04 b6 01 00 	movl   $0x1b6,0x4(%esp)
c01045a8:	00 
c01045a9:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c01045b0:	e8 59 c7 ff ff       	call   c0100d0e <__panic>
    assert(total == 0);
c01045b5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01045b9:	74 24                	je     c01045df <default_check+0x68b>
c01045bb:	c7 44 24 0c 18 9c 10 	movl   $0xc0109c18,0xc(%esp)
c01045c2:	c0 
c01045c3:	c7 44 24 08 96 98 10 	movl   $0xc0109896,0x8(%esp)
c01045ca:	c0 
c01045cb:	c7 44 24 04 b7 01 00 	movl   $0x1b7,0x4(%esp)
c01045d2:	00 
c01045d3:	c7 04 24 ab 98 10 c0 	movl   $0xc01098ab,(%esp)
c01045da:	e8 2f c7 ff ff       	call   c0100d0e <__panic>
}
c01045df:	90                   	nop
c01045e0:	89 ec                	mov    %ebp,%esp
c01045e2:	5d                   	pop    %ebp
c01045e3:	c3                   	ret    

c01045e4 <page2ppn>:
page2ppn(struct Page *page) {
c01045e4:	55                   	push   %ebp
c01045e5:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01045e7:	8b 15 a0 6f 12 c0    	mov    0xc0126fa0,%edx
c01045ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01045f0:	29 d0                	sub    %edx,%eax
c01045f2:	c1 f8 05             	sar    $0x5,%eax
}
c01045f5:	5d                   	pop    %ebp
c01045f6:	c3                   	ret    

c01045f7 <page2pa>:
page2pa(struct Page *page) {
c01045f7:	55                   	push   %ebp
c01045f8:	89 e5                	mov    %esp,%ebp
c01045fa:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01045fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0104600:	89 04 24             	mov    %eax,(%esp)
c0104603:	e8 dc ff ff ff       	call   c01045e4 <page2ppn>
c0104608:	c1 e0 0c             	shl    $0xc,%eax
}
c010460b:	89 ec                	mov    %ebp,%esp
c010460d:	5d                   	pop    %ebp
c010460e:	c3                   	ret    

c010460f <pa2page>:
pa2page(uintptr_t pa) {
c010460f:	55                   	push   %ebp
c0104610:	89 e5                	mov    %esp,%ebp
c0104612:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0104615:	8b 45 08             	mov    0x8(%ebp),%eax
c0104618:	c1 e8 0c             	shr    $0xc,%eax
c010461b:	89 c2                	mov    %eax,%edx
c010461d:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c0104622:	39 c2                	cmp    %eax,%edx
c0104624:	72 1c                	jb     c0104642 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0104626:	c7 44 24 08 54 9c 10 	movl   $0xc0109c54,0x8(%esp)
c010462d:	c0 
c010462e:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c0104635:	00 
c0104636:	c7 04 24 73 9c 10 c0 	movl   $0xc0109c73,(%esp)
c010463d:	e8 cc c6 ff ff       	call   c0100d0e <__panic>
    return &pages[PPN(pa)];
c0104642:	8b 15 a0 6f 12 c0    	mov    0xc0126fa0,%edx
c0104648:	8b 45 08             	mov    0x8(%ebp),%eax
c010464b:	c1 e8 0c             	shr    $0xc,%eax
c010464e:	c1 e0 05             	shl    $0x5,%eax
c0104651:	01 d0                	add    %edx,%eax
}
c0104653:	89 ec                	mov    %ebp,%esp
c0104655:	5d                   	pop    %ebp
c0104656:	c3                   	ret    

c0104657 <page2kva>:
page2kva(struct Page *page) {
c0104657:	55                   	push   %ebp
c0104658:	89 e5                	mov    %esp,%ebp
c010465a:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c010465d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104660:	89 04 24             	mov    %eax,(%esp)
c0104663:	e8 8f ff ff ff       	call   c01045f7 <page2pa>
c0104668:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010466b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010466e:	c1 e8 0c             	shr    $0xc,%eax
c0104671:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104674:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c0104679:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010467c:	72 23                	jb     c01046a1 <page2kva+0x4a>
c010467e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104681:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104685:	c7 44 24 08 84 9c 10 	movl   $0xc0109c84,0x8(%esp)
c010468c:	c0 
c010468d:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c0104694:	00 
c0104695:	c7 04 24 73 9c 10 c0 	movl   $0xc0109c73,(%esp)
c010469c:	e8 6d c6 ff ff       	call   c0100d0e <__panic>
c01046a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046a4:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01046a9:	89 ec                	mov    %ebp,%esp
c01046ab:	5d                   	pop    %ebp
c01046ac:	c3                   	ret    

c01046ad <kva2page>:
kva2page(void *kva) {
c01046ad:	55                   	push   %ebp
c01046ae:	89 e5                	mov    %esp,%ebp
c01046b0:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c01046b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01046b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01046b9:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01046c0:	77 23                	ja     c01046e5 <kva2page+0x38>
c01046c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01046c9:	c7 44 24 08 a8 9c 10 	movl   $0xc0109ca8,0x8(%esp)
c01046d0:	c0 
c01046d1:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c01046d8:	00 
c01046d9:	c7 04 24 73 9c 10 c0 	movl   $0xc0109c73,(%esp)
c01046e0:	e8 29 c6 ff ff       	call   c0100d0e <__panic>
c01046e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046e8:	05 00 00 00 40       	add    $0x40000000,%eax
c01046ed:	89 04 24             	mov    %eax,(%esp)
c01046f0:	e8 1a ff ff ff       	call   c010460f <pa2page>
}
c01046f5:	89 ec                	mov    %ebp,%esp
c01046f7:	5d                   	pop    %ebp
c01046f8:	c3                   	ret    

c01046f9 <pte2page>:
pte2page(pte_t pte) {
c01046f9:	55                   	push   %ebp
c01046fa:	89 e5                	mov    %esp,%ebp
c01046fc:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c01046ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0104702:	83 e0 01             	and    $0x1,%eax
c0104705:	85 c0                	test   %eax,%eax
c0104707:	75 1c                	jne    c0104725 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0104709:	c7 44 24 08 cc 9c 10 	movl   $0xc0109ccc,0x8(%esp)
c0104710:	c0 
c0104711:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0104718:	00 
c0104719:	c7 04 24 73 9c 10 c0 	movl   $0xc0109c73,(%esp)
c0104720:	e8 e9 c5 ff ff       	call   c0100d0e <__panic>
    return pa2page(PTE_ADDR(pte));
c0104725:	8b 45 08             	mov    0x8(%ebp),%eax
c0104728:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010472d:	89 04 24             	mov    %eax,(%esp)
c0104730:	e8 da fe ff ff       	call   c010460f <pa2page>
}
c0104735:	89 ec                	mov    %ebp,%esp
c0104737:	5d                   	pop    %ebp
c0104738:	c3                   	ret    

c0104739 <pde2page>:
pde2page(pde_t pde) {
c0104739:	55                   	push   %ebp
c010473a:	89 e5                	mov    %esp,%ebp
c010473c:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c010473f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104742:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104747:	89 04 24             	mov    %eax,(%esp)
c010474a:	e8 c0 fe ff ff       	call   c010460f <pa2page>
}
c010474f:	89 ec                	mov    %ebp,%esp
c0104751:	5d                   	pop    %ebp
c0104752:	c3                   	ret    

c0104753 <page_ref>:
page_ref(struct Page *page) {
c0104753:	55                   	push   %ebp
c0104754:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0104756:	8b 45 08             	mov    0x8(%ebp),%eax
c0104759:	8b 00                	mov    (%eax),%eax
}
c010475b:	5d                   	pop    %ebp
c010475c:	c3                   	ret    

c010475d <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c010475d:	55                   	push   %ebp
c010475e:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0104760:	8b 45 08             	mov    0x8(%ebp),%eax
c0104763:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104766:	89 10                	mov    %edx,(%eax)
}
c0104768:	90                   	nop
c0104769:	5d                   	pop    %ebp
c010476a:	c3                   	ret    

c010476b <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c010476b:	55                   	push   %ebp
c010476c:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c010476e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104771:	8b 00                	mov    (%eax),%eax
c0104773:	8d 50 01             	lea    0x1(%eax),%edx
c0104776:	8b 45 08             	mov    0x8(%ebp),%eax
c0104779:	89 10                	mov    %edx,(%eax)
    return page->ref;
c010477b:	8b 45 08             	mov    0x8(%ebp),%eax
c010477e:	8b 00                	mov    (%eax),%eax
}
c0104780:	5d                   	pop    %ebp
c0104781:	c3                   	ret    

c0104782 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0104782:	55                   	push   %ebp
c0104783:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0104785:	8b 45 08             	mov    0x8(%ebp),%eax
c0104788:	8b 00                	mov    (%eax),%eax
c010478a:	8d 50 ff             	lea    -0x1(%eax),%edx
c010478d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104790:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0104792:	8b 45 08             	mov    0x8(%ebp),%eax
c0104795:	8b 00                	mov    (%eax),%eax
}
c0104797:	5d                   	pop    %ebp
c0104798:	c3                   	ret    

c0104799 <__intr_save>:
__intr_save(void) {
c0104799:	55                   	push   %ebp
c010479a:	89 e5                	mov    %esp,%ebp
c010479c:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010479f:	9c                   	pushf  
c01047a0:	58                   	pop    %eax
c01047a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01047a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01047a7:	25 00 02 00 00       	and    $0x200,%eax
c01047ac:	85 c0                	test   %eax,%eax
c01047ae:	74 0c                	je     c01047bc <__intr_save+0x23>
        intr_disable();
c01047b0:	e8 0f d8 ff ff       	call   c0101fc4 <intr_disable>
        return 1;
c01047b5:	b8 01 00 00 00       	mov    $0x1,%eax
c01047ba:	eb 05                	jmp    c01047c1 <__intr_save+0x28>
    return 0;
c01047bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01047c1:	89 ec                	mov    %ebp,%esp
c01047c3:	5d                   	pop    %ebp
c01047c4:	c3                   	ret    

c01047c5 <__intr_restore>:
__intr_restore(bool flag) {
c01047c5:	55                   	push   %ebp
c01047c6:	89 e5                	mov    %esp,%ebp
c01047c8:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01047cb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01047cf:	74 05                	je     c01047d6 <__intr_restore+0x11>
        intr_enable();
c01047d1:	e8 e6 d7 ff ff       	call   c0101fbc <intr_enable>
}
c01047d6:	90                   	nop
c01047d7:	89 ec                	mov    %ebp,%esp
c01047d9:	5d                   	pop    %ebp
c01047da:	c3                   	ret    

c01047db <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c01047db:	55                   	push   %ebp
c01047dc:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c01047de:	8b 45 08             	mov    0x8(%ebp),%eax
c01047e1:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c01047e4:	b8 23 00 00 00       	mov    $0x23,%eax
c01047e9:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c01047eb:	b8 23 00 00 00       	mov    $0x23,%eax
c01047f0:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c01047f2:	b8 10 00 00 00       	mov    $0x10,%eax
c01047f7:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c01047f9:	b8 10 00 00 00       	mov    $0x10,%eax
c01047fe:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0104800:	b8 10 00 00 00       	mov    $0x10,%eax
c0104805:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0104807:	ea 0e 48 10 c0 08 00 	ljmp   $0x8,$0xc010480e
}
c010480e:	90                   	nop
c010480f:	5d                   	pop    %ebp
c0104810:	c3                   	ret    

c0104811 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0104811:	55                   	push   %ebp
c0104812:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0104814:	8b 45 08             	mov    0x8(%ebp),%eax
c0104817:	a3 c4 6f 12 c0       	mov    %eax,0xc0126fc4
}
c010481c:	90                   	nop
c010481d:	5d                   	pop    %ebp
c010481e:	c3                   	ret    

c010481f <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c010481f:	55                   	push   %ebp
c0104820:	89 e5                	mov    %esp,%ebp
c0104822:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0104825:	b8 00 30 12 c0       	mov    $0xc0123000,%eax
c010482a:	89 04 24             	mov    %eax,(%esp)
c010482d:	e8 df ff ff ff       	call   c0104811 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0104832:	66 c7 05 c8 6f 12 c0 	movw   $0x10,0xc0126fc8
c0104839:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c010483b:	66 c7 05 28 3a 12 c0 	movw   $0x68,0xc0123a28
c0104842:	68 00 
c0104844:	b8 c0 6f 12 c0       	mov    $0xc0126fc0,%eax
c0104849:	0f b7 c0             	movzwl %ax,%eax
c010484c:	66 a3 2a 3a 12 c0    	mov    %ax,0xc0123a2a
c0104852:	b8 c0 6f 12 c0       	mov    $0xc0126fc0,%eax
c0104857:	c1 e8 10             	shr    $0x10,%eax
c010485a:	a2 2c 3a 12 c0       	mov    %al,0xc0123a2c
c010485f:	0f b6 05 2d 3a 12 c0 	movzbl 0xc0123a2d,%eax
c0104866:	24 f0                	and    $0xf0,%al
c0104868:	0c 09                	or     $0x9,%al
c010486a:	a2 2d 3a 12 c0       	mov    %al,0xc0123a2d
c010486f:	0f b6 05 2d 3a 12 c0 	movzbl 0xc0123a2d,%eax
c0104876:	24 ef                	and    $0xef,%al
c0104878:	a2 2d 3a 12 c0       	mov    %al,0xc0123a2d
c010487d:	0f b6 05 2d 3a 12 c0 	movzbl 0xc0123a2d,%eax
c0104884:	24 9f                	and    $0x9f,%al
c0104886:	a2 2d 3a 12 c0       	mov    %al,0xc0123a2d
c010488b:	0f b6 05 2d 3a 12 c0 	movzbl 0xc0123a2d,%eax
c0104892:	0c 80                	or     $0x80,%al
c0104894:	a2 2d 3a 12 c0       	mov    %al,0xc0123a2d
c0104899:	0f b6 05 2e 3a 12 c0 	movzbl 0xc0123a2e,%eax
c01048a0:	24 f0                	and    $0xf0,%al
c01048a2:	a2 2e 3a 12 c0       	mov    %al,0xc0123a2e
c01048a7:	0f b6 05 2e 3a 12 c0 	movzbl 0xc0123a2e,%eax
c01048ae:	24 ef                	and    $0xef,%al
c01048b0:	a2 2e 3a 12 c0       	mov    %al,0xc0123a2e
c01048b5:	0f b6 05 2e 3a 12 c0 	movzbl 0xc0123a2e,%eax
c01048bc:	24 df                	and    $0xdf,%al
c01048be:	a2 2e 3a 12 c0       	mov    %al,0xc0123a2e
c01048c3:	0f b6 05 2e 3a 12 c0 	movzbl 0xc0123a2e,%eax
c01048ca:	0c 40                	or     $0x40,%al
c01048cc:	a2 2e 3a 12 c0       	mov    %al,0xc0123a2e
c01048d1:	0f b6 05 2e 3a 12 c0 	movzbl 0xc0123a2e,%eax
c01048d8:	24 7f                	and    $0x7f,%al
c01048da:	a2 2e 3a 12 c0       	mov    %al,0xc0123a2e
c01048df:	b8 c0 6f 12 c0       	mov    $0xc0126fc0,%eax
c01048e4:	c1 e8 18             	shr    $0x18,%eax
c01048e7:	a2 2f 3a 12 c0       	mov    %al,0xc0123a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c01048ec:	c7 04 24 30 3a 12 c0 	movl   $0xc0123a30,(%esp)
c01048f3:	e8 e3 fe ff ff       	call   c01047db <lgdt>
c01048f8:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c01048fe:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0104902:	0f 00 d8             	ltr    %ax
}
c0104905:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
c0104906:	90                   	nop
c0104907:	89 ec                	mov    %ebp,%esp
c0104909:	5d                   	pop    %ebp
c010490a:	c3                   	ret    

c010490b <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c010490b:	55                   	push   %ebp
c010490c:	89 e5                	mov    %esp,%ebp
c010490e:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0104911:	c7 05 ac 6f 12 c0 38 	movl   $0xc0109c38,0xc0126fac
c0104918:	9c 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c010491b:	a1 ac 6f 12 c0       	mov    0xc0126fac,%eax
c0104920:	8b 00                	mov    (%eax),%eax
c0104922:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104926:	c7 04 24 f8 9c 10 c0 	movl   $0xc0109cf8,(%esp)
c010492d:	e8 33 ba ff ff       	call   c0100365 <cprintf>
    pmm_manager->init();
c0104932:	a1 ac 6f 12 c0       	mov    0xc0126fac,%eax
c0104937:	8b 40 04             	mov    0x4(%eax),%eax
c010493a:	ff d0                	call   *%eax
}
c010493c:	90                   	nop
c010493d:	89 ec                	mov    %ebp,%esp
c010493f:	5d                   	pop    %ebp
c0104940:	c3                   	ret    

c0104941 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0104941:	55                   	push   %ebp
c0104942:	89 e5                	mov    %esp,%ebp
c0104944:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0104947:	a1 ac 6f 12 c0       	mov    0xc0126fac,%eax
c010494c:	8b 40 08             	mov    0x8(%eax),%eax
c010494f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104952:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104956:	8b 55 08             	mov    0x8(%ebp),%edx
c0104959:	89 14 24             	mov    %edx,(%esp)
c010495c:	ff d0                	call   *%eax
}
c010495e:	90                   	nop
c010495f:	89 ec                	mov    %ebp,%esp
c0104961:	5d                   	pop    %ebp
c0104962:	c3                   	ret    

c0104963 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0104963:	55                   	push   %ebp
c0104964:	89 e5                	mov    %esp,%ebp
c0104966:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0104969:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c0104970:	e8 24 fe ff ff       	call   c0104799 <__intr_save>
c0104975:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c0104978:	a1 ac 6f 12 c0       	mov    0xc0126fac,%eax
c010497d:	8b 40 0c             	mov    0xc(%eax),%eax
c0104980:	8b 55 08             	mov    0x8(%ebp),%edx
c0104983:	89 14 24             	mov    %edx,(%esp)
c0104986:	ff d0                	call   *%eax
c0104988:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c010498b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010498e:	89 04 24             	mov    %eax,(%esp)
c0104991:	e8 2f fe ff ff       	call   c01047c5 <__intr_restore>

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c0104996:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010499a:	75 2d                	jne    c01049c9 <alloc_pages+0x66>
c010499c:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c01049a0:	77 27                	ja     c01049c9 <alloc_pages+0x66>
c01049a2:	a1 44 70 12 c0       	mov    0xc0127044,%eax
c01049a7:	85 c0                	test   %eax,%eax
c01049a9:	74 1e                	je     c01049c9 <alloc_pages+0x66>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c01049ab:	8b 55 08             	mov    0x8(%ebp),%edx
c01049ae:	a1 0c 71 12 c0       	mov    0xc012710c,%eax
c01049b3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01049ba:	00 
c01049bb:	89 54 24 04          	mov    %edx,0x4(%esp)
c01049bf:	89 04 24             	mov    %eax,(%esp)
c01049c2:	e8 63 1a 00 00       	call   c010642a <swap_out>
    {
c01049c7:	eb a7                	jmp    c0104970 <alloc_pages+0xd>
    }
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c01049c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01049cc:	89 ec                	mov    %ebp,%esp
c01049ce:	5d                   	pop    %ebp
c01049cf:	c3                   	ret    

c01049d0 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c01049d0:	55                   	push   %ebp
c01049d1:	89 e5                	mov    %esp,%ebp
c01049d3:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c01049d6:	e8 be fd ff ff       	call   c0104799 <__intr_save>
c01049db:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c01049de:	a1 ac 6f 12 c0       	mov    0xc0126fac,%eax
c01049e3:	8b 40 10             	mov    0x10(%eax),%eax
c01049e6:	8b 55 0c             	mov    0xc(%ebp),%edx
c01049e9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01049ed:	8b 55 08             	mov    0x8(%ebp),%edx
c01049f0:	89 14 24             	mov    %edx,(%esp)
c01049f3:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c01049f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049f8:	89 04 24             	mov    %eax,(%esp)
c01049fb:	e8 c5 fd ff ff       	call   c01047c5 <__intr_restore>
}
c0104a00:	90                   	nop
c0104a01:	89 ec                	mov    %ebp,%esp
c0104a03:	5d                   	pop    %ebp
c0104a04:	c3                   	ret    

c0104a05 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0104a05:	55                   	push   %ebp
c0104a06:	89 e5                	mov    %esp,%ebp
c0104a08:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0104a0b:	e8 89 fd ff ff       	call   c0104799 <__intr_save>
c0104a10:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0104a13:	a1 ac 6f 12 c0       	mov    0xc0126fac,%eax
c0104a18:	8b 40 14             	mov    0x14(%eax),%eax
c0104a1b:	ff d0                	call   *%eax
c0104a1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0104a20:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a23:	89 04 24             	mov    %eax,(%esp)
c0104a26:	e8 9a fd ff ff       	call   c01047c5 <__intr_restore>
    return ret;
c0104a2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0104a2e:	89 ec                	mov    %ebp,%esp
c0104a30:	5d                   	pop    %ebp
c0104a31:	c3                   	ret    

c0104a32 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0104a32:	55                   	push   %ebp
c0104a33:	89 e5                	mov    %esp,%ebp
c0104a35:	57                   	push   %edi
c0104a36:	56                   	push   %esi
c0104a37:	53                   	push   %ebx
c0104a38:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0104a3e:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0104a45:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0104a4c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0104a53:	c7 04 24 0f 9d 10 c0 	movl   $0xc0109d0f,(%esp)
c0104a5a:	e8 06 b9 ff ff       	call   c0100365 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0104a5f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104a66:	e9 0c 01 00 00       	jmp    c0104b77 <page_init+0x145>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0104a6b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104a6e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104a71:	89 d0                	mov    %edx,%eax
c0104a73:	c1 e0 02             	shl    $0x2,%eax
c0104a76:	01 d0                	add    %edx,%eax
c0104a78:	c1 e0 02             	shl    $0x2,%eax
c0104a7b:	01 c8                	add    %ecx,%eax
c0104a7d:	8b 50 08             	mov    0x8(%eax),%edx
c0104a80:	8b 40 04             	mov    0x4(%eax),%eax
c0104a83:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0104a86:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0104a89:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104a8c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104a8f:	89 d0                	mov    %edx,%eax
c0104a91:	c1 e0 02             	shl    $0x2,%eax
c0104a94:	01 d0                	add    %edx,%eax
c0104a96:	c1 e0 02             	shl    $0x2,%eax
c0104a99:	01 c8                	add    %ecx,%eax
c0104a9b:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104a9e:	8b 58 10             	mov    0x10(%eax),%ebx
c0104aa1:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104aa4:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0104aa7:	01 c8                	add    %ecx,%eax
c0104aa9:	11 da                	adc    %ebx,%edx
c0104aab:	89 45 98             	mov    %eax,-0x68(%ebp)
c0104aae:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0104ab1:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104ab4:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104ab7:	89 d0                	mov    %edx,%eax
c0104ab9:	c1 e0 02             	shl    $0x2,%eax
c0104abc:	01 d0                	add    %edx,%eax
c0104abe:	c1 e0 02             	shl    $0x2,%eax
c0104ac1:	01 c8                	add    %ecx,%eax
c0104ac3:	83 c0 14             	add    $0x14,%eax
c0104ac6:	8b 00                	mov    (%eax),%eax
c0104ac8:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c0104ace:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104ad1:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0104ad4:	83 c0 ff             	add    $0xffffffff,%eax
c0104ad7:	83 d2 ff             	adc    $0xffffffff,%edx
c0104ada:	89 c6                	mov    %eax,%esi
c0104adc:	89 d7                	mov    %edx,%edi
c0104ade:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104ae1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104ae4:	89 d0                	mov    %edx,%eax
c0104ae6:	c1 e0 02             	shl    $0x2,%eax
c0104ae9:	01 d0                	add    %edx,%eax
c0104aeb:	c1 e0 02             	shl    $0x2,%eax
c0104aee:	01 c8                	add    %ecx,%eax
c0104af0:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104af3:	8b 58 10             	mov    0x10(%eax),%ebx
c0104af6:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0104afc:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c0104b00:	89 74 24 14          	mov    %esi,0x14(%esp)
c0104b04:	89 7c 24 18          	mov    %edi,0x18(%esp)
c0104b08:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104b0b:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0104b0e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104b12:	89 54 24 10          	mov    %edx,0x10(%esp)
c0104b16:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0104b1a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0104b1e:	c7 04 24 1c 9d 10 c0 	movl   $0xc0109d1c,(%esp)
c0104b25:	e8 3b b8 ff ff       	call   c0100365 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0104b2a:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104b2d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104b30:	89 d0                	mov    %edx,%eax
c0104b32:	c1 e0 02             	shl    $0x2,%eax
c0104b35:	01 d0                	add    %edx,%eax
c0104b37:	c1 e0 02             	shl    $0x2,%eax
c0104b3a:	01 c8                	add    %ecx,%eax
c0104b3c:	83 c0 14             	add    $0x14,%eax
c0104b3f:	8b 00                	mov    (%eax),%eax
c0104b41:	83 f8 01             	cmp    $0x1,%eax
c0104b44:	75 2e                	jne    c0104b74 <page_init+0x142>
            if (maxpa < end && begin < KMEMSIZE) {
c0104b46:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104b49:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104b4c:	3b 45 98             	cmp    -0x68(%ebp),%eax
c0104b4f:	89 d0                	mov    %edx,%eax
c0104b51:	1b 45 9c             	sbb    -0x64(%ebp),%eax
c0104b54:	73 1e                	jae    c0104b74 <page_init+0x142>
c0104b56:	ba ff ff ff 37       	mov    $0x37ffffff,%edx
c0104b5b:	b8 00 00 00 00       	mov    $0x0,%eax
c0104b60:	3b 55 a0             	cmp    -0x60(%ebp),%edx
c0104b63:	1b 45 a4             	sbb    -0x5c(%ebp),%eax
c0104b66:	72 0c                	jb     c0104b74 <page_init+0x142>
                maxpa = end;
c0104b68:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104b6b:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0104b6e:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104b71:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c0104b74:	ff 45 dc             	incl   -0x24(%ebp)
c0104b77:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104b7a:	8b 00                	mov    (%eax),%eax
c0104b7c:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0104b7f:	0f 8c e6 fe ff ff    	jl     c0104a6b <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0104b85:	ba 00 00 00 38       	mov    $0x38000000,%edx
c0104b8a:	b8 00 00 00 00       	mov    $0x0,%eax
c0104b8f:	3b 55 e0             	cmp    -0x20(%ebp),%edx
c0104b92:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
c0104b95:	73 0e                	jae    c0104ba5 <page_init+0x173>
        maxpa = KMEMSIZE;
c0104b97:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0104b9e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0104ba5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104ba8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104bab:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0104baf:	c1 ea 0c             	shr    $0xc,%edx
c0104bb2:	a3 a4 6f 12 c0       	mov    %eax,0xc0126fa4
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0104bb7:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c0104bbe:	b8 14 71 12 c0       	mov    $0xc0127114,%eax
c0104bc3:	8d 50 ff             	lea    -0x1(%eax),%edx
c0104bc6:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104bc9:	01 d0                	add    %edx,%eax
c0104bcb:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0104bce:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104bd1:	ba 00 00 00 00       	mov    $0x0,%edx
c0104bd6:	f7 75 c0             	divl   -0x40(%ebp)
c0104bd9:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104bdc:	29 d0                	sub    %edx,%eax
c0104bde:	a3 a0 6f 12 c0       	mov    %eax,0xc0126fa0

    for (i = 0; i < npage; i ++) {
c0104be3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104bea:	eb 28                	jmp    c0104c14 <page_init+0x1e2>
        SetPageReserved(pages + i);
c0104bec:	8b 15 a0 6f 12 c0    	mov    0xc0126fa0,%edx
c0104bf2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104bf5:	c1 e0 05             	shl    $0x5,%eax
c0104bf8:	01 d0                	add    %edx,%eax
c0104bfa:	83 c0 04             	add    $0x4,%eax
c0104bfd:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c0104c04:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104c07:	8b 45 90             	mov    -0x70(%ebp),%eax
c0104c0a:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0104c0d:	0f ab 10             	bts    %edx,(%eax)
}
c0104c10:	90                   	nop
    for (i = 0; i < npage; i ++) {
c0104c11:	ff 45 dc             	incl   -0x24(%ebp)
c0104c14:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104c17:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c0104c1c:	39 c2                	cmp    %eax,%edx
c0104c1e:	72 cc                	jb     c0104bec <page_init+0x1ba>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0104c20:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c0104c25:	c1 e0 05             	shl    $0x5,%eax
c0104c28:	89 c2                	mov    %eax,%edx
c0104c2a:	a1 a0 6f 12 c0       	mov    0xc0126fa0,%eax
c0104c2f:	01 d0                	add    %edx,%eax
c0104c31:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0104c34:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c0104c3b:	77 23                	ja     c0104c60 <page_init+0x22e>
c0104c3d:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104c40:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104c44:	c7 44 24 08 a8 9c 10 	movl   $0xc0109ca8,0x8(%esp)
c0104c4b:	c0 
c0104c4c:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c0104c53:	00 
c0104c54:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0104c5b:	e8 ae c0 ff ff       	call   c0100d0e <__panic>
c0104c60:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104c63:	05 00 00 00 40       	add    $0x40000000,%eax
c0104c68:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0104c6b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104c72:	e9 53 01 00 00       	jmp    c0104dca <page_init+0x398>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0104c77:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104c7a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104c7d:	89 d0                	mov    %edx,%eax
c0104c7f:	c1 e0 02             	shl    $0x2,%eax
c0104c82:	01 d0                	add    %edx,%eax
c0104c84:	c1 e0 02             	shl    $0x2,%eax
c0104c87:	01 c8                	add    %ecx,%eax
c0104c89:	8b 50 08             	mov    0x8(%eax),%edx
c0104c8c:	8b 40 04             	mov    0x4(%eax),%eax
c0104c8f:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104c92:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104c95:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104c98:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104c9b:	89 d0                	mov    %edx,%eax
c0104c9d:	c1 e0 02             	shl    $0x2,%eax
c0104ca0:	01 d0                	add    %edx,%eax
c0104ca2:	c1 e0 02             	shl    $0x2,%eax
c0104ca5:	01 c8                	add    %ecx,%eax
c0104ca7:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104caa:	8b 58 10             	mov    0x10(%eax),%ebx
c0104cad:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104cb0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104cb3:	01 c8                	add    %ecx,%eax
c0104cb5:	11 da                	adc    %ebx,%edx
c0104cb7:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104cba:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0104cbd:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104cc0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104cc3:	89 d0                	mov    %edx,%eax
c0104cc5:	c1 e0 02             	shl    $0x2,%eax
c0104cc8:	01 d0                	add    %edx,%eax
c0104cca:	c1 e0 02             	shl    $0x2,%eax
c0104ccd:	01 c8                	add    %ecx,%eax
c0104ccf:	83 c0 14             	add    $0x14,%eax
c0104cd2:	8b 00                	mov    (%eax),%eax
c0104cd4:	83 f8 01             	cmp    $0x1,%eax
c0104cd7:	0f 85 ea 00 00 00    	jne    c0104dc7 <page_init+0x395>
            if (begin < freemem) {
c0104cdd:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104ce0:	ba 00 00 00 00       	mov    $0x0,%edx
c0104ce5:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0104ce8:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0104ceb:	19 d1                	sbb    %edx,%ecx
c0104ced:	73 0d                	jae    c0104cfc <page_init+0x2ca>
                begin = freemem;
c0104cef:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104cf2:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104cf5:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0104cfc:	ba 00 00 00 38       	mov    $0x38000000,%edx
c0104d01:	b8 00 00 00 00       	mov    $0x0,%eax
c0104d06:	3b 55 c8             	cmp    -0x38(%ebp),%edx
c0104d09:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0104d0c:	73 0e                	jae    c0104d1c <page_init+0x2ea>
                end = KMEMSIZE;
c0104d0e:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0104d15:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0104d1c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104d1f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104d22:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104d25:	89 d0                	mov    %edx,%eax
c0104d27:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0104d2a:	0f 83 97 00 00 00    	jae    c0104dc7 <page_init+0x395>
                begin = ROUNDUP(begin, PGSIZE);
c0104d30:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c0104d37:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104d3a:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104d3d:	01 d0                	add    %edx,%eax
c0104d3f:	48                   	dec    %eax
c0104d40:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0104d43:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104d46:	ba 00 00 00 00       	mov    $0x0,%edx
c0104d4b:	f7 75 b0             	divl   -0x50(%ebp)
c0104d4e:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104d51:	29 d0                	sub    %edx,%eax
c0104d53:	ba 00 00 00 00       	mov    $0x0,%edx
c0104d58:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104d5b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0104d5e:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104d61:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0104d64:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104d67:	ba 00 00 00 00       	mov    $0x0,%edx
c0104d6c:	89 c7                	mov    %eax,%edi
c0104d6e:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c0104d74:	89 7d 80             	mov    %edi,-0x80(%ebp)
c0104d77:	89 d0                	mov    %edx,%eax
c0104d79:	83 e0 00             	and    $0x0,%eax
c0104d7c:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0104d7f:	8b 45 80             	mov    -0x80(%ebp),%eax
c0104d82:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104d85:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104d88:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c0104d8b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104d8e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104d91:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104d94:	89 d0                	mov    %edx,%eax
c0104d96:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0104d99:	73 2c                	jae    c0104dc7 <page_init+0x395>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0104d9b:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104d9e:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104da1:	2b 45 d0             	sub    -0x30(%ebp),%eax
c0104da4:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c0104da7:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0104dab:	c1 ea 0c             	shr    $0xc,%edx
c0104dae:	89 c3                	mov    %eax,%ebx
c0104db0:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104db3:	89 04 24             	mov    %eax,(%esp)
c0104db6:	e8 54 f8 ff ff       	call   c010460f <pa2page>
c0104dbb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104dbf:	89 04 24             	mov    %eax,(%esp)
c0104dc2:	e8 7a fb ff ff       	call   c0104941 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c0104dc7:	ff 45 dc             	incl   -0x24(%ebp)
c0104dca:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104dcd:	8b 00                	mov    (%eax),%eax
c0104dcf:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0104dd2:	0f 8c 9f fe ff ff    	jl     c0104c77 <page_init+0x245>
                }
            }
        }
    }
}
c0104dd8:	90                   	nop
c0104dd9:	90                   	nop
c0104dda:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0104de0:	5b                   	pop    %ebx
c0104de1:	5e                   	pop    %esi
c0104de2:	5f                   	pop    %edi
c0104de3:	5d                   	pop    %ebp
c0104de4:	c3                   	ret    

c0104de5 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0104de5:	55                   	push   %ebp
c0104de6:	89 e5                	mov    %esp,%ebp
c0104de8:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0104deb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104dee:	33 45 14             	xor    0x14(%ebp),%eax
c0104df1:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104df6:	85 c0                	test   %eax,%eax
c0104df8:	74 24                	je     c0104e1e <boot_map_segment+0x39>
c0104dfa:	c7 44 24 0c 5a 9d 10 	movl   $0xc0109d5a,0xc(%esp)
c0104e01:	c0 
c0104e02:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c0104e09:	c0 
c0104e0a:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
c0104e11:	00 
c0104e12:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0104e19:	e8 f0 be ff ff       	call   c0100d0e <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0104e1e:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0104e25:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104e28:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104e2d:	89 c2                	mov    %eax,%edx
c0104e2f:	8b 45 10             	mov    0x10(%ebp),%eax
c0104e32:	01 c2                	add    %eax,%edx
c0104e34:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e37:	01 d0                	add    %edx,%eax
c0104e39:	48                   	dec    %eax
c0104e3a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104e3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e40:	ba 00 00 00 00       	mov    $0x0,%edx
c0104e45:	f7 75 f0             	divl   -0x10(%ebp)
c0104e48:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e4b:	29 d0                	sub    %edx,%eax
c0104e4d:	c1 e8 0c             	shr    $0xc,%eax
c0104e50:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0104e53:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104e56:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104e59:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104e5c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104e61:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0104e64:	8b 45 14             	mov    0x14(%ebp),%eax
c0104e67:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104e6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104e6d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104e72:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0104e75:	eb 68                	jmp    c0104edf <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0104e77:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0104e7e:	00 
c0104e7f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104e82:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104e86:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e89:	89 04 24             	mov    %eax,(%esp)
c0104e8c:	e8 88 01 00 00       	call   c0105019 <get_pte>
c0104e91:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0104e94:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0104e98:	75 24                	jne    c0104ebe <boot_map_segment+0xd9>
c0104e9a:	c7 44 24 0c 86 9d 10 	movl   $0xc0109d86,0xc(%esp)
c0104ea1:	c0 
c0104ea2:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c0104ea9:	c0 
c0104eaa:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c0104eb1:	00 
c0104eb2:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0104eb9:	e8 50 be ff ff       	call   c0100d0e <__panic>
        *ptep = pa | PTE_P | perm;
c0104ebe:	8b 45 14             	mov    0x14(%ebp),%eax
c0104ec1:	0b 45 18             	or     0x18(%ebp),%eax
c0104ec4:	83 c8 01             	or     $0x1,%eax
c0104ec7:	89 c2                	mov    %eax,%edx
c0104ec9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104ecc:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0104ece:	ff 4d f4             	decl   -0xc(%ebp)
c0104ed1:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0104ed8:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0104edf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104ee3:	75 92                	jne    c0104e77 <boot_map_segment+0x92>
    }
}
c0104ee5:	90                   	nop
c0104ee6:	90                   	nop
c0104ee7:	89 ec                	mov    %ebp,%esp
c0104ee9:	5d                   	pop    %ebp
c0104eea:	c3                   	ret    

c0104eeb <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0104eeb:	55                   	push   %ebp
c0104eec:	89 e5                	mov    %esp,%ebp
c0104eee:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0104ef1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104ef8:	e8 66 fa ff ff       	call   c0104963 <alloc_pages>
c0104efd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0104f00:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104f04:	75 1c                	jne    c0104f22 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0104f06:	c7 44 24 08 93 9d 10 	movl   $0xc0109d93,0x8(%esp)
c0104f0d:	c0 
c0104f0e:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c0104f15:	00 
c0104f16:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0104f1d:	e8 ec bd ff ff       	call   c0100d0e <__panic>
    }
    return page2kva(p);
c0104f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f25:	89 04 24             	mov    %eax,(%esp)
c0104f28:	e8 2a f7 ff ff       	call   c0104657 <page2kva>
}
c0104f2d:	89 ec                	mov    %ebp,%esp
c0104f2f:	5d                   	pop    %ebp
c0104f30:	c3                   	ret    

c0104f31 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0104f31:	55                   	push   %ebp
c0104f32:	89 e5                	mov    %esp,%ebp
c0104f34:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0104f37:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0104f3c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104f3f:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0104f46:	77 23                	ja     c0104f6b <pmm_init+0x3a>
c0104f48:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f4b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104f4f:	c7 44 24 08 a8 9c 10 	movl   $0xc0109ca8,0x8(%esp)
c0104f56:	c0 
c0104f57:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
c0104f5e:	00 
c0104f5f:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0104f66:	e8 a3 bd ff ff       	call   c0100d0e <__panic>
c0104f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f6e:	05 00 00 00 40       	add    $0x40000000,%eax
c0104f73:	a3 a8 6f 12 c0       	mov    %eax,0xc0126fa8
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0104f78:	e8 8e f9 ff ff       	call   c010490b <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0104f7d:	e8 b0 fa ff ff       	call   c0104a32 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0104f82:	e8 1e 05 00 00       	call   c01054a5 <check_alloc_page>

    check_pgdir();
c0104f87:	e8 3a 05 00 00       	call   c01054c6 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0104f8c:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0104f91:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104f94:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0104f9b:	77 23                	ja     c0104fc0 <pmm_init+0x8f>
c0104f9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104fa0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104fa4:	c7 44 24 08 a8 9c 10 	movl   $0xc0109ca8,0x8(%esp)
c0104fab:	c0 
c0104fac:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
c0104fb3:	00 
c0104fb4:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0104fbb:	e8 4e bd ff ff       	call   c0100d0e <__panic>
c0104fc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104fc3:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0104fc9:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0104fce:	05 ac 0f 00 00       	add    $0xfac,%eax
c0104fd3:	83 ca 03             	or     $0x3,%edx
c0104fd6:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0104fd8:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0104fdd:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0104fe4:	00 
c0104fe5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104fec:	00 
c0104fed:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0104ff4:	38 
c0104ff5:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0104ffc:	c0 
c0104ffd:	89 04 24             	mov    %eax,(%esp)
c0105000:	e8 e0 fd ff ff       	call   c0104de5 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0105005:	e8 15 f8 ff ff       	call   c010481f <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c010500a:	e8 55 0b 00 00       	call   c0105b64 <check_boot_pgdir>

    print_pgdir();
c010500f:	e8 d2 0f 00 00       	call   c0105fe6 <print_pgdir>

}
c0105014:	90                   	nop
c0105015:	89 ec                	mov    %ebp,%esp
c0105017:	5d                   	pop    %ebp
c0105018:	c3                   	ret    

c0105019 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0105019:	55                   	push   %ebp
c010501a:	89 e5                	mov    %esp,%ebp
c010501c:	83 ec 38             	sub    $0x38,%esp
    }
    return NULL;          // (8) return page table entry
#endif

    
    pde_t *pdep=pgdir+PDX(la);
c010501f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105022:	c1 e8 16             	shr    $0x16,%eax
c0105025:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010502c:	8b 45 08             	mov    0x8(%ebp),%eax
c010502f:	01 d0                	add    %edx,%eax
c0105031:	89 45 f4             	mov    %eax,-0xc(%ebp)

    pte_t *ptep=((pte_t*)KADDR(*pdep& ~0xfff))+PTX(la);
c0105034:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105037:	8b 00                	mov    (%eax),%eax
c0105039:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010503e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105041:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105044:	c1 e8 0c             	shr    $0xc,%eax
c0105047:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010504a:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c010504f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0105052:	72 23                	jb     c0105077 <get_pte+0x5e>
c0105054:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105057:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010505b:	c7 44 24 08 84 9c 10 	movl   $0xc0109c84,0x8(%esp)
c0105062:	c0 
c0105063:	c7 44 24 04 7b 01 00 	movl   $0x17b,0x4(%esp)
c010506a:	00 
c010506b:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0105072:	e8 97 bc ff ff       	call   c0100d0e <__panic>
c0105077:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010507a:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010507f:	89 c2                	mov    %eax,%edx
c0105081:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105084:	c1 e8 0c             	shr    $0xc,%eax
c0105087:	25 ff 03 00 00       	and    $0x3ff,%eax
c010508c:	c1 e0 02             	shl    $0x2,%eax
c010508f:	01 d0                	add    %edx,%eax
c0105091:	89 45 e8             	mov    %eax,-0x18(%ebp)

    if(*pdep & PTE_P) return ptep;
c0105094:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105097:	8b 00                	mov    (%eax),%eax
c0105099:	83 e0 01             	and    $0x1,%eax
c010509c:	85 c0                	test   %eax,%eax
c010509e:	74 08                	je     c01050a8 <get_pte+0x8f>
c01050a0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01050a3:	e9 dd 00 00 00       	jmp    c0105185 <get_pte+0x16c>
    
    if (!create) return NULL;
c01050a8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01050ac:	75 0a                	jne    c01050b8 <get_pte+0x9f>
c01050ae:	b8 00 00 00 00       	mov    $0x0,%eax
c01050b3:	e9 cd 00 00 00       	jmp    c0105185 <get_pte+0x16c>

   struct Page *p=alloc_page();
c01050b8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01050bf:	e8 9f f8 ff ff       	call   c0104963 <alloc_pages>
c01050c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
   if(p==NULL) return NULL;
c01050c7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01050cb:	75 0a                	jne    c01050d7 <get_pte+0xbe>
c01050cd:	b8 00 00 00 00       	mov    $0x0,%eax
c01050d2:	e9 ae 00 00 00       	jmp    c0105185 <get_pte+0x16c>

   set_page_ref(p,1);
c01050d7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01050de:	00 
c01050df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01050e2:	89 04 24             	mov    %eax,(%esp)
c01050e5:	e8 73 f6 ff ff       	call   c010475d <set_page_ref>

   ptep= KADDR(page2pa(p));
c01050ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01050ed:	89 04 24             	mov    %eax,(%esp)
c01050f0:	e8 02 f5 ff ff       	call   c01045f7 <page2pa>
c01050f5:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01050f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01050fb:	c1 e8 0c             	shr    $0xc,%eax
c01050fe:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105101:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c0105106:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0105109:	72 23                	jb     c010512e <get_pte+0x115>
c010510b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010510e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105112:	c7 44 24 08 84 9c 10 	movl   $0xc0109c84,0x8(%esp)
c0105119:	c0 
c010511a:	c7 44 24 04 86 01 00 	movl   $0x186,0x4(%esp)
c0105121:	00 
c0105122:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0105129:	e8 e0 bb ff ff       	call   c0100d0e <__panic>
c010512e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105131:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105136:	89 45 e8             	mov    %eax,-0x18(%ebp)

   memset(ptep,0,PGSIZE);
c0105139:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105140:	00 
c0105141:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105148:	00 
c0105149:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010514c:	89 04 24             	mov    %eax,(%esp)
c010514f:	e8 8d 3c 00 00       	call   c0108de1 <memset>

   //更改原来的页目录项
   *pdep=(page2pa(p)&~0xfff)|PTE_U|PTE_P|PTE_W;
c0105154:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105157:	89 04 24             	mov    %eax,(%esp)
c010515a:	e8 98 f4 ff ff       	call   c01045f7 <page2pa>
c010515f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105164:	83 c8 07             	or     $0x7,%eax
c0105167:	89 c2                	mov    %eax,%edx
c0105169:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010516c:	89 10                	mov    %edx,(%eax)

   return ptep+PTX(la);
c010516e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105171:	c1 e8 0c             	shr    $0xc,%eax
c0105174:	25 ff 03 00 00       	and    $0x3ff,%eax
c0105179:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105180:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105183:	01 d0                	add    %edx,%eax
        *pdep = pa | PTE_U | PTE_W | PTE_P;
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];*/


}
c0105185:	89 ec                	mov    %ebp,%esp
c0105187:	5d                   	pop    %ebp
c0105188:	c3                   	ret    

c0105189 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0105189:	55                   	push   %ebp
c010518a:	89 e5                	mov    %esp,%ebp
c010518c:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c010518f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105196:	00 
c0105197:	8b 45 0c             	mov    0xc(%ebp),%eax
c010519a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010519e:	8b 45 08             	mov    0x8(%ebp),%eax
c01051a1:	89 04 24             	mov    %eax,(%esp)
c01051a4:	e8 70 fe ff ff       	call   c0105019 <get_pte>
c01051a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c01051ac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01051b0:	74 08                	je     c01051ba <get_page+0x31>
        *ptep_store = ptep;
c01051b2:	8b 45 10             	mov    0x10(%ebp),%eax
c01051b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01051b8:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c01051ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01051be:	74 1b                	je     c01051db <get_page+0x52>
c01051c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051c3:	8b 00                	mov    (%eax),%eax
c01051c5:	83 e0 01             	and    $0x1,%eax
c01051c8:	85 c0                	test   %eax,%eax
c01051ca:	74 0f                	je     c01051db <get_page+0x52>
        return pte2page(*ptep);
c01051cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051cf:	8b 00                	mov    (%eax),%eax
c01051d1:	89 04 24             	mov    %eax,(%esp)
c01051d4:	e8 20 f5 ff ff       	call   c01046f9 <pte2page>
c01051d9:	eb 05                	jmp    c01051e0 <get_page+0x57>
    }
    return NULL;
c01051db:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01051e0:	89 ec                	mov    %ebp,%esp
c01051e2:	5d                   	pop    %ebp
c01051e3:	c3                   	ret    

c01051e4 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c01051e4:	55                   	push   %ebp
c01051e5:	89 e5                	mov    %esp,%ebp
c01051e7:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    assert(*ptep & PTE_P);
c01051ea:	8b 45 10             	mov    0x10(%ebp),%eax
c01051ed:	8b 00                	mov    (%eax),%eax
c01051ef:	83 e0 01             	and    $0x1,%eax
c01051f2:	85 c0                	test   %eax,%eax
c01051f4:	75 24                	jne    c010521a <page_remove_pte+0x36>
c01051f6:	c7 44 24 0c ac 9d 10 	movl   $0xc0109dac,0xc(%esp)
c01051fd:	c0 
c01051fe:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c0105205:	c0 
c0105206:	c7 44 24 04 ca 01 00 	movl   $0x1ca,0x4(%esp)
c010520d:	00 
c010520e:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0105215:	e8 f4 ba ff ff       	call   c0100d0e <__panic>
    struct Page *p=pte2page(*ptep);
c010521a:	8b 45 10             	mov    0x10(%ebp),%eax
c010521d:	8b 00                	mov    (%eax),%eax
c010521f:	89 04 24             	mov    %eax,(%esp)
c0105222:	e8 d2 f4 ff ff       	call   c01046f9 <pte2page>
c0105227:	89 45 f4             	mov    %eax,-0xc(%ebp)
    page_ref_dec(p);
c010522a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010522d:	89 04 24             	mov    %eax,(%esp)
c0105230:	e8 4d f5 ff ff       	call   c0104782 <page_ref_dec>
    if(p->ref==0)
c0105235:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105238:	8b 00                	mov    (%eax),%eax
c010523a:	85 c0                	test   %eax,%eax
c010523c:	75 13                	jne    c0105251 <page_remove_pte+0x6d>
    {
        free_page(p);
c010523e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105245:	00 
c0105246:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105249:	89 04 24             	mov    %eax,(%esp)
c010524c:	e8 7f f7 ff ff       	call   c01049d0 <free_pages>
    }
    *ptep&=~(PTE_P);
c0105251:	8b 45 10             	mov    0x10(%ebp),%eax
c0105254:	8b 00                	mov    (%eax),%eax
c0105256:	83 e0 fe             	and    $0xfffffffe,%eax
c0105259:	89 c2                	mov    %eax,%edx
c010525b:	8b 45 10             	mov    0x10(%ebp),%eax
c010525e:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir,la);
c0105260:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105263:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105267:	8b 45 08             	mov    0x8(%ebp),%eax
c010526a:	89 04 24             	mov    %eax,(%esp)
c010526d:	e8 07 01 00 00       	call   c0105379 <tlb_invalidate>
        *ptep = 0;
        tlb_invalidate(pgdir, la);
    }*/


}
c0105272:	90                   	nop
c0105273:	89 ec                	mov    %ebp,%esp
c0105275:	5d                   	pop    %ebp
c0105276:	c3                   	ret    

c0105277 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0105277:	55                   	push   %ebp
c0105278:	89 e5                	mov    %esp,%ebp
c010527a:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c010527d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105284:	00 
c0105285:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105288:	89 44 24 04          	mov    %eax,0x4(%esp)
c010528c:	8b 45 08             	mov    0x8(%ebp),%eax
c010528f:	89 04 24             	mov    %eax,(%esp)
c0105292:	e8 82 fd ff ff       	call   c0105019 <get_pte>
c0105297:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c010529a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010529e:	74 19                	je     c01052b9 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c01052a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052a3:	89 44 24 08          	mov    %eax,0x8(%esp)
c01052a7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01052aa:	89 44 24 04          	mov    %eax,0x4(%esp)
c01052ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01052b1:	89 04 24             	mov    %eax,(%esp)
c01052b4:	e8 2b ff ff ff       	call   c01051e4 <page_remove_pte>
    }
}
c01052b9:	90                   	nop
c01052ba:	89 ec                	mov    %ebp,%esp
c01052bc:	5d                   	pop    %ebp
c01052bd:	c3                   	ret    

c01052be <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c01052be:	55                   	push   %ebp
c01052bf:	89 e5                	mov    %esp,%ebp
c01052c1:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c01052c4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01052cb:	00 
c01052cc:	8b 45 10             	mov    0x10(%ebp),%eax
c01052cf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01052d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01052d6:	89 04 24             	mov    %eax,(%esp)
c01052d9:	e8 3b fd ff ff       	call   c0105019 <get_pte>
c01052de:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c01052e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01052e5:	75 0a                	jne    c01052f1 <page_insert+0x33>
        return -E_NO_MEM;
c01052e7:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01052ec:	e9 84 00 00 00       	jmp    c0105375 <page_insert+0xb7>
    }
    //对应物理页的引用次数+1
    page_ref_inc(page);
c01052f1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01052f4:	89 04 24             	mov    %eax,(%esp)
c01052f7:	e8 6f f4 ff ff       	call   c010476b <page_ref_inc>
    if (*ptep & PTE_P) {
c01052fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052ff:	8b 00                	mov    (%eax),%eax
c0105301:	83 e0 01             	and    $0x1,%eax
c0105304:	85 c0                	test   %eax,%eax
c0105306:	74 3e                	je     c0105346 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c0105308:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010530b:	8b 00                	mov    (%eax),%eax
c010530d:	89 04 24             	mov    %eax,(%esp)
c0105310:	e8 e4 f3 ff ff       	call   c01046f9 <pte2page>
c0105315:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0105318:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010531b:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010531e:	75 0d                	jne    c010532d <page_insert+0x6f>
            page_ref_dec(page);
c0105320:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105323:	89 04 24             	mov    %eax,(%esp)
c0105326:	e8 57 f4 ff ff       	call   c0104782 <page_ref_dec>
c010532b:	eb 19                	jmp    c0105346 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c010532d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105330:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105334:	8b 45 10             	mov    0x10(%ebp),%eax
c0105337:	89 44 24 04          	mov    %eax,0x4(%esp)
c010533b:	8b 45 08             	mov    0x8(%ebp),%eax
c010533e:	89 04 24             	mov    %eax,(%esp)
c0105341:	e8 9e fe ff ff       	call   c01051e4 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0105346:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105349:	89 04 24             	mov    %eax,(%esp)
c010534c:	e8 a6 f2 ff ff       	call   c01045f7 <page2pa>
c0105351:	0b 45 14             	or     0x14(%ebp),%eax
c0105354:	83 c8 01             	or     $0x1,%eax
c0105357:	89 c2                	mov    %eax,%edx
c0105359:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010535c:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c010535e:	8b 45 10             	mov    0x10(%ebp),%eax
c0105361:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105365:	8b 45 08             	mov    0x8(%ebp),%eax
c0105368:	89 04 24             	mov    %eax,(%esp)
c010536b:	e8 09 00 00 00       	call   c0105379 <tlb_invalidate>
    return 0;
c0105370:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105375:	89 ec                	mov    %ebp,%esp
c0105377:	5d                   	pop    %ebp
c0105378:	c3                   	ret    

c0105379 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0105379:	55                   	push   %ebp
c010537a:	89 e5                	mov    %esp,%ebp
c010537c:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c010537f:	0f 20 d8             	mov    %cr3,%eax
c0105382:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0105385:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c0105388:	8b 45 08             	mov    0x8(%ebp),%eax
c010538b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010538e:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0105395:	77 23                	ja     c01053ba <tlb_invalidate+0x41>
c0105397:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010539a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010539e:	c7 44 24 08 a8 9c 10 	movl   $0xc0109ca8,0x8(%esp)
c01053a5:	c0 
c01053a6:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
c01053ad:	00 
c01053ae:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c01053b5:	e8 54 b9 ff ff       	call   c0100d0e <__panic>
c01053ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053bd:	05 00 00 00 40       	add    $0x40000000,%eax
c01053c2:	39 d0                	cmp    %edx,%eax
c01053c4:	75 0d                	jne    c01053d3 <tlb_invalidate+0x5a>
        invlpg((void *)la);
c01053c6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01053c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c01053cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01053cf:	0f 01 38             	invlpg (%eax)
}
c01053d2:	90                   	nop
    }
}
c01053d3:	90                   	nop
c01053d4:	89 ec                	mov    %ebp,%esp
c01053d6:	5d                   	pop    %ebp
c01053d7:	c3                   	ret    

c01053d8 <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c01053d8:	55                   	push   %ebp
c01053d9:	89 e5                	mov    %esp,%ebp
c01053db:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c01053de:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01053e5:	e8 79 f5 ff ff       	call   c0104963 <alloc_pages>
c01053ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c01053ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01053f1:	0f 84 a7 00 00 00    	je     c010549e <pgdir_alloc_page+0xc6>
        if (page_insert(pgdir, page, la, perm) != 0) {
c01053f7:	8b 45 10             	mov    0x10(%ebp),%eax
c01053fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01053fe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105401:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105405:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105408:	89 44 24 04          	mov    %eax,0x4(%esp)
c010540c:	8b 45 08             	mov    0x8(%ebp),%eax
c010540f:	89 04 24             	mov    %eax,(%esp)
c0105412:	e8 a7 fe ff ff       	call   c01052be <page_insert>
c0105417:	85 c0                	test   %eax,%eax
c0105419:	74 1a                	je     c0105435 <pgdir_alloc_page+0x5d>
            free_page(page);
c010541b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105422:	00 
c0105423:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105426:	89 04 24             	mov    %eax,(%esp)
c0105429:	e8 a2 f5 ff ff       	call   c01049d0 <free_pages>
            return NULL;
c010542e:	b8 00 00 00 00       	mov    $0x0,%eax
c0105433:	eb 6c                	jmp    c01054a1 <pgdir_alloc_page+0xc9>
        }
        if (swap_init_ok){
c0105435:	a1 44 70 12 c0       	mov    0xc0127044,%eax
c010543a:	85 c0                	test   %eax,%eax
c010543c:	74 60                	je     c010549e <pgdir_alloc_page+0xc6>
            swap_map_swappable(check_mm_struct, la, page, 0);
c010543e:	a1 0c 71 12 c0       	mov    0xc012710c,%eax
c0105443:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010544a:	00 
c010544b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010544e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105452:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105455:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105459:	89 04 24             	mov    %eax,(%esp)
c010545c:	e8 79 0f 00 00       	call   c01063da <swap_map_swappable>
            page->pra_vaddr=la;
c0105461:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105464:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105467:	89 50 1c             	mov    %edx,0x1c(%eax)
            assert(page_ref(page) == 1);
c010546a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010546d:	89 04 24             	mov    %eax,(%esp)
c0105470:	e8 de f2 ff ff       	call   c0104753 <page_ref>
c0105475:	83 f8 01             	cmp    $0x1,%eax
c0105478:	74 24                	je     c010549e <pgdir_alloc_page+0xc6>
c010547a:	c7 44 24 0c ba 9d 10 	movl   $0xc0109dba,0xc(%esp)
c0105481:	c0 
c0105482:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c0105489:	c0 
c010548a:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
c0105491:	00 
c0105492:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0105499:	e8 70 b8 ff ff       	call   c0100d0e <__panic>
            //cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x, pra_link_next %x in pgdir_alloc_page\n", (page-pages), page->pra_vaddr,page->pra_page_link.prev, page->pra_page_link.next);
        }

    }

    return page;
c010549e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01054a1:	89 ec                	mov    %ebp,%esp
c01054a3:	5d                   	pop    %ebp
c01054a4:	c3                   	ret    

c01054a5 <check_alloc_page>:

static void
check_alloc_page(void) {
c01054a5:	55                   	push   %ebp
c01054a6:	89 e5                	mov    %esp,%ebp
c01054a8:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c01054ab:	a1 ac 6f 12 c0       	mov    0xc0126fac,%eax
c01054b0:	8b 40 18             	mov    0x18(%eax),%eax
c01054b3:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c01054b5:	c7 04 24 d0 9d 10 c0 	movl   $0xc0109dd0,(%esp)
c01054bc:	e8 a4 ae ff ff       	call   c0100365 <cprintf>
}
c01054c1:	90                   	nop
c01054c2:	89 ec                	mov    %ebp,%esp
c01054c4:	5d                   	pop    %ebp
c01054c5:	c3                   	ret    

c01054c6 <check_pgdir>:

static void
check_pgdir(void) {
c01054c6:	55                   	push   %ebp
c01054c7:	89 e5                	mov    %esp,%ebp
c01054c9:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c01054cc:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c01054d1:	3d 00 80 03 00       	cmp    $0x38000,%eax
c01054d6:	76 24                	jbe    c01054fc <check_pgdir+0x36>
c01054d8:	c7 44 24 0c ef 9d 10 	movl   $0xc0109def,0xc(%esp)
c01054df:	c0 
c01054e0:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c01054e7:	c0 
c01054e8:	c7 44 24 04 2e 02 00 	movl   $0x22e,0x4(%esp)
c01054ef:	00 
c01054f0:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c01054f7:	e8 12 b8 ff ff       	call   c0100d0e <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c01054fc:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105501:	85 c0                	test   %eax,%eax
c0105503:	74 0e                	je     c0105513 <check_pgdir+0x4d>
c0105505:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c010550a:	25 ff 0f 00 00       	and    $0xfff,%eax
c010550f:	85 c0                	test   %eax,%eax
c0105511:	74 24                	je     c0105537 <check_pgdir+0x71>
c0105513:	c7 44 24 0c 0c 9e 10 	movl   $0xc0109e0c,0xc(%esp)
c010551a:	c0 
c010551b:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c0105522:	c0 
c0105523:	c7 44 24 04 2f 02 00 	movl   $0x22f,0x4(%esp)
c010552a:	00 
c010552b:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0105532:	e8 d7 b7 ff ff       	call   c0100d0e <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0105537:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c010553c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105543:	00 
c0105544:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010554b:	00 
c010554c:	89 04 24             	mov    %eax,(%esp)
c010554f:	e8 35 fc ff ff       	call   c0105189 <get_page>
c0105554:	85 c0                	test   %eax,%eax
c0105556:	74 24                	je     c010557c <check_pgdir+0xb6>
c0105558:	c7 44 24 0c 44 9e 10 	movl   $0xc0109e44,0xc(%esp)
c010555f:	c0 
c0105560:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c0105567:	c0 
c0105568:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
c010556f:	00 
c0105570:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0105577:	e8 92 b7 ff ff       	call   c0100d0e <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c010557c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105583:	e8 db f3 ff ff       	call   c0104963 <alloc_pages>
c0105588:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c010558b:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105590:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105597:	00 
c0105598:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010559f:	00 
c01055a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01055a3:	89 54 24 04          	mov    %edx,0x4(%esp)
c01055a7:	89 04 24             	mov    %eax,(%esp)
c01055aa:	e8 0f fd ff ff       	call   c01052be <page_insert>
c01055af:	85 c0                	test   %eax,%eax
c01055b1:	74 24                	je     c01055d7 <check_pgdir+0x111>
c01055b3:	c7 44 24 0c 6c 9e 10 	movl   $0xc0109e6c,0xc(%esp)
c01055ba:	c0 
c01055bb:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c01055c2:	c0 
c01055c3:	c7 44 24 04 34 02 00 	movl   $0x234,0x4(%esp)
c01055ca:	00 
c01055cb:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c01055d2:	e8 37 b7 ff ff       	call   c0100d0e <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c01055d7:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c01055dc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01055e3:	00 
c01055e4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01055eb:	00 
c01055ec:	89 04 24             	mov    %eax,(%esp)
c01055ef:	e8 25 fa ff ff       	call   c0105019 <get_pte>
c01055f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01055f7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01055fb:	75 24                	jne    c0105621 <check_pgdir+0x15b>
c01055fd:	c7 44 24 0c 98 9e 10 	movl   $0xc0109e98,0xc(%esp)
c0105604:	c0 
c0105605:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c010560c:	c0 
c010560d:	c7 44 24 04 37 02 00 	movl   $0x237,0x4(%esp)
c0105614:	00 
c0105615:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c010561c:	e8 ed b6 ff ff       	call   c0100d0e <__panic>
    assert(pte2page(*ptep) == p1);
c0105621:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105624:	8b 00                	mov    (%eax),%eax
c0105626:	89 04 24             	mov    %eax,(%esp)
c0105629:	e8 cb f0 ff ff       	call   c01046f9 <pte2page>
c010562e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0105631:	74 24                	je     c0105657 <check_pgdir+0x191>
c0105633:	c7 44 24 0c c5 9e 10 	movl   $0xc0109ec5,0xc(%esp)
c010563a:	c0 
c010563b:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c0105642:	c0 
c0105643:	c7 44 24 04 38 02 00 	movl   $0x238,0x4(%esp)
c010564a:	00 
c010564b:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0105652:	e8 b7 b6 ff ff       	call   c0100d0e <__panic>
    assert(page_ref(p1) == 1);
c0105657:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010565a:	89 04 24             	mov    %eax,(%esp)
c010565d:	e8 f1 f0 ff ff       	call   c0104753 <page_ref>
c0105662:	83 f8 01             	cmp    $0x1,%eax
c0105665:	74 24                	je     c010568b <check_pgdir+0x1c5>
c0105667:	c7 44 24 0c db 9e 10 	movl   $0xc0109edb,0xc(%esp)
c010566e:	c0 
c010566f:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c0105676:	c0 
c0105677:	c7 44 24 04 39 02 00 	movl   $0x239,0x4(%esp)
c010567e:	00 
c010567f:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0105686:	e8 83 b6 ff ff       	call   c0100d0e <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c010568b:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105690:	8b 00                	mov    (%eax),%eax
c0105692:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105697:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010569a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010569d:	c1 e8 0c             	shr    $0xc,%eax
c01056a0:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01056a3:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c01056a8:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01056ab:	72 23                	jb     c01056d0 <check_pgdir+0x20a>
c01056ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01056b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01056b4:	c7 44 24 08 84 9c 10 	movl   $0xc0109c84,0x8(%esp)
c01056bb:	c0 
c01056bc:	c7 44 24 04 3b 02 00 	movl   $0x23b,0x4(%esp)
c01056c3:	00 
c01056c4:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c01056cb:	e8 3e b6 ff ff       	call   c0100d0e <__panic>
c01056d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01056d3:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01056d8:	83 c0 04             	add    $0x4,%eax
c01056db:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c01056de:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c01056e3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01056ea:	00 
c01056eb:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01056f2:	00 
c01056f3:	89 04 24             	mov    %eax,(%esp)
c01056f6:	e8 1e f9 ff ff       	call   c0105019 <get_pte>
c01056fb:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01056fe:	74 24                	je     c0105724 <check_pgdir+0x25e>
c0105700:	c7 44 24 0c f0 9e 10 	movl   $0xc0109ef0,0xc(%esp)
c0105707:	c0 
c0105708:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c010570f:	c0 
c0105710:	c7 44 24 04 3c 02 00 	movl   $0x23c,0x4(%esp)
c0105717:	00 
c0105718:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c010571f:	e8 ea b5 ff ff       	call   c0100d0e <__panic>

    p2 = alloc_page();
c0105724:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010572b:	e8 33 f2 ff ff       	call   c0104963 <alloc_pages>
c0105730:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0105733:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105738:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c010573f:	00 
c0105740:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105747:	00 
c0105748:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010574b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010574f:	89 04 24             	mov    %eax,(%esp)
c0105752:	e8 67 fb ff ff       	call   c01052be <page_insert>
c0105757:	85 c0                	test   %eax,%eax
c0105759:	74 24                	je     c010577f <check_pgdir+0x2b9>
c010575b:	c7 44 24 0c 18 9f 10 	movl   $0xc0109f18,0xc(%esp)
c0105762:	c0 
c0105763:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c010576a:	c0 
c010576b:	c7 44 24 04 3f 02 00 	movl   $0x23f,0x4(%esp)
c0105772:	00 
c0105773:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c010577a:	e8 8f b5 ff ff       	call   c0100d0e <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c010577f:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105784:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010578b:	00 
c010578c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105793:	00 
c0105794:	89 04 24             	mov    %eax,(%esp)
c0105797:	e8 7d f8 ff ff       	call   c0105019 <get_pte>
c010579c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010579f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01057a3:	75 24                	jne    c01057c9 <check_pgdir+0x303>
c01057a5:	c7 44 24 0c 50 9f 10 	movl   $0xc0109f50,0xc(%esp)
c01057ac:	c0 
c01057ad:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c01057b4:	c0 
c01057b5:	c7 44 24 04 40 02 00 	movl   $0x240,0x4(%esp)
c01057bc:	00 
c01057bd:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c01057c4:	e8 45 b5 ff ff       	call   c0100d0e <__panic>
    assert(*ptep & PTE_U);
c01057c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057cc:	8b 00                	mov    (%eax),%eax
c01057ce:	83 e0 04             	and    $0x4,%eax
c01057d1:	85 c0                	test   %eax,%eax
c01057d3:	75 24                	jne    c01057f9 <check_pgdir+0x333>
c01057d5:	c7 44 24 0c 80 9f 10 	movl   $0xc0109f80,0xc(%esp)
c01057dc:	c0 
c01057dd:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c01057e4:	c0 
c01057e5:	c7 44 24 04 41 02 00 	movl   $0x241,0x4(%esp)
c01057ec:	00 
c01057ed:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c01057f4:	e8 15 b5 ff ff       	call   c0100d0e <__panic>
    assert(*ptep & PTE_W);
c01057f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057fc:	8b 00                	mov    (%eax),%eax
c01057fe:	83 e0 02             	and    $0x2,%eax
c0105801:	85 c0                	test   %eax,%eax
c0105803:	75 24                	jne    c0105829 <check_pgdir+0x363>
c0105805:	c7 44 24 0c 8e 9f 10 	movl   $0xc0109f8e,0xc(%esp)
c010580c:	c0 
c010580d:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c0105814:	c0 
c0105815:	c7 44 24 04 42 02 00 	movl   $0x242,0x4(%esp)
c010581c:	00 
c010581d:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0105824:	e8 e5 b4 ff ff       	call   c0100d0e <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0105829:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c010582e:	8b 00                	mov    (%eax),%eax
c0105830:	83 e0 04             	and    $0x4,%eax
c0105833:	85 c0                	test   %eax,%eax
c0105835:	75 24                	jne    c010585b <check_pgdir+0x395>
c0105837:	c7 44 24 0c 9c 9f 10 	movl   $0xc0109f9c,0xc(%esp)
c010583e:	c0 
c010583f:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c0105846:	c0 
c0105847:	c7 44 24 04 43 02 00 	movl   $0x243,0x4(%esp)
c010584e:	00 
c010584f:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0105856:	e8 b3 b4 ff ff       	call   c0100d0e <__panic>
    assert(page_ref(p2) == 1);
c010585b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010585e:	89 04 24             	mov    %eax,(%esp)
c0105861:	e8 ed ee ff ff       	call   c0104753 <page_ref>
c0105866:	83 f8 01             	cmp    $0x1,%eax
c0105869:	74 24                	je     c010588f <check_pgdir+0x3c9>
c010586b:	c7 44 24 0c b2 9f 10 	movl   $0xc0109fb2,0xc(%esp)
c0105872:	c0 
c0105873:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c010587a:	c0 
c010587b:	c7 44 24 04 44 02 00 	movl   $0x244,0x4(%esp)
c0105882:	00 
c0105883:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c010588a:	e8 7f b4 ff ff       	call   c0100d0e <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c010588f:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105894:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010589b:	00 
c010589c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01058a3:	00 
c01058a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01058a7:	89 54 24 04          	mov    %edx,0x4(%esp)
c01058ab:	89 04 24             	mov    %eax,(%esp)
c01058ae:	e8 0b fa ff ff       	call   c01052be <page_insert>
c01058b3:	85 c0                	test   %eax,%eax
c01058b5:	74 24                	je     c01058db <check_pgdir+0x415>
c01058b7:	c7 44 24 0c c4 9f 10 	movl   $0xc0109fc4,0xc(%esp)
c01058be:	c0 
c01058bf:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c01058c6:	c0 
c01058c7:	c7 44 24 04 46 02 00 	movl   $0x246,0x4(%esp)
c01058ce:	00 
c01058cf:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c01058d6:	e8 33 b4 ff ff       	call   c0100d0e <__panic>
    assert(page_ref(p1) == 2);
c01058db:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058de:	89 04 24             	mov    %eax,(%esp)
c01058e1:	e8 6d ee ff ff       	call   c0104753 <page_ref>
c01058e6:	83 f8 02             	cmp    $0x2,%eax
c01058e9:	74 24                	je     c010590f <check_pgdir+0x449>
c01058eb:	c7 44 24 0c f0 9f 10 	movl   $0xc0109ff0,0xc(%esp)
c01058f2:	c0 
c01058f3:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c01058fa:	c0 
c01058fb:	c7 44 24 04 47 02 00 	movl   $0x247,0x4(%esp)
c0105902:	00 
c0105903:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c010590a:	e8 ff b3 ff ff       	call   c0100d0e <__panic>
    assert(page_ref(p2) == 0);
c010590f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105912:	89 04 24             	mov    %eax,(%esp)
c0105915:	e8 39 ee ff ff       	call   c0104753 <page_ref>
c010591a:	85 c0                	test   %eax,%eax
c010591c:	74 24                	je     c0105942 <check_pgdir+0x47c>
c010591e:	c7 44 24 0c 02 a0 10 	movl   $0xc010a002,0xc(%esp)
c0105925:	c0 
c0105926:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c010592d:	c0 
c010592e:	c7 44 24 04 48 02 00 	movl   $0x248,0x4(%esp)
c0105935:	00 
c0105936:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c010593d:	e8 cc b3 ff ff       	call   c0100d0e <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0105942:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105947:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010594e:	00 
c010594f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105956:	00 
c0105957:	89 04 24             	mov    %eax,(%esp)
c010595a:	e8 ba f6 ff ff       	call   c0105019 <get_pte>
c010595f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105962:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105966:	75 24                	jne    c010598c <check_pgdir+0x4c6>
c0105968:	c7 44 24 0c 50 9f 10 	movl   $0xc0109f50,0xc(%esp)
c010596f:	c0 
c0105970:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c0105977:	c0 
c0105978:	c7 44 24 04 49 02 00 	movl   $0x249,0x4(%esp)
c010597f:	00 
c0105980:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0105987:	e8 82 b3 ff ff       	call   c0100d0e <__panic>
    assert(pte2page(*ptep) == p1);
c010598c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010598f:	8b 00                	mov    (%eax),%eax
c0105991:	89 04 24             	mov    %eax,(%esp)
c0105994:	e8 60 ed ff ff       	call   c01046f9 <pte2page>
c0105999:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010599c:	74 24                	je     c01059c2 <check_pgdir+0x4fc>
c010599e:	c7 44 24 0c c5 9e 10 	movl   $0xc0109ec5,0xc(%esp)
c01059a5:	c0 
c01059a6:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c01059ad:	c0 
c01059ae:	c7 44 24 04 4a 02 00 	movl   $0x24a,0x4(%esp)
c01059b5:	00 
c01059b6:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c01059bd:	e8 4c b3 ff ff       	call   c0100d0e <__panic>
    assert((*ptep & PTE_U) == 0);
c01059c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059c5:	8b 00                	mov    (%eax),%eax
c01059c7:	83 e0 04             	and    $0x4,%eax
c01059ca:	85 c0                	test   %eax,%eax
c01059cc:	74 24                	je     c01059f2 <check_pgdir+0x52c>
c01059ce:	c7 44 24 0c 14 a0 10 	movl   $0xc010a014,0xc(%esp)
c01059d5:	c0 
c01059d6:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c01059dd:	c0 
c01059de:	c7 44 24 04 4b 02 00 	movl   $0x24b,0x4(%esp)
c01059e5:	00 
c01059e6:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c01059ed:	e8 1c b3 ff ff       	call   c0100d0e <__panic>

    page_remove(boot_pgdir, 0x0);
c01059f2:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c01059f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01059fe:	00 
c01059ff:	89 04 24             	mov    %eax,(%esp)
c0105a02:	e8 70 f8 ff ff       	call   c0105277 <page_remove>
    assert(page_ref(p1) == 1);
c0105a07:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a0a:	89 04 24             	mov    %eax,(%esp)
c0105a0d:	e8 41 ed ff ff       	call   c0104753 <page_ref>
c0105a12:	83 f8 01             	cmp    $0x1,%eax
c0105a15:	74 24                	je     c0105a3b <check_pgdir+0x575>
c0105a17:	c7 44 24 0c db 9e 10 	movl   $0xc0109edb,0xc(%esp)
c0105a1e:	c0 
c0105a1f:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c0105a26:	c0 
c0105a27:	c7 44 24 04 4e 02 00 	movl   $0x24e,0x4(%esp)
c0105a2e:	00 
c0105a2f:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0105a36:	e8 d3 b2 ff ff       	call   c0100d0e <__panic>
    assert(page_ref(p2) == 0);
c0105a3b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105a3e:	89 04 24             	mov    %eax,(%esp)
c0105a41:	e8 0d ed ff ff       	call   c0104753 <page_ref>
c0105a46:	85 c0                	test   %eax,%eax
c0105a48:	74 24                	je     c0105a6e <check_pgdir+0x5a8>
c0105a4a:	c7 44 24 0c 02 a0 10 	movl   $0xc010a002,0xc(%esp)
c0105a51:	c0 
c0105a52:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c0105a59:	c0 
c0105a5a:	c7 44 24 04 4f 02 00 	movl   $0x24f,0x4(%esp)
c0105a61:	00 
c0105a62:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0105a69:	e8 a0 b2 ff ff       	call   c0100d0e <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0105a6e:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105a73:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105a7a:	00 
c0105a7b:	89 04 24             	mov    %eax,(%esp)
c0105a7e:	e8 f4 f7 ff ff       	call   c0105277 <page_remove>
    assert(page_ref(p1) == 0);
c0105a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a86:	89 04 24             	mov    %eax,(%esp)
c0105a89:	e8 c5 ec ff ff       	call   c0104753 <page_ref>
c0105a8e:	85 c0                	test   %eax,%eax
c0105a90:	74 24                	je     c0105ab6 <check_pgdir+0x5f0>
c0105a92:	c7 44 24 0c 29 a0 10 	movl   $0xc010a029,0xc(%esp)
c0105a99:	c0 
c0105a9a:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c0105aa1:	c0 
c0105aa2:	c7 44 24 04 52 02 00 	movl   $0x252,0x4(%esp)
c0105aa9:	00 
c0105aaa:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0105ab1:	e8 58 b2 ff ff       	call   c0100d0e <__panic>
    assert(page_ref(p2) == 0);
c0105ab6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105ab9:	89 04 24             	mov    %eax,(%esp)
c0105abc:	e8 92 ec ff ff       	call   c0104753 <page_ref>
c0105ac1:	85 c0                	test   %eax,%eax
c0105ac3:	74 24                	je     c0105ae9 <check_pgdir+0x623>
c0105ac5:	c7 44 24 0c 02 a0 10 	movl   $0xc010a002,0xc(%esp)
c0105acc:	c0 
c0105acd:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c0105ad4:	c0 
c0105ad5:	c7 44 24 04 53 02 00 	movl   $0x253,0x4(%esp)
c0105adc:	00 
c0105add:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0105ae4:	e8 25 b2 ff ff       	call   c0100d0e <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0105ae9:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105aee:	8b 00                	mov    (%eax),%eax
c0105af0:	89 04 24             	mov    %eax,(%esp)
c0105af3:	e8 41 ec ff ff       	call   c0104739 <pde2page>
c0105af8:	89 04 24             	mov    %eax,(%esp)
c0105afb:	e8 53 ec ff ff       	call   c0104753 <page_ref>
c0105b00:	83 f8 01             	cmp    $0x1,%eax
c0105b03:	74 24                	je     c0105b29 <check_pgdir+0x663>
c0105b05:	c7 44 24 0c 3c a0 10 	movl   $0xc010a03c,0xc(%esp)
c0105b0c:	c0 
c0105b0d:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c0105b14:	c0 
c0105b15:	c7 44 24 04 55 02 00 	movl   $0x255,0x4(%esp)
c0105b1c:	00 
c0105b1d:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0105b24:	e8 e5 b1 ff ff       	call   c0100d0e <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0105b29:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105b2e:	8b 00                	mov    (%eax),%eax
c0105b30:	89 04 24             	mov    %eax,(%esp)
c0105b33:	e8 01 ec ff ff       	call   c0104739 <pde2page>
c0105b38:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105b3f:	00 
c0105b40:	89 04 24             	mov    %eax,(%esp)
c0105b43:	e8 88 ee ff ff       	call   c01049d0 <free_pages>
    boot_pgdir[0] = 0;
c0105b48:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105b4d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0105b53:	c7 04 24 63 a0 10 c0 	movl   $0xc010a063,(%esp)
c0105b5a:	e8 06 a8 ff ff       	call   c0100365 <cprintf>
}
c0105b5f:	90                   	nop
c0105b60:	89 ec                	mov    %ebp,%esp
c0105b62:	5d                   	pop    %ebp
c0105b63:	c3                   	ret    

c0105b64 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0105b64:	55                   	push   %ebp
c0105b65:	89 e5                	mov    %esp,%ebp
c0105b67:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0105b6a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105b71:	e9 ca 00 00 00       	jmp    c0105c40 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0105b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b79:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105b7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105b7f:	c1 e8 0c             	shr    $0xc,%eax
c0105b82:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105b85:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c0105b8a:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0105b8d:	72 23                	jb     c0105bb2 <check_boot_pgdir+0x4e>
c0105b8f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105b92:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105b96:	c7 44 24 08 84 9c 10 	movl   $0xc0109c84,0x8(%esp)
c0105b9d:	c0 
c0105b9e:	c7 44 24 04 61 02 00 	movl   $0x261,0x4(%esp)
c0105ba5:	00 
c0105ba6:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0105bad:	e8 5c b1 ff ff       	call   c0100d0e <__panic>
c0105bb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105bb5:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105bba:	89 c2                	mov    %eax,%edx
c0105bbc:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105bc1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105bc8:	00 
c0105bc9:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105bcd:	89 04 24             	mov    %eax,(%esp)
c0105bd0:	e8 44 f4 ff ff       	call   c0105019 <get_pte>
c0105bd5:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105bd8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105bdc:	75 24                	jne    c0105c02 <check_boot_pgdir+0x9e>
c0105bde:	c7 44 24 0c 80 a0 10 	movl   $0xc010a080,0xc(%esp)
c0105be5:	c0 
c0105be6:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c0105bed:	c0 
c0105bee:	c7 44 24 04 61 02 00 	movl   $0x261,0x4(%esp)
c0105bf5:	00 
c0105bf6:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0105bfd:	e8 0c b1 ff ff       	call   c0100d0e <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0105c02:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105c05:	8b 00                	mov    (%eax),%eax
c0105c07:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105c0c:	89 c2                	mov    %eax,%edx
c0105c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c11:	39 c2                	cmp    %eax,%edx
c0105c13:	74 24                	je     c0105c39 <check_boot_pgdir+0xd5>
c0105c15:	c7 44 24 0c bd a0 10 	movl   $0xc010a0bd,0xc(%esp)
c0105c1c:	c0 
c0105c1d:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c0105c24:	c0 
c0105c25:	c7 44 24 04 62 02 00 	movl   $0x262,0x4(%esp)
c0105c2c:	00 
c0105c2d:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0105c34:	e8 d5 b0 ff ff       	call   c0100d0e <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c0105c39:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0105c40:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105c43:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c0105c48:	39 c2                	cmp    %eax,%edx
c0105c4a:	0f 82 26 ff ff ff    	jb     c0105b76 <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0105c50:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105c55:	05 ac 0f 00 00       	add    $0xfac,%eax
c0105c5a:	8b 00                	mov    (%eax),%eax
c0105c5c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105c61:	89 c2                	mov    %eax,%edx
c0105c63:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105c68:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105c6b:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0105c72:	77 23                	ja     c0105c97 <check_boot_pgdir+0x133>
c0105c74:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c77:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105c7b:	c7 44 24 08 a8 9c 10 	movl   $0xc0109ca8,0x8(%esp)
c0105c82:	c0 
c0105c83:	c7 44 24 04 65 02 00 	movl   $0x265,0x4(%esp)
c0105c8a:	00 
c0105c8b:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0105c92:	e8 77 b0 ff ff       	call   c0100d0e <__panic>
c0105c97:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c9a:	05 00 00 00 40       	add    $0x40000000,%eax
c0105c9f:	39 d0                	cmp    %edx,%eax
c0105ca1:	74 24                	je     c0105cc7 <check_boot_pgdir+0x163>
c0105ca3:	c7 44 24 0c d4 a0 10 	movl   $0xc010a0d4,0xc(%esp)
c0105caa:	c0 
c0105cab:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c0105cb2:	c0 
c0105cb3:	c7 44 24 04 65 02 00 	movl   $0x265,0x4(%esp)
c0105cba:	00 
c0105cbb:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0105cc2:	e8 47 b0 ff ff       	call   c0100d0e <__panic>

    assert(boot_pgdir[0] == 0);
c0105cc7:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105ccc:	8b 00                	mov    (%eax),%eax
c0105cce:	85 c0                	test   %eax,%eax
c0105cd0:	74 24                	je     c0105cf6 <check_boot_pgdir+0x192>
c0105cd2:	c7 44 24 0c 08 a1 10 	movl   $0xc010a108,0xc(%esp)
c0105cd9:	c0 
c0105cda:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c0105ce1:	c0 
c0105ce2:	c7 44 24 04 67 02 00 	movl   $0x267,0x4(%esp)
c0105ce9:	00 
c0105cea:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0105cf1:	e8 18 b0 ff ff       	call   c0100d0e <__panic>

    struct Page *p;
    p = alloc_page();
c0105cf6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105cfd:	e8 61 ec ff ff       	call   c0104963 <alloc_pages>
c0105d02:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0105d05:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105d0a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0105d11:	00 
c0105d12:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0105d19:	00 
c0105d1a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105d1d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105d21:	89 04 24             	mov    %eax,(%esp)
c0105d24:	e8 95 f5 ff ff       	call   c01052be <page_insert>
c0105d29:	85 c0                	test   %eax,%eax
c0105d2b:	74 24                	je     c0105d51 <check_boot_pgdir+0x1ed>
c0105d2d:	c7 44 24 0c 1c a1 10 	movl   $0xc010a11c,0xc(%esp)
c0105d34:	c0 
c0105d35:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c0105d3c:	c0 
c0105d3d:	c7 44 24 04 6b 02 00 	movl   $0x26b,0x4(%esp)
c0105d44:	00 
c0105d45:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0105d4c:	e8 bd af ff ff       	call   c0100d0e <__panic>
    assert(page_ref(p) == 1);
c0105d51:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105d54:	89 04 24             	mov    %eax,(%esp)
c0105d57:	e8 f7 e9 ff ff       	call   c0104753 <page_ref>
c0105d5c:	83 f8 01             	cmp    $0x1,%eax
c0105d5f:	74 24                	je     c0105d85 <check_boot_pgdir+0x221>
c0105d61:	c7 44 24 0c 4a a1 10 	movl   $0xc010a14a,0xc(%esp)
c0105d68:	c0 
c0105d69:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c0105d70:	c0 
c0105d71:	c7 44 24 04 6c 02 00 	movl   $0x26c,0x4(%esp)
c0105d78:	00 
c0105d79:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0105d80:	e8 89 af ff ff       	call   c0100d0e <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0105d85:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105d8a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0105d91:	00 
c0105d92:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0105d99:	00 
c0105d9a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105d9d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105da1:	89 04 24             	mov    %eax,(%esp)
c0105da4:	e8 15 f5 ff ff       	call   c01052be <page_insert>
c0105da9:	85 c0                	test   %eax,%eax
c0105dab:	74 24                	je     c0105dd1 <check_boot_pgdir+0x26d>
c0105dad:	c7 44 24 0c 5c a1 10 	movl   $0xc010a15c,0xc(%esp)
c0105db4:	c0 
c0105db5:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c0105dbc:	c0 
c0105dbd:	c7 44 24 04 6d 02 00 	movl   $0x26d,0x4(%esp)
c0105dc4:	00 
c0105dc5:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0105dcc:	e8 3d af ff ff       	call   c0100d0e <__panic>
    assert(page_ref(p) == 2);
c0105dd1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105dd4:	89 04 24             	mov    %eax,(%esp)
c0105dd7:	e8 77 e9 ff ff       	call   c0104753 <page_ref>
c0105ddc:	83 f8 02             	cmp    $0x2,%eax
c0105ddf:	74 24                	je     c0105e05 <check_boot_pgdir+0x2a1>
c0105de1:	c7 44 24 0c 93 a1 10 	movl   $0xc010a193,0xc(%esp)
c0105de8:	c0 
c0105de9:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c0105df0:	c0 
c0105df1:	c7 44 24 04 6e 02 00 	movl   $0x26e,0x4(%esp)
c0105df8:	00 
c0105df9:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0105e00:	e8 09 af ff ff       	call   c0100d0e <__panic>

    const char *str = "ucore: Hello world!!";
c0105e05:	c7 45 e8 a4 a1 10 c0 	movl   $0xc010a1a4,-0x18(%ebp)
    strcpy((void *)0x100, str);
c0105e0c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105e0f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e13:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105e1a:	e8 f2 2c 00 00       	call   c0108b11 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0105e1f:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0105e26:	00 
c0105e27:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105e2e:	e8 56 2d 00 00       	call   c0108b89 <strcmp>
c0105e33:	85 c0                	test   %eax,%eax
c0105e35:	74 24                	je     c0105e5b <check_boot_pgdir+0x2f7>
c0105e37:	c7 44 24 0c bc a1 10 	movl   $0xc010a1bc,0xc(%esp)
c0105e3e:	c0 
c0105e3f:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c0105e46:	c0 
c0105e47:	c7 44 24 04 72 02 00 	movl   $0x272,0x4(%esp)
c0105e4e:	00 
c0105e4f:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0105e56:	e8 b3 ae ff ff       	call   c0100d0e <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0105e5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e5e:	89 04 24             	mov    %eax,(%esp)
c0105e61:	e8 f1 e7 ff ff       	call   c0104657 <page2kva>
c0105e66:	05 00 01 00 00       	add    $0x100,%eax
c0105e6b:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0105e6e:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105e75:	e8 3d 2c 00 00       	call   c0108ab7 <strlen>
c0105e7a:	85 c0                	test   %eax,%eax
c0105e7c:	74 24                	je     c0105ea2 <check_boot_pgdir+0x33e>
c0105e7e:	c7 44 24 0c f4 a1 10 	movl   $0xc010a1f4,0xc(%esp)
c0105e85:	c0 
c0105e86:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c0105e8d:	c0 
c0105e8e:	c7 44 24 04 75 02 00 	movl   $0x275,0x4(%esp)
c0105e95:	00 
c0105e96:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0105e9d:	e8 6c ae ff ff       	call   c0100d0e <__panic>

    free_page(p);
c0105ea2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105ea9:	00 
c0105eaa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105ead:	89 04 24             	mov    %eax,(%esp)
c0105eb0:	e8 1b eb ff ff       	call   c01049d0 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0105eb5:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105eba:	8b 00                	mov    (%eax),%eax
c0105ebc:	89 04 24             	mov    %eax,(%esp)
c0105ebf:	e8 75 e8 ff ff       	call   c0104739 <pde2page>
c0105ec4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105ecb:	00 
c0105ecc:	89 04 24             	mov    %eax,(%esp)
c0105ecf:	e8 fc ea ff ff       	call   c01049d0 <free_pages>
    boot_pgdir[0] = 0;
c0105ed4:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105ed9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0105edf:	c7 04 24 18 a2 10 c0 	movl   $0xc010a218,(%esp)
c0105ee6:	e8 7a a4 ff ff       	call   c0100365 <cprintf>
}
c0105eeb:	90                   	nop
c0105eec:	89 ec                	mov    %ebp,%esp
c0105eee:	5d                   	pop    %ebp
c0105eef:	c3                   	ret    

c0105ef0 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0105ef0:	55                   	push   %ebp
c0105ef1:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0105ef3:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ef6:	83 e0 04             	and    $0x4,%eax
c0105ef9:	85 c0                	test   %eax,%eax
c0105efb:	74 04                	je     c0105f01 <perm2str+0x11>
c0105efd:	b0 75                	mov    $0x75,%al
c0105eff:	eb 02                	jmp    c0105f03 <perm2str+0x13>
c0105f01:	b0 2d                	mov    $0x2d,%al
c0105f03:	a2 28 70 12 c0       	mov    %al,0xc0127028
    str[1] = 'r';
c0105f08:	c6 05 29 70 12 c0 72 	movb   $0x72,0xc0127029
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0105f0f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f12:	83 e0 02             	and    $0x2,%eax
c0105f15:	85 c0                	test   %eax,%eax
c0105f17:	74 04                	je     c0105f1d <perm2str+0x2d>
c0105f19:	b0 77                	mov    $0x77,%al
c0105f1b:	eb 02                	jmp    c0105f1f <perm2str+0x2f>
c0105f1d:	b0 2d                	mov    $0x2d,%al
c0105f1f:	a2 2a 70 12 c0       	mov    %al,0xc012702a
    str[3] = '\0';
c0105f24:	c6 05 2b 70 12 c0 00 	movb   $0x0,0xc012702b
    return str;
c0105f2b:	b8 28 70 12 c0       	mov    $0xc0127028,%eax
}
c0105f30:	5d                   	pop    %ebp
c0105f31:	c3                   	ret    

c0105f32 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0105f32:	55                   	push   %ebp
c0105f33:	89 e5                	mov    %esp,%ebp
c0105f35:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0105f38:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f3b:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105f3e:	72 0d                	jb     c0105f4d <get_pgtable_items+0x1b>
        return 0;
c0105f40:	b8 00 00 00 00       	mov    $0x0,%eax
c0105f45:	e9 98 00 00 00       	jmp    c0105fe2 <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c0105f4a:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c0105f4d:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f50:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105f53:	73 18                	jae    c0105f6d <get_pgtable_items+0x3b>
c0105f55:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f58:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105f5f:	8b 45 14             	mov    0x14(%ebp),%eax
c0105f62:	01 d0                	add    %edx,%eax
c0105f64:	8b 00                	mov    (%eax),%eax
c0105f66:	83 e0 01             	and    $0x1,%eax
c0105f69:	85 c0                	test   %eax,%eax
c0105f6b:	74 dd                	je     c0105f4a <get_pgtable_items+0x18>
    }
    if (start < right) {
c0105f6d:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f70:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105f73:	73 68                	jae    c0105fdd <get_pgtable_items+0xab>
        if (left_store != NULL) {
c0105f75:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0105f79:	74 08                	je     c0105f83 <get_pgtable_items+0x51>
            *left_store = start;
c0105f7b:	8b 45 18             	mov    0x18(%ebp),%eax
c0105f7e:	8b 55 10             	mov    0x10(%ebp),%edx
c0105f81:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0105f83:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f86:	8d 50 01             	lea    0x1(%eax),%edx
c0105f89:	89 55 10             	mov    %edx,0x10(%ebp)
c0105f8c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105f93:	8b 45 14             	mov    0x14(%ebp),%eax
c0105f96:	01 d0                	add    %edx,%eax
c0105f98:	8b 00                	mov    (%eax),%eax
c0105f9a:	83 e0 07             	and    $0x7,%eax
c0105f9d:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0105fa0:	eb 03                	jmp    c0105fa5 <get_pgtable_items+0x73>
            start ++;
c0105fa2:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0105fa5:	8b 45 10             	mov    0x10(%ebp),%eax
c0105fa8:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105fab:	73 1d                	jae    c0105fca <get_pgtable_items+0x98>
c0105fad:	8b 45 10             	mov    0x10(%ebp),%eax
c0105fb0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105fb7:	8b 45 14             	mov    0x14(%ebp),%eax
c0105fba:	01 d0                	add    %edx,%eax
c0105fbc:	8b 00                	mov    (%eax),%eax
c0105fbe:	83 e0 07             	and    $0x7,%eax
c0105fc1:	89 c2                	mov    %eax,%edx
c0105fc3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105fc6:	39 c2                	cmp    %eax,%edx
c0105fc8:	74 d8                	je     c0105fa2 <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
c0105fca:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105fce:	74 08                	je     c0105fd8 <get_pgtable_items+0xa6>
            *right_store = start;
c0105fd0:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105fd3:	8b 55 10             	mov    0x10(%ebp),%edx
c0105fd6:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0105fd8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105fdb:	eb 05                	jmp    c0105fe2 <get_pgtable_items+0xb0>
    }
    return 0;
c0105fdd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105fe2:	89 ec                	mov    %ebp,%esp
c0105fe4:	5d                   	pop    %ebp
c0105fe5:	c3                   	ret    

c0105fe6 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0105fe6:	55                   	push   %ebp
c0105fe7:	89 e5                	mov    %esp,%ebp
c0105fe9:	57                   	push   %edi
c0105fea:	56                   	push   %esi
c0105feb:	53                   	push   %ebx
c0105fec:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0105fef:	c7 04 24 38 a2 10 c0 	movl   $0xc010a238,(%esp)
c0105ff6:	e8 6a a3 ff ff       	call   c0100365 <cprintf>
    size_t left, right = 0, perm;
c0105ffb:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0106002:	e9 f2 00 00 00       	jmp    c01060f9 <print_pgdir+0x113>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0106007:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010600a:	89 04 24             	mov    %eax,(%esp)
c010600d:	e8 de fe ff ff       	call   c0105ef0 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0106012:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106015:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0106018:	29 ca                	sub    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010601a:	89 d6                	mov    %edx,%esi
c010601c:	c1 e6 16             	shl    $0x16,%esi
c010601f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106022:	89 d3                	mov    %edx,%ebx
c0106024:	c1 e3 16             	shl    $0x16,%ebx
c0106027:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010602a:	89 d1                	mov    %edx,%ecx
c010602c:	c1 e1 16             	shl    $0x16,%ecx
c010602f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106032:	8b 7d e0             	mov    -0x20(%ebp),%edi
c0106035:	29 fa                	sub    %edi,%edx
c0106037:	89 44 24 14          	mov    %eax,0x14(%esp)
c010603b:	89 74 24 10          	mov    %esi,0x10(%esp)
c010603f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0106043:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0106047:	89 54 24 04          	mov    %edx,0x4(%esp)
c010604b:	c7 04 24 69 a2 10 c0 	movl   $0xc010a269,(%esp)
c0106052:	e8 0e a3 ff ff       	call   c0100365 <cprintf>
        size_t l, r = left * NPTEENTRY;
c0106057:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010605a:	c1 e0 0a             	shl    $0xa,%eax
c010605d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0106060:	eb 50                	jmp    c01060b2 <print_pgdir+0xcc>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0106062:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106065:	89 04 24             	mov    %eax,(%esp)
c0106068:	e8 83 fe ff ff       	call   c0105ef0 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c010606d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106070:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c0106073:	29 ca                	sub    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0106075:	89 d6                	mov    %edx,%esi
c0106077:	c1 e6 0c             	shl    $0xc,%esi
c010607a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010607d:	89 d3                	mov    %edx,%ebx
c010607f:	c1 e3 0c             	shl    $0xc,%ebx
c0106082:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106085:	89 d1                	mov    %edx,%ecx
c0106087:	c1 e1 0c             	shl    $0xc,%ecx
c010608a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010608d:	8b 7d d8             	mov    -0x28(%ebp),%edi
c0106090:	29 fa                	sub    %edi,%edx
c0106092:	89 44 24 14          	mov    %eax,0x14(%esp)
c0106096:	89 74 24 10          	mov    %esi,0x10(%esp)
c010609a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010609e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01060a2:	89 54 24 04          	mov    %edx,0x4(%esp)
c01060a6:	c7 04 24 88 a2 10 c0 	movl   $0xc010a288,(%esp)
c01060ad:	e8 b3 a2 ff ff       	call   c0100365 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01060b2:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c01060b7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01060ba:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01060bd:	89 d3                	mov    %edx,%ebx
c01060bf:	c1 e3 0a             	shl    $0xa,%ebx
c01060c2:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01060c5:	89 d1                	mov    %edx,%ecx
c01060c7:	c1 e1 0a             	shl    $0xa,%ecx
c01060ca:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c01060cd:	89 54 24 14          	mov    %edx,0x14(%esp)
c01060d1:	8d 55 d8             	lea    -0x28(%ebp),%edx
c01060d4:	89 54 24 10          	mov    %edx,0x10(%esp)
c01060d8:	89 74 24 0c          	mov    %esi,0xc(%esp)
c01060dc:	89 44 24 08          	mov    %eax,0x8(%esp)
c01060e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01060e4:	89 0c 24             	mov    %ecx,(%esp)
c01060e7:	e8 46 fe ff ff       	call   c0105f32 <get_pgtable_items>
c01060ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01060ef:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01060f3:	0f 85 69 ff ff ff    	jne    c0106062 <print_pgdir+0x7c>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c01060f9:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c01060fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106101:	8d 55 dc             	lea    -0x24(%ebp),%edx
c0106104:	89 54 24 14          	mov    %edx,0x14(%esp)
c0106108:	8d 55 e0             	lea    -0x20(%ebp),%edx
c010610b:	89 54 24 10          	mov    %edx,0x10(%esp)
c010610f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0106113:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106117:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c010611e:	00 
c010611f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0106126:	e8 07 fe ff ff       	call   c0105f32 <get_pgtable_items>
c010612b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010612e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106132:	0f 85 cf fe ff ff    	jne    c0106007 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0106138:	c7 04 24 ac a2 10 c0 	movl   $0xc010a2ac,(%esp)
c010613f:	e8 21 a2 ff ff       	call   c0100365 <cprintf>
}
c0106144:	90                   	nop
c0106145:	83 c4 4c             	add    $0x4c,%esp
c0106148:	5b                   	pop    %ebx
c0106149:	5e                   	pop    %esi
c010614a:	5f                   	pop    %edi
c010614b:	5d                   	pop    %ebp
c010614c:	c3                   	ret    

c010614d <kmalloc>:

void *
kmalloc(size_t n) {
c010614d:	55                   	push   %ebp
c010614e:	89 e5                	mov    %esp,%ebp
c0106150:	83 ec 28             	sub    $0x28,%esp
    void * ptr=NULL;
c0106153:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    struct Page *base=NULL;
c010615a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    assert(n > 0 && n < 1024*0124);
c0106161:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0106165:	74 09                	je     c0106170 <kmalloc+0x23>
c0106167:	81 7d 08 ff 4f 01 00 	cmpl   $0x14fff,0x8(%ebp)
c010616e:	76 24                	jbe    c0106194 <kmalloc+0x47>
c0106170:	c7 44 24 0c dd a2 10 	movl   $0xc010a2dd,0xc(%esp)
c0106177:	c0 
c0106178:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c010617f:	c0 
c0106180:	c7 44 24 04 c1 02 00 	movl   $0x2c1,0x4(%esp)
c0106187:	00 
c0106188:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c010618f:	e8 7a ab ff ff       	call   c0100d0e <__panic>
    int num_pages=(n+PGSIZE-1)/PGSIZE;
c0106194:	8b 45 08             	mov    0x8(%ebp),%eax
c0106197:	05 ff 0f 00 00       	add    $0xfff,%eax
c010619c:	c1 e8 0c             	shr    $0xc,%eax
c010619f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    base = alloc_pages(num_pages);
c01061a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01061a5:	89 04 24             	mov    %eax,(%esp)
c01061a8:	e8 b6 e7 ff ff       	call   c0104963 <alloc_pages>
c01061ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(base != NULL);
c01061b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01061b4:	75 24                	jne    c01061da <kmalloc+0x8d>
c01061b6:	c7 44 24 0c f4 a2 10 	movl   $0xc010a2f4,0xc(%esp)
c01061bd:	c0 
c01061be:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c01061c5:	c0 
c01061c6:	c7 44 24 04 c4 02 00 	movl   $0x2c4,0x4(%esp)
c01061cd:	00 
c01061ce:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c01061d5:	e8 34 ab ff ff       	call   c0100d0e <__panic>
    ptr=page2kva(base);
c01061da:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01061dd:	89 04 24             	mov    %eax,(%esp)
c01061e0:	e8 72 e4 ff ff       	call   c0104657 <page2kva>
c01061e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ptr;
c01061e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01061eb:	89 ec                	mov    %ebp,%esp
c01061ed:	5d                   	pop    %ebp
c01061ee:	c3                   	ret    

c01061ef <kfree>:

void 
kfree(void *ptr, size_t n) {
c01061ef:	55                   	push   %ebp
c01061f0:	89 e5                	mov    %esp,%ebp
c01061f2:	83 ec 28             	sub    $0x28,%esp
    assert(n > 0 && n < 1024*0124);
c01061f5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01061f9:	74 09                	je     c0106204 <kfree+0x15>
c01061fb:	81 7d 0c ff 4f 01 00 	cmpl   $0x14fff,0xc(%ebp)
c0106202:	76 24                	jbe    c0106228 <kfree+0x39>
c0106204:	c7 44 24 0c dd a2 10 	movl   $0xc010a2dd,0xc(%esp)
c010620b:	c0 
c010620c:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c0106213:	c0 
c0106214:	c7 44 24 04 cb 02 00 	movl   $0x2cb,0x4(%esp)
c010621b:	00 
c010621c:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c0106223:	e8 e6 aa ff ff       	call   c0100d0e <__panic>
    assert(ptr != NULL);
c0106228:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010622c:	75 24                	jne    c0106252 <kfree+0x63>
c010622e:	c7 44 24 0c 01 a3 10 	movl   $0xc010a301,0xc(%esp)
c0106235:	c0 
c0106236:	c7 44 24 08 71 9d 10 	movl   $0xc0109d71,0x8(%esp)
c010623d:	c0 
c010623e:	c7 44 24 04 cc 02 00 	movl   $0x2cc,0x4(%esp)
c0106245:	00 
c0106246:	c7 04 24 4c 9d 10 c0 	movl   $0xc0109d4c,(%esp)
c010624d:	e8 bc aa ff ff       	call   c0100d0e <__panic>
    struct Page *base=NULL;
c0106252:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    int num_pages=(n+PGSIZE-1)/PGSIZE;
c0106259:	8b 45 0c             	mov    0xc(%ebp),%eax
c010625c:	05 ff 0f 00 00       	add    $0xfff,%eax
c0106261:	c1 e8 0c             	shr    $0xc,%eax
c0106264:	89 45 f0             	mov    %eax,-0x10(%ebp)
    base = kva2page(ptr);
c0106267:	8b 45 08             	mov    0x8(%ebp),%eax
c010626a:	89 04 24             	mov    %eax,(%esp)
c010626d:	e8 3b e4 ff ff       	call   c01046ad <kva2page>
c0106272:	89 45 f4             	mov    %eax,-0xc(%ebp)
    free_pages(base, num_pages);
c0106275:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106278:	89 44 24 04          	mov    %eax,0x4(%esp)
c010627c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010627f:	89 04 24             	mov    %eax,(%esp)
c0106282:	e8 49 e7 ff ff       	call   c01049d0 <free_pages>
}
c0106287:	90                   	nop
c0106288:	89 ec                	mov    %ebp,%esp
c010628a:	5d                   	pop    %ebp
c010628b:	c3                   	ret    

c010628c <pa2page>:
pa2page(uintptr_t pa) {
c010628c:	55                   	push   %ebp
c010628d:	89 e5                	mov    %esp,%ebp
c010628f:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0106292:	8b 45 08             	mov    0x8(%ebp),%eax
c0106295:	c1 e8 0c             	shr    $0xc,%eax
c0106298:	89 c2                	mov    %eax,%edx
c010629a:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c010629f:	39 c2                	cmp    %eax,%edx
c01062a1:	72 1c                	jb     c01062bf <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01062a3:	c7 44 24 08 10 a3 10 	movl   $0xc010a310,0x8(%esp)
c01062aa:	c0 
c01062ab:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c01062b2:	00 
c01062b3:	c7 04 24 2f a3 10 c0 	movl   $0xc010a32f,(%esp)
c01062ba:	e8 4f aa ff ff       	call   c0100d0e <__panic>
    return &pages[PPN(pa)];
c01062bf:	8b 15 a0 6f 12 c0    	mov    0xc0126fa0,%edx
c01062c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01062c8:	c1 e8 0c             	shr    $0xc,%eax
c01062cb:	c1 e0 05             	shl    $0x5,%eax
c01062ce:	01 d0                	add    %edx,%eax
}
c01062d0:	89 ec                	mov    %ebp,%esp
c01062d2:	5d                   	pop    %ebp
c01062d3:	c3                   	ret    

c01062d4 <pte2page>:
pte2page(pte_t pte) {
c01062d4:	55                   	push   %ebp
c01062d5:	89 e5                	mov    %esp,%ebp
c01062d7:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c01062da:	8b 45 08             	mov    0x8(%ebp),%eax
c01062dd:	83 e0 01             	and    $0x1,%eax
c01062e0:	85 c0                	test   %eax,%eax
c01062e2:	75 1c                	jne    c0106300 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c01062e4:	c7 44 24 08 40 a3 10 	movl   $0xc010a340,0x8(%esp)
c01062eb:	c0 
c01062ec:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c01062f3:	00 
c01062f4:	c7 04 24 2f a3 10 c0 	movl   $0xc010a32f,(%esp)
c01062fb:	e8 0e aa ff ff       	call   c0100d0e <__panic>
    return pa2page(PTE_ADDR(pte));
c0106300:	8b 45 08             	mov    0x8(%ebp),%eax
c0106303:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106308:	89 04 24             	mov    %eax,(%esp)
c010630b:	e8 7c ff ff ff       	call   c010628c <pa2page>
}
c0106310:	89 ec                	mov    %ebp,%esp
c0106312:	5d                   	pop    %ebp
c0106313:	c3                   	ret    

c0106314 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c0106314:	55                   	push   %ebp
c0106315:	89 e5                	mov    %esp,%ebp
c0106317:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c010631a:	e8 19 1f 00 00       	call   c0108238 <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c010631f:	a1 40 70 12 c0       	mov    0xc0127040,%eax
c0106324:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c0106329:	76 0c                	jbe    c0106337 <swap_init+0x23>
c010632b:	a1 40 70 12 c0       	mov    0xc0127040,%eax
c0106330:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c0106335:	76 25                	jbe    c010635c <swap_init+0x48>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c0106337:	a1 40 70 12 c0       	mov    0xc0127040,%eax
c010633c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106340:	c7 44 24 08 61 a3 10 	movl   $0xc010a361,0x8(%esp)
c0106347:	c0 
c0106348:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
c010634f:	00 
c0106350:	c7 04 24 7c a3 10 c0 	movl   $0xc010a37c,(%esp)
c0106357:	e8 b2 a9 ff ff       	call   c0100d0e <__panic>
     }
     

     sm = &swap_manager_fifo;
c010635c:	c7 05 00 71 12 c0 40 	movl   $0xc0123a40,0xc0127100
c0106363:	3a 12 c0 
     
     int r = sm->init();
c0106366:	a1 00 71 12 c0       	mov    0xc0127100,%eax
c010636b:	8b 40 04             	mov    0x4(%eax),%eax
c010636e:	ff d0                	call   *%eax
c0106370:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c0106373:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106377:	75 26                	jne    c010639f <swap_init+0x8b>
     {
          swap_init_ok = 1;
c0106379:	c7 05 44 70 12 c0 01 	movl   $0x1,0xc0127044
c0106380:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c0106383:	a1 00 71 12 c0       	mov    0xc0127100,%eax
c0106388:	8b 00                	mov    (%eax),%eax
c010638a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010638e:	c7 04 24 8b a3 10 c0 	movl   $0xc010a38b,(%esp)
c0106395:	e8 cb 9f ff ff       	call   c0100365 <cprintf>
          check_swap();
c010639a:	e8 b0 04 00 00       	call   c010684f <check_swap>
     }

     return r;
c010639f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01063a2:	89 ec                	mov    %ebp,%esp
c01063a4:	5d                   	pop    %ebp
c01063a5:	c3                   	ret    

c01063a6 <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c01063a6:	55                   	push   %ebp
c01063a7:	89 e5                	mov    %esp,%ebp
c01063a9:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c01063ac:	a1 00 71 12 c0       	mov    0xc0127100,%eax
c01063b1:	8b 40 08             	mov    0x8(%eax),%eax
c01063b4:	8b 55 08             	mov    0x8(%ebp),%edx
c01063b7:	89 14 24             	mov    %edx,(%esp)
c01063ba:	ff d0                	call   *%eax
}
c01063bc:	89 ec                	mov    %ebp,%esp
c01063be:	5d                   	pop    %ebp
c01063bf:	c3                   	ret    

c01063c0 <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c01063c0:	55                   	push   %ebp
c01063c1:	89 e5                	mov    %esp,%ebp
c01063c3:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c01063c6:	a1 00 71 12 c0       	mov    0xc0127100,%eax
c01063cb:	8b 40 0c             	mov    0xc(%eax),%eax
c01063ce:	8b 55 08             	mov    0x8(%ebp),%edx
c01063d1:	89 14 24             	mov    %edx,(%esp)
c01063d4:	ff d0                	call   *%eax
}
c01063d6:	89 ec                	mov    %ebp,%esp
c01063d8:	5d                   	pop    %ebp
c01063d9:	c3                   	ret    

c01063da <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c01063da:	55                   	push   %ebp
c01063db:	89 e5                	mov    %esp,%ebp
c01063dd:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c01063e0:	a1 00 71 12 c0       	mov    0xc0127100,%eax
c01063e5:	8b 40 10             	mov    0x10(%eax),%eax
c01063e8:	8b 55 14             	mov    0x14(%ebp),%edx
c01063eb:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01063ef:	8b 55 10             	mov    0x10(%ebp),%edx
c01063f2:	89 54 24 08          	mov    %edx,0x8(%esp)
c01063f6:	8b 55 0c             	mov    0xc(%ebp),%edx
c01063f9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01063fd:	8b 55 08             	mov    0x8(%ebp),%edx
c0106400:	89 14 24             	mov    %edx,(%esp)
c0106403:	ff d0                	call   *%eax
}
c0106405:	89 ec                	mov    %ebp,%esp
c0106407:	5d                   	pop    %ebp
c0106408:	c3                   	ret    

c0106409 <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0106409:	55                   	push   %ebp
c010640a:	89 e5                	mov    %esp,%ebp
c010640c:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c010640f:	a1 00 71 12 c0       	mov    0xc0127100,%eax
c0106414:	8b 40 14             	mov    0x14(%eax),%eax
c0106417:	8b 55 0c             	mov    0xc(%ebp),%edx
c010641a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010641e:	8b 55 08             	mov    0x8(%ebp),%edx
c0106421:	89 14 24             	mov    %edx,(%esp)
c0106424:	ff d0                	call   *%eax
}
c0106426:	89 ec                	mov    %ebp,%esp
c0106428:	5d                   	pop    %ebp
c0106429:	c3                   	ret    

c010642a <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c010642a:	55                   	push   %ebp
c010642b:	89 e5                	mov    %esp,%ebp
c010642d:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c0106430:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106437:	e9 53 01 00 00       	jmp    c010658f <swap_out+0x165>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c010643c:	a1 00 71 12 c0       	mov    0xc0127100,%eax
c0106441:	8b 40 18             	mov    0x18(%eax),%eax
c0106444:	8b 55 10             	mov    0x10(%ebp),%edx
c0106447:	89 54 24 08          	mov    %edx,0x8(%esp)
c010644b:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c010644e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106452:	8b 55 08             	mov    0x8(%ebp),%edx
c0106455:	89 14 24             	mov    %edx,(%esp)
c0106458:	ff d0                	call   *%eax
c010645a:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c010645d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106461:	74 18                	je     c010647b <swap_out+0x51>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c0106463:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106466:	89 44 24 04          	mov    %eax,0x4(%esp)
c010646a:	c7 04 24 a0 a3 10 c0 	movl   $0xc010a3a0,(%esp)
c0106471:	e8 ef 9e ff ff       	call   c0100365 <cprintf>
c0106476:	e9 20 01 00 00       	jmp    c010659b <swap_out+0x171>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c010647b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010647e:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106481:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c0106484:	8b 45 08             	mov    0x8(%ebp),%eax
c0106487:	8b 40 0c             	mov    0xc(%eax),%eax
c010648a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106491:	00 
c0106492:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106495:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106499:	89 04 24             	mov    %eax,(%esp)
c010649c:	e8 78 eb ff ff       	call   c0105019 <get_pte>
c01064a1:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c01064a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01064a7:	8b 00                	mov    (%eax),%eax
c01064a9:	83 e0 01             	and    $0x1,%eax
c01064ac:	85 c0                	test   %eax,%eax
c01064ae:	75 24                	jne    c01064d4 <swap_out+0xaa>
c01064b0:	c7 44 24 0c cd a3 10 	movl   $0xc010a3cd,0xc(%esp)
c01064b7:	c0 
c01064b8:	c7 44 24 08 e2 a3 10 	movl   $0xc010a3e2,0x8(%esp)
c01064bf:	c0 
c01064c0:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c01064c7:	00 
c01064c8:	c7 04 24 7c a3 10 c0 	movl   $0xc010a37c,(%esp)
c01064cf:	e8 3a a8 ff ff       	call   c0100d0e <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c01064d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01064d7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01064da:	8b 52 1c             	mov    0x1c(%edx),%edx
c01064dd:	c1 ea 0c             	shr    $0xc,%edx
c01064e0:	42                   	inc    %edx
c01064e1:	c1 e2 08             	shl    $0x8,%edx
c01064e4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01064e8:	89 14 24             	mov    %edx,(%esp)
c01064eb:	e8 07 1e 00 00       	call   c01082f7 <swapfs_write>
c01064f0:	85 c0                	test   %eax,%eax
c01064f2:	74 34                	je     c0106528 <swap_out+0xfe>
                    cprintf("SWAP: failed to save\n");
c01064f4:	c7 04 24 f7 a3 10 c0 	movl   $0xc010a3f7,(%esp)
c01064fb:	e8 65 9e ff ff       	call   c0100365 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c0106500:	a1 00 71 12 c0       	mov    0xc0127100,%eax
c0106505:	8b 40 10             	mov    0x10(%eax),%eax
c0106508:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010650b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0106512:	00 
c0106513:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106517:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010651a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010651e:	8b 55 08             	mov    0x8(%ebp),%edx
c0106521:	89 14 24             	mov    %edx,(%esp)
c0106524:	ff d0                	call   *%eax
c0106526:	eb 64                	jmp    c010658c <swap_out+0x162>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c0106528:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010652b:	8b 40 1c             	mov    0x1c(%eax),%eax
c010652e:	c1 e8 0c             	shr    $0xc,%eax
c0106531:	40                   	inc    %eax
c0106532:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106536:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106539:	89 44 24 08          	mov    %eax,0x8(%esp)
c010653d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106540:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106544:	c7 04 24 10 a4 10 c0 	movl   $0xc010a410,(%esp)
c010654b:	e8 15 9e ff ff       	call   c0100365 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c0106550:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106553:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106556:	c1 e8 0c             	shr    $0xc,%eax
c0106559:	40                   	inc    %eax
c010655a:	c1 e0 08             	shl    $0x8,%eax
c010655d:	89 c2                	mov    %eax,%edx
c010655f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106562:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c0106564:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106567:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010656e:	00 
c010656f:	89 04 24             	mov    %eax,(%esp)
c0106572:	e8 59 e4 ff ff       	call   c01049d0 <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c0106577:	8b 45 08             	mov    0x8(%ebp),%eax
c010657a:	8b 40 0c             	mov    0xc(%eax),%eax
c010657d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106580:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106584:	89 04 24             	mov    %eax,(%esp)
c0106587:	e8 ed ed ff ff       	call   c0105379 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
c010658c:	ff 45 f4             	incl   -0xc(%ebp)
c010658f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106592:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106595:	0f 85 a1 fe ff ff    	jne    c010643c <swap_out+0x12>
     }
     return i;
c010659b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010659e:	89 ec                	mov    %ebp,%esp
c01065a0:	5d                   	pop    %ebp
c01065a1:	c3                   	ret    

c01065a2 <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c01065a2:	55                   	push   %ebp
c01065a3:	89 e5                	mov    %esp,%ebp
c01065a5:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c01065a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01065af:	e8 af e3 ff ff       	call   c0104963 <alloc_pages>
c01065b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c01065b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01065bb:	75 24                	jne    c01065e1 <swap_in+0x3f>
c01065bd:	c7 44 24 0c 50 a4 10 	movl   $0xc010a450,0xc(%esp)
c01065c4:	c0 
c01065c5:	c7 44 24 08 e2 a3 10 	movl   $0xc010a3e2,0x8(%esp)
c01065cc:	c0 
c01065cd:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c01065d4:	00 
c01065d5:	c7 04 24 7c a3 10 c0 	movl   $0xc010a37c,(%esp)
c01065dc:	e8 2d a7 ff ff       	call   c0100d0e <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c01065e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01065e4:	8b 40 0c             	mov    0xc(%eax),%eax
c01065e7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01065ee:	00 
c01065ef:	8b 55 0c             	mov    0xc(%ebp),%edx
c01065f2:	89 54 24 04          	mov    %edx,0x4(%esp)
c01065f6:	89 04 24             	mov    %eax,(%esp)
c01065f9:	e8 1b ea ff ff       	call   c0105019 <get_pte>
c01065fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c0106601:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106604:	8b 00                	mov    (%eax),%eax
c0106606:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106609:	89 54 24 04          	mov    %edx,0x4(%esp)
c010660d:	89 04 24             	mov    %eax,(%esp)
c0106610:	e8 6e 1c 00 00       	call   c0108283 <swapfs_read>
c0106615:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106618:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010661c:	74 2a                	je     c0106648 <swap_in+0xa6>
     {
        assert(r!=0);
c010661e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106622:	75 24                	jne    c0106648 <swap_in+0xa6>
c0106624:	c7 44 24 0c 5d a4 10 	movl   $0xc010a45d,0xc(%esp)
c010662b:	c0 
c010662c:	c7 44 24 08 e2 a3 10 	movl   $0xc010a3e2,0x8(%esp)
c0106633:	c0 
c0106634:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
c010663b:	00 
c010663c:	c7 04 24 7c a3 10 c0 	movl   $0xc010a37c,(%esp)
c0106643:	e8 c6 a6 ff ff       	call   c0100d0e <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c0106648:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010664b:	8b 00                	mov    (%eax),%eax
c010664d:	c1 e8 08             	shr    $0x8,%eax
c0106650:	89 c2                	mov    %eax,%edx
c0106652:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106655:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106659:	89 54 24 04          	mov    %edx,0x4(%esp)
c010665d:	c7 04 24 64 a4 10 c0 	movl   $0xc010a464,(%esp)
c0106664:	e8 fc 9c ff ff       	call   c0100365 <cprintf>
     *ptr_result=result;
c0106669:	8b 45 10             	mov    0x10(%ebp),%eax
c010666c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010666f:	89 10                	mov    %edx,(%eax)
     return 0;
c0106671:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106676:	89 ec                	mov    %ebp,%esp
c0106678:	5d                   	pop    %ebp
c0106679:	c3                   	ret    

c010667a <check_content_set>:



static inline void
check_content_set(void)
{
c010667a:	55                   	push   %ebp
c010667b:	89 e5                	mov    %esp,%ebp
c010667d:	83 ec 18             	sub    $0x18,%esp
     *(unsigned char *)0x1000 = 0x0a;
c0106680:	b8 00 10 00 00       	mov    $0x1000,%eax
c0106685:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0106688:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c010668d:	83 f8 01             	cmp    $0x1,%eax
c0106690:	74 24                	je     c01066b6 <check_content_set+0x3c>
c0106692:	c7 44 24 0c a2 a4 10 	movl   $0xc010a4a2,0xc(%esp)
c0106699:	c0 
c010669a:	c7 44 24 08 e2 a3 10 	movl   $0xc010a3e2,0x8(%esp)
c01066a1:	c0 
c01066a2:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
c01066a9:	00 
c01066aa:	c7 04 24 7c a3 10 c0 	movl   $0xc010a37c,(%esp)
c01066b1:	e8 58 a6 ff ff       	call   c0100d0e <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c01066b6:	b8 10 10 00 00       	mov    $0x1010,%eax
c01066bb:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c01066be:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c01066c3:	83 f8 01             	cmp    $0x1,%eax
c01066c6:	74 24                	je     c01066ec <check_content_set+0x72>
c01066c8:	c7 44 24 0c a2 a4 10 	movl   $0xc010a4a2,0xc(%esp)
c01066cf:	c0 
c01066d0:	c7 44 24 08 e2 a3 10 	movl   $0xc010a3e2,0x8(%esp)
c01066d7:	c0 
c01066d8:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c01066df:	00 
c01066e0:	c7 04 24 7c a3 10 c0 	movl   $0xc010a37c,(%esp)
c01066e7:	e8 22 a6 ff ff       	call   c0100d0e <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c01066ec:	b8 00 20 00 00       	mov    $0x2000,%eax
c01066f1:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c01066f4:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c01066f9:	83 f8 02             	cmp    $0x2,%eax
c01066fc:	74 24                	je     c0106722 <check_content_set+0xa8>
c01066fe:	c7 44 24 0c b1 a4 10 	movl   $0xc010a4b1,0xc(%esp)
c0106705:	c0 
c0106706:	c7 44 24 08 e2 a3 10 	movl   $0xc010a3e2,0x8(%esp)
c010670d:	c0 
c010670e:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c0106715:	00 
c0106716:	c7 04 24 7c a3 10 c0 	movl   $0xc010a37c,(%esp)
c010671d:	e8 ec a5 ff ff       	call   c0100d0e <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c0106722:	b8 10 20 00 00       	mov    $0x2010,%eax
c0106727:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c010672a:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c010672f:	83 f8 02             	cmp    $0x2,%eax
c0106732:	74 24                	je     c0106758 <check_content_set+0xde>
c0106734:	c7 44 24 0c b1 a4 10 	movl   $0xc010a4b1,0xc(%esp)
c010673b:	c0 
c010673c:	c7 44 24 08 e2 a3 10 	movl   $0xc010a3e2,0x8(%esp)
c0106743:	c0 
c0106744:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c010674b:	00 
c010674c:	c7 04 24 7c a3 10 c0 	movl   $0xc010a37c,(%esp)
c0106753:	e8 b6 a5 ff ff       	call   c0100d0e <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c0106758:	b8 00 30 00 00       	mov    $0x3000,%eax
c010675d:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0106760:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c0106765:	83 f8 03             	cmp    $0x3,%eax
c0106768:	74 24                	je     c010678e <check_content_set+0x114>
c010676a:	c7 44 24 0c c0 a4 10 	movl   $0xc010a4c0,0xc(%esp)
c0106771:	c0 
c0106772:	c7 44 24 08 e2 a3 10 	movl   $0xc010a3e2,0x8(%esp)
c0106779:	c0 
c010677a:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c0106781:	00 
c0106782:	c7 04 24 7c a3 10 c0 	movl   $0xc010a37c,(%esp)
c0106789:	e8 80 a5 ff ff       	call   c0100d0e <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c010678e:	b8 10 30 00 00       	mov    $0x3010,%eax
c0106793:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0106796:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c010679b:	83 f8 03             	cmp    $0x3,%eax
c010679e:	74 24                	je     c01067c4 <check_content_set+0x14a>
c01067a0:	c7 44 24 0c c0 a4 10 	movl   $0xc010a4c0,0xc(%esp)
c01067a7:	c0 
c01067a8:	c7 44 24 08 e2 a3 10 	movl   $0xc010a3e2,0x8(%esp)
c01067af:	c0 
c01067b0:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c01067b7:	00 
c01067b8:	c7 04 24 7c a3 10 c0 	movl   $0xc010a37c,(%esp)
c01067bf:	e8 4a a5 ff ff       	call   c0100d0e <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c01067c4:	b8 00 40 00 00       	mov    $0x4000,%eax
c01067c9:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c01067cc:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c01067d1:	83 f8 04             	cmp    $0x4,%eax
c01067d4:	74 24                	je     c01067fa <check_content_set+0x180>
c01067d6:	c7 44 24 0c cf a4 10 	movl   $0xc010a4cf,0xc(%esp)
c01067dd:	c0 
c01067de:	c7 44 24 08 e2 a3 10 	movl   $0xc010a3e2,0x8(%esp)
c01067e5:	c0 
c01067e6:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c01067ed:	00 
c01067ee:	c7 04 24 7c a3 10 c0 	movl   $0xc010a37c,(%esp)
c01067f5:	e8 14 a5 ff ff       	call   c0100d0e <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c01067fa:	b8 10 40 00 00       	mov    $0x4010,%eax
c01067ff:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0106802:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c0106807:	83 f8 04             	cmp    $0x4,%eax
c010680a:	74 24                	je     c0106830 <check_content_set+0x1b6>
c010680c:	c7 44 24 0c cf a4 10 	movl   $0xc010a4cf,0xc(%esp)
c0106813:	c0 
c0106814:	c7 44 24 08 e2 a3 10 	movl   $0xc010a3e2,0x8(%esp)
c010681b:	c0 
c010681c:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0106823:	00 
c0106824:	c7 04 24 7c a3 10 c0 	movl   $0xc010a37c,(%esp)
c010682b:	e8 de a4 ff ff       	call   c0100d0e <__panic>
}
c0106830:	90                   	nop
c0106831:	89 ec                	mov    %ebp,%esp
c0106833:	5d                   	pop    %ebp
c0106834:	c3                   	ret    

c0106835 <check_content_access>:

static inline int
check_content_access(void)
{
c0106835:	55                   	push   %ebp
c0106836:	89 e5                	mov    %esp,%ebp
c0106838:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c010683b:	a1 00 71 12 c0       	mov    0xc0127100,%eax
c0106840:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106843:	ff d0                	call   *%eax
c0106845:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c0106848:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010684b:	89 ec                	mov    %ebp,%esp
c010684d:	5d                   	pop    %ebp
c010684e:	c3                   	ret    

c010684f <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c010684f:	55                   	push   %ebp
c0106850:	89 e5                	mov    %esp,%ebp
c0106852:	83 ec 78             	sub    $0x78,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c0106855:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010685c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c0106863:	c7 45 e8 84 6f 12 c0 	movl   $0xc0126f84,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c010686a:	eb 6a                	jmp    c01068d6 <check_swap+0x87>
        struct Page *p = le2page(le, page_link);
c010686c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010686f:	83 e8 0c             	sub    $0xc,%eax
c0106872:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(PageProperty(p));
c0106875:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106878:	83 c0 04             	add    $0x4,%eax
c010687b:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0106882:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106885:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0106888:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010688b:	0f a3 10             	bt     %edx,(%eax)
c010688e:	19 c0                	sbb    %eax,%eax
c0106890:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c0106893:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0106897:	0f 95 c0             	setne  %al
c010689a:	0f b6 c0             	movzbl %al,%eax
c010689d:	85 c0                	test   %eax,%eax
c010689f:	75 24                	jne    c01068c5 <check_swap+0x76>
c01068a1:	c7 44 24 0c de a4 10 	movl   $0xc010a4de,0xc(%esp)
c01068a8:	c0 
c01068a9:	c7 44 24 08 e2 a3 10 	movl   $0xc010a3e2,0x8(%esp)
c01068b0:	c0 
c01068b1:	c7 44 24 04 bb 00 00 	movl   $0xbb,0x4(%esp)
c01068b8:	00 
c01068b9:	c7 04 24 7c a3 10 c0 	movl   $0xc010a37c,(%esp)
c01068c0:	e8 49 a4 ff ff       	call   c0100d0e <__panic>
        count ++, total += p->property;
c01068c5:	ff 45 f4             	incl   -0xc(%ebp)
c01068c8:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01068cb:	8b 50 08             	mov    0x8(%eax),%edx
c01068ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01068d1:	01 d0                	add    %edx,%eax
c01068d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01068d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01068d9:	89 45 b8             	mov    %eax,-0x48(%ebp)
c01068dc:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01068df:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c01068e2:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01068e5:	81 7d e8 84 6f 12 c0 	cmpl   $0xc0126f84,-0x18(%ebp)
c01068ec:	0f 85 7a ff ff ff    	jne    c010686c <check_swap+0x1d>
     }
     assert(total == nr_free_pages());
c01068f2:	e8 0e e1 ff ff       	call   c0104a05 <nr_free_pages>
c01068f7:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01068fa:	39 d0                	cmp    %edx,%eax
c01068fc:	74 24                	je     c0106922 <check_swap+0xd3>
c01068fe:	c7 44 24 0c ee a4 10 	movl   $0xc010a4ee,0xc(%esp)
c0106905:	c0 
c0106906:	c7 44 24 08 e2 a3 10 	movl   $0xc010a3e2,0x8(%esp)
c010690d:	c0 
c010690e:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
c0106915:	00 
c0106916:	c7 04 24 7c a3 10 c0 	movl   $0xc010a37c,(%esp)
c010691d:	e8 ec a3 ff ff       	call   c0100d0e <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c0106922:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106925:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106929:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010692c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106930:	c7 04 24 08 a5 10 c0 	movl   $0xc010a508,(%esp)
c0106937:	e8 29 9a ff ff       	call   c0100365 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c010693c:	e8 24 0b 00 00       	call   c0107465 <mm_create>
c0106941:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     assert(mm != NULL);
c0106944:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106948:	75 24                	jne    c010696e <check_swap+0x11f>
c010694a:	c7 44 24 0c 2e a5 10 	movl   $0xc010a52e,0xc(%esp)
c0106951:	c0 
c0106952:	c7 44 24 08 e2 a3 10 	movl   $0xc010a3e2,0x8(%esp)
c0106959:	c0 
c010695a:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
c0106961:	00 
c0106962:	c7 04 24 7c a3 10 c0 	movl   $0xc010a37c,(%esp)
c0106969:	e8 a0 a3 ff ff       	call   c0100d0e <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c010696e:	a1 0c 71 12 c0       	mov    0xc012710c,%eax
c0106973:	85 c0                	test   %eax,%eax
c0106975:	74 24                	je     c010699b <check_swap+0x14c>
c0106977:	c7 44 24 0c 39 a5 10 	movl   $0xc010a539,0xc(%esp)
c010697e:	c0 
c010697f:	c7 44 24 08 e2 a3 10 	movl   $0xc010a3e2,0x8(%esp)
c0106986:	c0 
c0106987:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c010698e:	00 
c010698f:	c7 04 24 7c a3 10 c0 	movl   $0xc010a37c,(%esp)
c0106996:	e8 73 a3 ff ff       	call   c0100d0e <__panic>

     check_mm_struct = mm;
c010699b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010699e:	a3 0c 71 12 c0       	mov    %eax,0xc012710c

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c01069a3:	8b 15 e0 39 12 c0    	mov    0xc01239e0,%edx
c01069a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01069ac:	89 50 0c             	mov    %edx,0xc(%eax)
c01069af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01069b2:	8b 40 0c             	mov    0xc(%eax),%eax
c01069b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(pgdir[0] == 0);
c01069b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01069bb:	8b 00                	mov    (%eax),%eax
c01069bd:	85 c0                	test   %eax,%eax
c01069bf:	74 24                	je     c01069e5 <check_swap+0x196>
c01069c1:	c7 44 24 0c 51 a5 10 	movl   $0xc010a551,0xc(%esp)
c01069c8:	c0 
c01069c9:	c7 44 24 08 e2 a3 10 	movl   $0xc010a3e2,0x8(%esp)
c01069d0:	c0 
c01069d1:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c01069d8:	00 
c01069d9:	c7 04 24 7c a3 10 c0 	movl   $0xc010a37c,(%esp)
c01069e0:	e8 29 a3 ff ff       	call   c0100d0e <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c01069e5:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c01069ec:	00 
c01069ed:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c01069f4:	00 
c01069f5:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c01069fc:	e8 df 0a 00 00       	call   c01074e0 <vma_create>
c0106a01:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(vma != NULL);
c0106a04:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0106a08:	75 24                	jne    c0106a2e <check_swap+0x1df>
c0106a0a:	c7 44 24 0c 5f a5 10 	movl   $0xc010a55f,0xc(%esp)
c0106a11:	c0 
c0106a12:	c7 44 24 08 e2 a3 10 	movl   $0xc010a3e2,0x8(%esp)
c0106a19:	c0 
c0106a1a:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0106a21:	00 
c0106a22:	c7 04 24 7c a3 10 c0 	movl   $0xc010a37c,(%esp)
c0106a29:	e8 e0 a2 ff ff       	call   c0100d0e <__panic>

     insert_vma_struct(mm, vma);
c0106a2e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106a31:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106a35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106a38:	89 04 24             	mov    %eax,(%esp)
c0106a3b:	e8 37 0c 00 00       	call   c0107677 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c0106a40:	c7 04 24 6c a5 10 c0 	movl   $0xc010a56c,(%esp)
c0106a47:	e8 19 99 ff ff       	call   c0100365 <cprintf>
     pte_t *temp_ptep=NULL;
c0106a4c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c0106a53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106a56:	8b 40 0c             	mov    0xc(%eax),%eax
c0106a59:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0106a60:	00 
c0106a61:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0106a68:	00 
c0106a69:	89 04 24             	mov    %eax,(%esp)
c0106a6c:	e8 a8 e5 ff ff       	call   c0105019 <get_pte>
c0106a71:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(temp_ptep!= NULL);
c0106a74:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0106a78:	75 24                	jne    c0106a9e <check_swap+0x24f>
c0106a7a:	c7 44 24 0c a0 a5 10 	movl   $0xc010a5a0,0xc(%esp)
c0106a81:	c0 
c0106a82:	c7 44 24 08 e2 a3 10 	movl   $0xc010a3e2,0x8(%esp)
c0106a89:	c0 
c0106a8a:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0106a91:	00 
c0106a92:	c7 04 24 7c a3 10 c0 	movl   $0xc010a37c,(%esp)
c0106a99:	e8 70 a2 ff ff       	call   c0100d0e <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c0106a9e:	c7 04 24 b4 a5 10 c0 	movl   $0xc010a5b4,(%esp)
c0106aa5:	e8 bb 98 ff ff       	call   c0100365 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106aaa:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106ab1:	e9 a2 00 00 00       	jmp    c0106b58 <check_swap+0x309>
          check_rp[i] = alloc_page();
c0106ab6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106abd:	e8 a1 de ff ff       	call   c0104963 <alloc_pages>
c0106ac2:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106ac5:	89 04 95 cc 70 12 c0 	mov    %eax,-0x3fed8f34(,%edx,4)
          assert(check_rp[i] != NULL );
c0106acc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106acf:	8b 04 85 cc 70 12 c0 	mov    -0x3fed8f34(,%eax,4),%eax
c0106ad6:	85 c0                	test   %eax,%eax
c0106ad8:	75 24                	jne    c0106afe <check_swap+0x2af>
c0106ada:	c7 44 24 0c d8 a5 10 	movl   $0xc010a5d8,0xc(%esp)
c0106ae1:	c0 
c0106ae2:	c7 44 24 08 e2 a3 10 	movl   $0xc010a3e2,0x8(%esp)
c0106ae9:	c0 
c0106aea:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c0106af1:	00 
c0106af2:	c7 04 24 7c a3 10 c0 	movl   $0xc010a37c,(%esp)
c0106af9:	e8 10 a2 ff ff       	call   c0100d0e <__panic>
          assert(!PageProperty(check_rp[i]));
c0106afe:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106b01:	8b 04 85 cc 70 12 c0 	mov    -0x3fed8f34(,%eax,4),%eax
c0106b08:	83 c0 04             	add    $0x4,%eax
c0106b0b:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c0106b12:	89 45 b0             	mov    %eax,-0x50(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106b15:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0106b18:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0106b1b:	0f a3 10             	bt     %edx,(%eax)
c0106b1e:	19 c0                	sbb    %eax,%eax
c0106b20:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c0106b23:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c0106b27:	0f 95 c0             	setne  %al
c0106b2a:	0f b6 c0             	movzbl %al,%eax
c0106b2d:	85 c0                	test   %eax,%eax
c0106b2f:	74 24                	je     c0106b55 <check_swap+0x306>
c0106b31:	c7 44 24 0c ec a5 10 	movl   $0xc010a5ec,0xc(%esp)
c0106b38:	c0 
c0106b39:	c7 44 24 08 e2 a3 10 	movl   $0xc010a3e2,0x8(%esp)
c0106b40:	c0 
c0106b41:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c0106b48:	00 
c0106b49:	c7 04 24 7c a3 10 c0 	movl   $0xc010a37c,(%esp)
c0106b50:	e8 b9 a1 ff ff       	call   c0100d0e <__panic>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106b55:	ff 45 ec             	incl   -0x14(%ebp)
c0106b58:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106b5c:	0f 8e 54 ff ff ff    	jle    c0106ab6 <check_swap+0x267>
     }
     list_entry_t free_list_store = free_list;
c0106b62:	a1 84 6f 12 c0       	mov    0xc0126f84,%eax
c0106b67:	8b 15 88 6f 12 c0    	mov    0xc0126f88,%edx
c0106b6d:	89 45 98             	mov    %eax,-0x68(%ebp)
c0106b70:	89 55 9c             	mov    %edx,-0x64(%ebp)
c0106b73:	c7 45 a4 84 6f 12 c0 	movl   $0xc0126f84,-0x5c(%ebp)
    elm->prev = elm->next = elm;
c0106b7a:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106b7d:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0106b80:	89 50 04             	mov    %edx,0x4(%eax)
c0106b83:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106b86:	8b 50 04             	mov    0x4(%eax),%edx
c0106b89:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106b8c:	89 10                	mov    %edx,(%eax)
}
c0106b8e:	90                   	nop
c0106b8f:	c7 45 a8 84 6f 12 c0 	movl   $0xc0126f84,-0x58(%ebp)
    return list->next == list;
c0106b96:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0106b99:	8b 40 04             	mov    0x4(%eax),%eax
c0106b9c:	39 45 a8             	cmp    %eax,-0x58(%ebp)
c0106b9f:	0f 94 c0             	sete   %al
c0106ba2:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c0106ba5:	85 c0                	test   %eax,%eax
c0106ba7:	75 24                	jne    c0106bcd <check_swap+0x37e>
c0106ba9:	c7 44 24 0c 07 a6 10 	movl   $0xc010a607,0xc(%esp)
c0106bb0:	c0 
c0106bb1:	c7 44 24 08 e2 a3 10 	movl   $0xc010a3e2,0x8(%esp)
c0106bb8:	c0 
c0106bb9:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c0106bc0:	00 
c0106bc1:	c7 04 24 7c a3 10 c0 	movl   $0xc010a37c,(%esp)
c0106bc8:	e8 41 a1 ff ff       	call   c0100d0e <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c0106bcd:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
c0106bd2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     nr_free = 0;
c0106bd5:	c7 05 8c 6f 12 c0 00 	movl   $0x0,0xc0126f8c
c0106bdc:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106bdf:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106be6:	eb 1d                	jmp    c0106c05 <check_swap+0x3b6>
        free_pages(check_rp[i],1);
c0106be8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106beb:	8b 04 85 cc 70 12 c0 	mov    -0x3fed8f34(,%eax,4),%eax
c0106bf2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106bf9:	00 
c0106bfa:	89 04 24             	mov    %eax,(%esp)
c0106bfd:	e8 ce dd ff ff       	call   c01049d0 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106c02:	ff 45 ec             	incl   -0x14(%ebp)
c0106c05:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106c09:	7e dd                	jle    c0106be8 <check_swap+0x399>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c0106c0b:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
c0106c10:	83 f8 04             	cmp    $0x4,%eax
c0106c13:	74 24                	je     c0106c39 <check_swap+0x3ea>
c0106c15:	c7 44 24 0c 20 a6 10 	movl   $0xc010a620,0xc(%esp)
c0106c1c:	c0 
c0106c1d:	c7 44 24 08 e2 a3 10 	movl   $0xc010a3e2,0x8(%esp)
c0106c24:	c0 
c0106c25:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c0106c2c:	00 
c0106c2d:	c7 04 24 7c a3 10 c0 	movl   $0xc010a37c,(%esp)
c0106c34:	e8 d5 a0 ff ff       	call   c0100d0e <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c0106c39:	c7 04 24 44 a6 10 c0 	movl   $0xc010a644,(%esp)
c0106c40:	e8 20 97 ff ff       	call   c0100365 <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c0106c45:	c7 05 10 71 12 c0 00 	movl   $0x0,0xc0127110
c0106c4c:	00 00 00 
     
     check_content_set();
c0106c4f:	e8 26 fa ff ff       	call   c010667a <check_content_set>
     assert( nr_free == 0);         
c0106c54:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
c0106c59:	85 c0                	test   %eax,%eax
c0106c5b:	74 24                	je     c0106c81 <check_swap+0x432>
c0106c5d:	c7 44 24 0c 6b a6 10 	movl   $0xc010a66b,0xc(%esp)
c0106c64:	c0 
c0106c65:	c7 44 24 08 e2 a3 10 	movl   $0xc010a3e2,0x8(%esp)
c0106c6c:	c0 
c0106c6d:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c0106c74:	00 
c0106c75:	c7 04 24 7c a3 10 c0 	movl   $0xc010a37c,(%esp)
c0106c7c:	e8 8d a0 ff ff       	call   c0100d0e <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0106c81:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106c88:	eb 25                	jmp    c0106caf <check_swap+0x460>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c0106c8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106c8d:	c7 04 85 60 70 12 c0 	movl   $0xffffffff,-0x3fed8fa0(,%eax,4)
c0106c94:	ff ff ff ff 
c0106c98:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106c9b:	8b 14 85 60 70 12 c0 	mov    -0x3fed8fa0(,%eax,4),%edx
c0106ca2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106ca5:	89 14 85 a0 70 12 c0 	mov    %edx,-0x3fed8f60(,%eax,4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0106cac:	ff 45 ec             	incl   -0x14(%ebp)
c0106caf:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c0106cb3:	7e d5                	jle    c0106c8a <check_swap+0x43b>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106cb5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106cbc:	e9 e8 00 00 00       	jmp    c0106da9 <check_swap+0x55a>
         check_ptep[i]=0;
c0106cc1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106cc4:	c7 04 85 dc 70 12 c0 	movl   $0x0,-0x3fed8f24(,%eax,4)
c0106ccb:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c0106ccf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106cd2:	40                   	inc    %eax
c0106cd3:	c1 e0 0c             	shl    $0xc,%eax
c0106cd6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106cdd:	00 
c0106cde:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106ce2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106ce5:	89 04 24             	mov    %eax,(%esp)
c0106ce8:	e8 2c e3 ff ff       	call   c0105019 <get_pte>
c0106ced:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106cf0:	89 04 95 dc 70 12 c0 	mov    %eax,-0x3fed8f24(,%edx,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c0106cf7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106cfa:	8b 04 85 dc 70 12 c0 	mov    -0x3fed8f24(,%eax,4),%eax
c0106d01:	85 c0                	test   %eax,%eax
c0106d03:	75 24                	jne    c0106d29 <check_swap+0x4da>
c0106d05:	c7 44 24 0c 78 a6 10 	movl   $0xc010a678,0xc(%esp)
c0106d0c:	c0 
c0106d0d:	c7 44 24 08 e2 a3 10 	movl   $0xc010a3e2,0x8(%esp)
c0106d14:	c0 
c0106d15:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0106d1c:	00 
c0106d1d:	c7 04 24 7c a3 10 c0 	movl   $0xc010a37c,(%esp)
c0106d24:	e8 e5 9f ff ff       	call   c0100d0e <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c0106d29:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106d2c:	8b 04 85 dc 70 12 c0 	mov    -0x3fed8f24(,%eax,4),%eax
c0106d33:	8b 00                	mov    (%eax),%eax
c0106d35:	89 04 24             	mov    %eax,(%esp)
c0106d38:	e8 97 f5 ff ff       	call   c01062d4 <pte2page>
c0106d3d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106d40:	8b 14 95 cc 70 12 c0 	mov    -0x3fed8f34(,%edx,4),%edx
c0106d47:	39 d0                	cmp    %edx,%eax
c0106d49:	74 24                	je     c0106d6f <check_swap+0x520>
c0106d4b:	c7 44 24 0c 90 a6 10 	movl   $0xc010a690,0xc(%esp)
c0106d52:	c0 
c0106d53:	c7 44 24 08 e2 a3 10 	movl   $0xc010a3e2,0x8(%esp)
c0106d5a:	c0 
c0106d5b:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c0106d62:	00 
c0106d63:	c7 04 24 7c a3 10 c0 	movl   $0xc010a37c,(%esp)
c0106d6a:	e8 9f 9f ff ff       	call   c0100d0e <__panic>
         assert((*check_ptep[i] & PTE_P));          
c0106d6f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106d72:	8b 04 85 dc 70 12 c0 	mov    -0x3fed8f24(,%eax,4),%eax
c0106d79:	8b 00                	mov    (%eax),%eax
c0106d7b:	83 e0 01             	and    $0x1,%eax
c0106d7e:	85 c0                	test   %eax,%eax
c0106d80:	75 24                	jne    c0106da6 <check_swap+0x557>
c0106d82:	c7 44 24 0c b8 a6 10 	movl   $0xc010a6b8,0xc(%esp)
c0106d89:	c0 
c0106d8a:	c7 44 24 08 e2 a3 10 	movl   $0xc010a3e2,0x8(%esp)
c0106d91:	c0 
c0106d92:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c0106d99:	00 
c0106d9a:	c7 04 24 7c a3 10 c0 	movl   $0xc010a37c,(%esp)
c0106da1:	e8 68 9f ff ff       	call   c0100d0e <__panic>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106da6:	ff 45 ec             	incl   -0x14(%ebp)
c0106da9:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106dad:	0f 8e 0e ff ff ff    	jle    c0106cc1 <check_swap+0x472>
     }
     cprintf("set up init env for check_swap over!\n");
c0106db3:	c7 04 24 d4 a6 10 c0 	movl   $0xc010a6d4,(%esp)
c0106dba:	e8 a6 95 ff ff       	call   c0100365 <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c0106dbf:	e8 71 fa ff ff       	call   c0106835 <check_content_access>
c0106dc4:	89 45 d0             	mov    %eax,-0x30(%ebp)
     assert(ret==0);
c0106dc7:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0106dcb:	74 24                	je     c0106df1 <check_swap+0x5a2>
c0106dcd:	c7 44 24 0c fa a6 10 	movl   $0xc010a6fa,0xc(%esp)
c0106dd4:	c0 
c0106dd5:	c7 44 24 08 e2 a3 10 	movl   $0xc010a3e2,0x8(%esp)
c0106ddc:	c0 
c0106ddd:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c0106de4:	00 
c0106de5:	c7 04 24 7c a3 10 c0 	movl   $0xc010a37c,(%esp)
c0106dec:	e8 1d 9f ff ff       	call   c0100d0e <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106df1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106df8:	eb 1d                	jmp    c0106e17 <check_swap+0x5c8>
         free_pages(check_rp[i],1);
c0106dfa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106dfd:	8b 04 85 cc 70 12 c0 	mov    -0x3fed8f34(,%eax,4),%eax
c0106e04:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106e0b:	00 
c0106e0c:	89 04 24             	mov    %eax,(%esp)
c0106e0f:	e8 bc db ff ff       	call   c01049d0 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106e14:	ff 45 ec             	incl   -0x14(%ebp)
c0106e17:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106e1b:	7e dd                	jle    c0106dfa <check_swap+0x5ab>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
c0106e1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106e20:	89 04 24             	mov    %eax,(%esp)
c0106e23:	e8 85 09 00 00       	call   c01077ad <mm_destroy>
         
     nr_free = nr_free_store;
c0106e28:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106e2b:	a3 8c 6f 12 c0       	mov    %eax,0xc0126f8c
     free_list = free_list_store;
c0106e30:	8b 45 98             	mov    -0x68(%ebp),%eax
c0106e33:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0106e36:	a3 84 6f 12 c0       	mov    %eax,0xc0126f84
c0106e3b:	89 15 88 6f 12 c0    	mov    %edx,0xc0126f88

     
     le = &free_list;
c0106e41:	c7 45 e8 84 6f 12 c0 	movl   $0xc0126f84,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0106e48:	eb 1c                	jmp    c0106e66 <check_swap+0x617>
         struct Page *p = le2page(le, page_link);
c0106e4a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106e4d:	83 e8 0c             	sub    $0xc,%eax
c0106e50:	89 45 cc             	mov    %eax,-0x34(%ebp)
         count --, total -= p->property;
c0106e53:	ff 4d f4             	decl   -0xc(%ebp)
c0106e56:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106e59:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0106e5c:	8b 48 08             	mov    0x8(%eax),%ecx
c0106e5f:	89 d0                	mov    %edx,%eax
c0106e61:	29 c8                	sub    %ecx,%eax
c0106e63:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106e66:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106e69:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return listelm->next;
c0106e6c:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0106e6f:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c0106e72:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106e75:	81 7d e8 84 6f 12 c0 	cmpl   $0xc0126f84,-0x18(%ebp)
c0106e7c:	75 cc                	jne    c0106e4a <check_swap+0x5fb>
     }
     cprintf("count is %d, total is %d\n",count,total);
c0106e7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106e81:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106e85:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106e88:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106e8c:	c7 04 24 01 a7 10 c0 	movl   $0xc010a701,(%esp)
c0106e93:	e8 cd 94 ff ff       	call   c0100365 <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c0106e98:	c7 04 24 1b a7 10 c0 	movl   $0xc010a71b,(%esp)
c0106e9f:	e8 c1 94 ff ff       	call   c0100365 <cprintf>
}
c0106ea4:	90                   	nop
c0106ea5:	89 ec                	mov    %ebp,%esp
c0106ea7:	5d                   	pop    %ebp
c0106ea8:	c3                   	ret    

c0106ea9 <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c0106ea9:	55                   	push   %ebp
c0106eaa:	89 e5                	mov    %esp,%ebp
c0106eac:	83 ec 10             	sub    $0x10,%esp
c0106eaf:	c7 45 fc 04 71 12 c0 	movl   $0xc0127104,-0x4(%ebp)
    elm->prev = elm->next = elm;
c0106eb6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106eb9:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0106ebc:	89 50 04             	mov    %edx,0x4(%eax)
c0106ebf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106ec2:	8b 50 04             	mov    0x4(%eax),%edx
c0106ec5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106ec8:	89 10                	mov    %edx,(%eax)
}
c0106eca:	90                   	nop
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c0106ecb:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ece:	c7 40 14 04 71 12 c0 	movl   $0xc0127104,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c0106ed5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106eda:	89 ec                	mov    %ebp,%esp
c0106edc:	5d                   	pop    %ebp
c0106edd:	c3                   	ret    

c0106ede <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0106ede:	55                   	push   %ebp
c0106edf:	89 e5                	mov    %esp,%ebp
c0106ee1:	83 ec 48             	sub    $0x48,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0106ee4:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ee7:	8b 40 14             	mov    0x14(%eax),%eax
c0106eea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c0106eed:	8b 45 10             	mov    0x10(%ebp),%eax
c0106ef0:	83 c0 14             	add    $0x14,%eax
c0106ef3:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c0106ef6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106efa:	74 06                	je     c0106f02 <_fifo_map_swappable+0x24>
c0106efc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106f00:	75 24                	jne    c0106f26 <_fifo_map_swappable+0x48>
c0106f02:	c7 44 24 0c 34 a7 10 	movl   $0xc010a734,0xc(%esp)
c0106f09:	c0 
c0106f0a:	c7 44 24 08 52 a7 10 	movl   $0xc010a752,0x8(%esp)
c0106f11:	c0 
c0106f12:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
c0106f19:	00 
c0106f1a:	c7 04 24 67 a7 10 c0 	movl   $0xc010a767,(%esp)
c0106f21:	e8 e8 9d ff ff       	call   c0100d0e <__panic>
c0106f26:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106f29:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106f2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106f2f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106f32:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106f35:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106f38:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106f3b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_add(elm, listelm, listelm->next);
c0106f3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106f41:	8b 40 04             	mov    0x4(%eax),%eax
c0106f44:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106f47:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0106f4a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106f4d:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0106f50:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    prev->next = next->prev = elm;
c0106f53:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106f56:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106f59:	89 10                	mov    %edx,(%eax)
c0106f5b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106f5e:	8b 10                	mov    (%eax),%edx
c0106f60:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106f63:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0106f66:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106f69:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106f6c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0106f6f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106f72:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106f75:	89 10                	mov    %edx,(%eax)
}
c0106f77:	90                   	nop
}
c0106f78:	90                   	nop
}
c0106f79:	90                   	nop
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.

    list_add(head,entry);
    
    return 0;
c0106f7a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106f7f:	89 ec                	mov    %ebp,%esp
c0106f81:	5d                   	pop    %ebp
c0106f82:	c3                   	ret    

c0106f83 <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c0106f83:	55                   	push   %ebp
c0106f84:	89 e5                	mov    %esp,%ebp
c0106f86:	83 ec 38             	sub    $0x38,%esp
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0106f89:	8b 45 08             	mov    0x8(%ebp),%eax
c0106f8c:	8b 40 14             	mov    0x14(%eax),%eax
c0106f8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
         assert(head != NULL);
c0106f92:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106f96:	75 24                	jne    c0106fbc <_fifo_swap_out_victim+0x39>
c0106f98:	c7 44 24 0c 7b a7 10 	movl   $0xc010a77b,0xc(%esp)
c0106f9f:	c0 
c0106fa0:	c7 44 24 08 52 a7 10 	movl   $0xc010a752,0x8(%esp)
c0106fa7:	c0 
c0106fa8:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
c0106faf:	00 
c0106fb0:	c7 04 24 67 a7 10 c0 	movl   $0xc010a767,(%esp)
c0106fb7:	e8 52 9d ff ff       	call   c0100d0e <__panic>
     assert(in_tick==0);
c0106fbc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106fc0:	74 24                	je     c0106fe6 <_fifo_swap_out_victim+0x63>
c0106fc2:	c7 44 24 0c 88 a7 10 	movl   $0xc010a788,0xc(%esp)
c0106fc9:	c0 
c0106fca:	c7 44 24 08 52 a7 10 	movl   $0xc010a752,0x8(%esp)
c0106fd1:	c0 
c0106fd2:	c7 44 24 04 44 00 00 	movl   $0x44,0x4(%esp)
c0106fd9:	00 
c0106fda:	c7 04 24 67 a7 10 c0 	movl   $0xc010a767,(%esp)
c0106fe1:	e8 28 9d ff ff       	call   c0100d0e <__panic>
c0106fe6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106fe9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return listelm->prev;
c0106fec:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106fef:	8b 00                	mov    (%eax),%eax
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  assign the value of *ptr_page to the addr of this page
    
     list_entry_t *le=list_prev(head);
c0106ff1:	89 45 f0             	mov    %eax,-0x10(%ebp)
     assert(head!=le);
c0106ff4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106ff7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0106ffa:	75 24                	jne    c0107020 <_fifo_swap_out_victim+0x9d>
c0106ffc:	c7 44 24 0c 93 a7 10 	movl   $0xc010a793,0xc(%esp)
c0107003:	c0 
c0107004:	c7 44 24 08 52 a7 10 	movl   $0xc010a752,0x8(%esp)
c010700b:	c0 
c010700c:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
c0107013:	00 
c0107014:	c7 04 24 67 a7 10 c0 	movl   $0xc010a767,(%esp)
c010701b:	e8 ee 9c ff ff       	call   c0100d0e <__panic>
     struct Page *page=le2page(le,pra_page_link);
c0107020:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107023:	83 e8 14             	sub    $0x14,%eax
c0107026:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107029:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010702c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    __list_del(listelm->prev, listelm->next);
c010702f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107032:	8b 40 04             	mov    0x4(%eax),%eax
c0107035:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107038:	8b 12                	mov    (%edx),%edx
c010703a:	89 55 e0             	mov    %edx,-0x20(%ebp)
c010703d:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next;
c0107040:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107043:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107046:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0107049:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010704c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010704f:	89 10                	mov    %edx,(%eax)
}
c0107051:	90                   	nop
}
c0107052:	90                   	nop

     list_del(le);

    assert(page !=NULL); 
c0107053:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107057:	75 24                	jne    c010707d <_fifo_swap_out_victim+0xfa>
c0107059:	c7 44 24 0c 9c a7 10 	movl   $0xc010a79c,0xc(%esp)
c0107060:	c0 
c0107061:	c7 44 24 08 52 a7 10 	movl   $0xc010a752,0x8(%esp)
c0107068:	c0 
c0107069:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
c0107070:	00 
c0107071:	c7 04 24 67 a7 10 c0 	movl   $0xc010a767,(%esp)
c0107078:	e8 91 9c ff ff       	call   c0100d0e <__panic>

    *ptr_page = page;
c010707d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107080:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107083:	89 10                	mov    %edx,(%eax)
     struct Page *p = le2page(le, pra_page_link);
     list_del(le);
     assert(p !=NULL);
     *ptr_page = p;*/
     
     return 0;
c0107085:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010708a:	89 ec                	mov    %ebp,%esp
c010708c:	5d                   	pop    %ebp
c010708d:	c3                   	ret    

c010708e <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c010708e:	55                   	push   %ebp
c010708f:	89 e5                	mov    %esp,%ebp
c0107091:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c0107094:	c7 04 24 a8 a7 10 c0 	movl   $0xc010a7a8,(%esp)
c010709b:	e8 c5 92 ff ff       	call   c0100365 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c01070a0:	b8 00 30 00 00       	mov    $0x3000,%eax
c01070a5:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c01070a8:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c01070ad:	83 f8 04             	cmp    $0x4,%eax
c01070b0:	74 24                	je     c01070d6 <_fifo_check_swap+0x48>
c01070b2:	c7 44 24 0c ce a7 10 	movl   $0xc010a7ce,0xc(%esp)
c01070b9:	c0 
c01070ba:	c7 44 24 08 52 a7 10 	movl   $0xc010a752,0x8(%esp)
c01070c1:	c0 
c01070c2:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
c01070c9:	00 
c01070ca:	c7 04 24 67 a7 10 c0 	movl   $0xc010a767,(%esp)
c01070d1:	e8 38 9c ff ff       	call   c0100d0e <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c01070d6:	c7 04 24 e0 a7 10 c0 	movl   $0xc010a7e0,(%esp)
c01070dd:	e8 83 92 ff ff       	call   c0100365 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c01070e2:	b8 00 10 00 00       	mov    $0x1000,%eax
c01070e7:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c01070ea:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c01070ef:	83 f8 04             	cmp    $0x4,%eax
c01070f2:	74 24                	je     c0107118 <_fifo_check_swap+0x8a>
c01070f4:	c7 44 24 0c ce a7 10 	movl   $0xc010a7ce,0xc(%esp)
c01070fb:	c0 
c01070fc:	c7 44 24 08 52 a7 10 	movl   $0xc010a752,0x8(%esp)
c0107103:	c0 
c0107104:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c010710b:	00 
c010710c:	c7 04 24 67 a7 10 c0 	movl   $0xc010a767,(%esp)
c0107113:	e8 f6 9b ff ff       	call   c0100d0e <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0107118:	c7 04 24 08 a8 10 c0 	movl   $0xc010a808,(%esp)
c010711f:	e8 41 92 ff ff       	call   c0100365 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0107124:	b8 00 40 00 00       	mov    $0x4000,%eax
c0107129:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c010712c:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c0107131:	83 f8 04             	cmp    $0x4,%eax
c0107134:	74 24                	je     c010715a <_fifo_check_swap+0xcc>
c0107136:	c7 44 24 0c ce a7 10 	movl   $0xc010a7ce,0xc(%esp)
c010713d:	c0 
c010713e:	c7 44 24 08 52 a7 10 	movl   $0xc010a752,0x8(%esp)
c0107145:	c0 
c0107146:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
c010714d:	00 
c010714e:	c7 04 24 67 a7 10 c0 	movl   $0xc010a767,(%esp)
c0107155:	e8 b4 9b ff ff       	call   c0100d0e <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c010715a:	c7 04 24 30 a8 10 c0 	movl   $0xc010a830,(%esp)
c0107161:	e8 ff 91 ff ff       	call   c0100365 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107166:	b8 00 20 00 00       	mov    $0x2000,%eax
c010716b:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c010716e:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c0107173:	83 f8 04             	cmp    $0x4,%eax
c0107176:	74 24                	je     c010719c <_fifo_check_swap+0x10e>
c0107178:	c7 44 24 0c ce a7 10 	movl   $0xc010a7ce,0xc(%esp)
c010717f:	c0 
c0107180:	c7 44 24 08 52 a7 10 	movl   $0xc010a752,0x8(%esp)
c0107187:	c0 
c0107188:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c010718f:	00 
c0107190:	c7 04 24 67 a7 10 c0 	movl   $0xc010a767,(%esp)
c0107197:	e8 72 9b ff ff       	call   c0100d0e <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c010719c:	c7 04 24 58 a8 10 c0 	movl   $0xc010a858,(%esp)
c01071a3:	e8 bd 91 ff ff       	call   c0100365 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c01071a8:	b8 00 50 00 00       	mov    $0x5000,%eax
c01071ad:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c01071b0:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c01071b5:	83 f8 05             	cmp    $0x5,%eax
c01071b8:	74 24                	je     c01071de <_fifo_check_swap+0x150>
c01071ba:	c7 44 24 0c 7e a8 10 	movl   $0xc010a87e,0xc(%esp)
c01071c1:	c0 
c01071c2:	c7 44 24 08 52 a7 10 	movl   $0xc010a752,0x8(%esp)
c01071c9:	c0 
c01071ca:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
c01071d1:	00 
c01071d2:	c7 04 24 67 a7 10 c0 	movl   $0xc010a767,(%esp)
c01071d9:	e8 30 9b ff ff       	call   c0100d0e <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c01071de:	c7 04 24 30 a8 10 c0 	movl   $0xc010a830,(%esp)
c01071e5:	e8 7b 91 ff ff       	call   c0100365 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c01071ea:	b8 00 20 00 00       	mov    $0x2000,%eax
c01071ef:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c01071f2:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c01071f7:	83 f8 05             	cmp    $0x5,%eax
c01071fa:	74 24                	je     c0107220 <_fifo_check_swap+0x192>
c01071fc:	c7 44 24 0c 7e a8 10 	movl   $0xc010a87e,0xc(%esp)
c0107203:	c0 
c0107204:	c7 44 24 08 52 a7 10 	movl   $0xc010a752,0x8(%esp)
c010720b:	c0 
c010720c:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
c0107213:	00 
c0107214:	c7 04 24 67 a7 10 c0 	movl   $0xc010a767,(%esp)
c010721b:	e8 ee 9a ff ff       	call   c0100d0e <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107220:	c7 04 24 e0 a7 10 c0 	movl   $0xc010a7e0,(%esp)
c0107227:	e8 39 91 ff ff       	call   c0100365 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c010722c:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107231:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c0107234:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c0107239:	83 f8 06             	cmp    $0x6,%eax
c010723c:	74 24                	je     c0107262 <_fifo_check_swap+0x1d4>
c010723e:	c7 44 24 0c 8d a8 10 	movl   $0xc010a88d,0xc(%esp)
c0107245:	c0 
c0107246:	c7 44 24 08 52 a7 10 	movl   $0xc010a752,0x8(%esp)
c010724d:	c0 
c010724e:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
c0107255:	00 
c0107256:	c7 04 24 67 a7 10 c0 	movl   $0xc010a767,(%esp)
c010725d:	e8 ac 9a ff ff       	call   c0100d0e <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107262:	c7 04 24 30 a8 10 c0 	movl   $0xc010a830,(%esp)
c0107269:	e8 f7 90 ff ff       	call   c0100365 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c010726e:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107273:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c0107276:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c010727b:	83 f8 07             	cmp    $0x7,%eax
c010727e:	74 24                	je     c01072a4 <_fifo_check_swap+0x216>
c0107280:	c7 44 24 0c 9c a8 10 	movl   $0xc010a89c,0xc(%esp)
c0107287:	c0 
c0107288:	c7 44 24 08 52 a7 10 	movl   $0xc010a752,0x8(%esp)
c010728f:	c0 
c0107290:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
c0107297:	00 
c0107298:	c7 04 24 67 a7 10 c0 	movl   $0xc010a767,(%esp)
c010729f:	e8 6a 9a ff ff       	call   c0100d0e <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c01072a4:	c7 04 24 a8 a7 10 c0 	movl   $0xc010a7a8,(%esp)
c01072ab:	e8 b5 90 ff ff       	call   c0100365 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c01072b0:	b8 00 30 00 00       	mov    $0x3000,%eax
c01072b5:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c01072b8:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c01072bd:	83 f8 08             	cmp    $0x8,%eax
c01072c0:	74 24                	je     c01072e6 <_fifo_check_swap+0x258>
c01072c2:	c7 44 24 0c ab a8 10 	movl   $0xc010a8ab,0xc(%esp)
c01072c9:	c0 
c01072ca:	c7 44 24 08 52 a7 10 	movl   $0xc010a752,0x8(%esp)
c01072d1:	c0 
c01072d2:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
c01072d9:	00 
c01072da:	c7 04 24 67 a7 10 c0 	movl   $0xc010a767,(%esp)
c01072e1:	e8 28 9a ff ff       	call   c0100d0e <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c01072e6:	c7 04 24 08 a8 10 c0 	movl   $0xc010a808,(%esp)
c01072ed:	e8 73 90 ff ff       	call   c0100365 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c01072f2:	b8 00 40 00 00       	mov    $0x4000,%eax
c01072f7:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c01072fa:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c01072ff:	83 f8 09             	cmp    $0x9,%eax
c0107302:	74 24                	je     c0107328 <_fifo_check_swap+0x29a>
c0107304:	c7 44 24 0c ba a8 10 	movl   $0xc010a8ba,0xc(%esp)
c010730b:	c0 
c010730c:	c7 44 24 08 52 a7 10 	movl   $0xc010a752,0x8(%esp)
c0107313:	c0 
c0107314:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
c010731b:	00 
c010731c:	c7 04 24 67 a7 10 c0 	movl   $0xc010a767,(%esp)
c0107323:	e8 e6 99 ff ff       	call   c0100d0e <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0107328:	c7 04 24 58 a8 10 c0 	movl   $0xc010a858,(%esp)
c010732f:	e8 31 90 ff ff       	call   c0100365 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0107334:	b8 00 50 00 00       	mov    $0x5000,%eax
c0107339:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c010733c:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c0107341:	83 f8 0a             	cmp    $0xa,%eax
c0107344:	74 24                	je     c010736a <_fifo_check_swap+0x2dc>
c0107346:	c7 44 24 0c c9 a8 10 	movl   $0xc010a8c9,0xc(%esp)
c010734d:	c0 
c010734e:	c7 44 24 08 52 a7 10 	movl   $0xc010a752,0x8(%esp)
c0107355:	c0 
c0107356:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
c010735d:	00 
c010735e:	c7 04 24 67 a7 10 c0 	movl   $0xc010a767,(%esp)
c0107365:	e8 a4 99 ff ff       	call   c0100d0e <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c010736a:	c7 04 24 e0 a7 10 c0 	movl   $0xc010a7e0,(%esp)
c0107371:	e8 ef 8f ff ff       	call   c0100365 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c0107376:	b8 00 10 00 00       	mov    $0x1000,%eax
c010737b:	0f b6 00             	movzbl (%eax),%eax
c010737e:	3c 0a                	cmp    $0xa,%al
c0107380:	74 24                	je     c01073a6 <_fifo_check_swap+0x318>
c0107382:	c7 44 24 0c dc a8 10 	movl   $0xc010a8dc,0xc(%esp)
c0107389:	c0 
c010738a:	c7 44 24 08 52 a7 10 	movl   $0xc010a752,0x8(%esp)
c0107391:	c0 
c0107392:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
c0107399:	00 
c010739a:	c7 04 24 67 a7 10 c0 	movl   $0xc010a767,(%esp)
c01073a1:	e8 68 99 ff ff       	call   c0100d0e <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c01073a6:	b8 00 10 00 00       	mov    $0x1000,%eax
c01073ab:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c01073ae:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c01073b3:	83 f8 0b             	cmp    $0xb,%eax
c01073b6:	74 24                	je     c01073dc <_fifo_check_swap+0x34e>
c01073b8:	c7 44 24 0c fd a8 10 	movl   $0xc010a8fd,0xc(%esp)
c01073bf:	c0 
c01073c0:	c7 44 24 08 52 a7 10 	movl   $0xc010a752,0x8(%esp)
c01073c7:	c0 
c01073c8:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
c01073cf:	00 
c01073d0:	c7 04 24 67 a7 10 c0 	movl   $0xc010a767,(%esp)
c01073d7:	e8 32 99 ff ff       	call   c0100d0e <__panic>
    return 0;
c01073dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01073e1:	89 ec                	mov    %ebp,%esp
c01073e3:	5d                   	pop    %ebp
c01073e4:	c3                   	ret    

c01073e5 <_fifo_init>:


static int
_fifo_init(void)
{
c01073e5:	55                   	push   %ebp
c01073e6:	89 e5                	mov    %esp,%ebp
    return 0;
c01073e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01073ed:	5d                   	pop    %ebp
c01073ee:	c3                   	ret    

c01073ef <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c01073ef:	55                   	push   %ebp
c01073f0:	89 e5                	mov    %esp,%ebp
    return 0;
c01073f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01073f7:	5d                   	pop    %ebp
c01073f8:	c3                   	ret    

c01073f9 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c01073f9:	55                   	push   %ebp
c01073fa:	89 e5                	mov    %esp,%ebp
c01073fc:	b8 00 00 00 00       	mov    $0x0,%eax
c0107401:	5d                   	pop    %ebp
c0107402:	c3                   	ret    

c0107403 <pa2page>:
pa2page(uintptr_t pa) {
c0107403:	55                   	push   %ebp
c0107404:	89 e5                	mov    %esp,%ebp
c0107406:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0107409:	8b 45 08             	mov    0x8(%ebp),%eax
c010740c:	c1 e8 0c             	shr    $0xc,%eax
c010740f:	89 c2                	mov    %eax,%edx
c0107411:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c0107416:	39 c2                	cmp    %eax,%edx
c0107418:	72 1c                	jb     c0107436 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c010741a:	c7 44 24 08 20 a9 10 	movl   $0xc010a920,0x8(%esp)
c0107421:	c0 
c0107422:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c0107429:	00 
c010742a:	c7 04 24 3f a9 10 c0 	movl   $0xc010a93f,(%esp)
c0107431:	e8 d8 98 ff ff       	call   c0100d0e <__panic>
    return &pages[PPN(pa)];
c0107436:	8b 15 a0 6f 12 c0    	mov    0xc0126fa0,%edx
c010743c:	8b 45 08             	mov    0x8(%ebp),%eax
c010743f:	c1 e8 0c             	shr    $0xc,%eax
c0107442:	c1 e0 05             	shl    $0x5,%eax
c0107445:	01 d0                	add    %edx,%eax
}
c0107447:	89 ec                	mov    %ebp,%esp
c0107449:	5d                   	pop    %ebp
c010744a:	c3                   	ret    

c010744b <pde2page>:
pde2page(pde_t pde) {
c010744b:	55                   	push   %ebp
c010744c:	89 e5                	mov    %esp,%ebp
c010744e:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0107451:	8b 45 08             	mov    0x8(%ebp),%eax
c0107454:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107459:	89 04 24             	mov    %eax,(%esp)
c010745c:	e8 a2 ff ff ff       	call   c0107403 <pa2page>
}
c0107461:	89 ec                	mov    %ebp,%esp
c0107463:	5d                   	pop    %ebp
c0107464:	c3                   	ret    

c0107465 <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c0107465:	55                   	push   %ebp
c0107466:	89 e5                	mov    %esp,%ebp
c0107468:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c010746b:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c0107472:	e8 d6 ec ff ff       	call   c010614d <kmalloc>
c0107477:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c010747a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010747e:	74 59                	je     c01074d9 <mm_create+0x74>
        list_init(&(mm->mmap_list));
c0107480:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107483:	89 45 f0             	mov    %eax,-0x10(%ebp)
    elm->prev = elm->next = elm;
c0107486:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107489:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010748c:	89 50 04             	mov    %edx,0x4(%eax)
c010748f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107492:	8b 50 04             	mov    0x4(%eax),%edx
c0107495:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107498:	89 10                	mov    %edx,(%eax)
}
c010749a:	90                   	nop
        mm->mmap_cache = NULL;
c010749b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010749e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c01074a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01074a8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c01074af:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01074b2:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c01074b9:	a1 44 70 12 c0       	mov    0xc0127044,%eax
c01074be:	85 c0                	test   %eax,%eax
c01074c0:	74 0d                	je     c01074cf <mm_create+0x6a>
c01074c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01074c5:	89 04 24             	mov    %eax,(%esp)
c01074c8:	e8 d9 ee ff ff       	call   c01063a6 <swap_init_mm>
c01074cd:	eb 0a                	jmp    c01074d9 <mm_create+0x74>
        else mm->sm_priv = NULL;
c01074cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01074d2:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    }
    return mm;
c01074d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01074dc:	89 ec                	mov    %ebp,%esp
c01074de:	5d                   	pop    %ebp
c01074df:	c3                   	ret    

c01074e0 <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c01074e0:	55                   	push   %ebp
c01074e1:	89 e5                	mov    %esp,%ebp
c01074e3:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c01074e6:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c01074ed:	e8 5b ec ff ff       	call   c010614d <kmalloc>
c01074f2:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c01074f5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01074f9:	74 1b                	je     c0107516 <vma_create+0x36>
        vma->vm_start = vm_start;
c01074fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01074fe:	8b 55 08             	mov    0x8(%ebp),%edx
c0107501:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c0107504:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107507:	8b 55 0c             	mov    0xc(%ebp),%edx
c010750a:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c010750d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107510:	8b 55 10             	mov    0x10(%ebp),%edx
c0107513:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c0107516:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107519:	89 ec                	mov    %ebp,%esp
c010751b:	5d                   	pop    %ebp
c010751c:	c3                   	ret    

c010751d <find_vma>:
//find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
//vma_cache,找的时候先找cache，如果cache里面没有东西，或是cache里面的vma不对的话，那么就在双向链表里面找，如果
//找到vma之后，都会在cahe里面更新，即cache里面的东西为上次找到vma，或是为null

struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c010751d:	55                   	push   %ebp
c010751e:	89 e5                	mov    %esp,%ebp
c0107520:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c0107523:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c010752a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010752e:	0f 84 95 00 00 00    	je     c01075c9 <find_vma+0xac>
        vma = mm->mmap_cache;
c0107534:	8b 45 08             	mov    0x8(%ebp),%eax
c0107537:	8b 40 08             	mov    0x8(%eax),%eax
c010753a:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c010753d:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0107541:	74 16                	je     c0107559 <find_vma+0x3c>
c0107543:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107546:	8b 40 04             	mov    0x4(%eax),%eax
c0107549:	39 45 0c             	cmp    %eax,0xc(%ebp)
c010754c:	72 0b                	jb     c0107559 <find_vma+0x3c>
c010754e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107551:	8b 40 08             	mov    0x8(%eax),%eax
c0107554:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0107557:	72 61                	jb     c01075ba <find_vma+0x9d>
                bool found = 0;
c0107559:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c0107560:	8b 45 08             	mov    0x8(%ebp),%eax
c0107563:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107566:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107569:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c010756c:	eb 28                	jmp    c0107596 <find_vma+0x79>
                    vma = le2vma(le, list_link);
c010756e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107571:	83 e8 10             	sub    $0x10,%eax
c0107574:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c0107577:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010757a:	8b 40 04             	mov    0x4(%eax),%eax
c010757d:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0107580:	72 14                	jb     c0107596 <find_vma+0x79>
c0107582:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107585:	8b 40 08             	mov    0x8(%eax),%eax
c0107588:	39 45 0c             	cmp    %eax,0xc(%ebp)
c010758b:	73 09                	jae    c0107596 <find_vma+0x79>
                        found = 1;
c010758d:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c0107594:	eb 17                	jmp    c01075ad <find_vma+0x90>
c0107596:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107599:	89 45 ec             	mov    %eax,-0x14(%ebp)
    return listelm->next;
c010759c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010759f:	8b 40 04             	mov    0x4(%eax),%eax
                while ((le = list_next(le)) != list) {
c01075a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01075a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01075a8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01075ab:	75 c1                	jne    c010756e <find_vma+0x51>
                    }
                }
                if (!found) {
c01075ad:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c01075b1:	75 07                	jne    c01075ba <find_vma+0x9d>
                    vma = NULL;
c01075b3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c01075ba:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01075be:	74 09                	je     c01075c9 <find_vma+0xac>
            mm->mmap_cache = vma;
c01075c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01075c3:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01075c6:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c01075c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01075cc:	89 ec                	mov    %ebp,%esp
c01075ce:	5d                   	pop    %ebp
c01075cf:	c3                   	ret    

c01075d0 <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
//看vma地址相交是否不为空
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c01075d0:	55                   	push   %ebp
c01075d1:	89 e5                	mov    %esp,%ebp
c01075d3:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c01075d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01075d9:	8b 50 04             	mov    0x4(%eax),%edx
c01075dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01075df:	8b 40 08             	mov    0x8(%eax),%eax
c01075e2:	39 c2                	cmp    %eax,%edx
c01075e4:	72 24                	jb     c010760a <check_vma_overlap+0x3a>
c01075e6:	c7 44 24 0c 4d a9 10 	movl   $0xc010a94d,0xc(%esp)
c01075ed:	c0 
c01075ee:	c7 44 24 08 6b a9 10 	movl   $0xc010a96b,0x8(%esp)
c01075f5:	c0 
c01075f6:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c01075fd:	00 
c01075fe:	c7 04 24 80 a9 10 c0 	movl   $0xc010a980,(%esp)
c0107605:	e8 04 97 ff ff       	call   c0100d0e <__panic>
    assert(prev->vm_end <= next->vm_start);
c010760a:	8b 45 08             	mov    0x8(%ebp),%eax
c010760d:	8b 50 08             	mov    0x8(%eax),%edx
c0107610:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107613:	8b 40 04             	mov    0x4(%eax),%eax
c0107616:	39 c2                	cmp    %eax,%edx
c0107618:	76 24                	jbe    c010763e <check_vma_overlap+0x6e>
c010761a:	c7 44 24 0c 90 a9 10 	movl   $0xc010a990,0xc(%esp)
c0107621:	c0 
c0107622:	c7 44 24 08 6b a9 10 	movl   $0xc010a96b,0x8(%esp)
c0107629:	c0 
c010762a:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0107631:	00 
c0107632:	c7 04 24 80 a9 10 c0 	movl   $0xc010a980,(%esp)
c0107639:	e8 d0 96 ff ff       	call   c0100d0e <__panic>
    assert(next->vm_start < next->vm_end);
c010763e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107641:	8b 50 04             	mov    0x4(%eax),%edx
c0107644:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107647:	8b 40 08             	mov    0x8(%eax),%eax
c010764a:	39 c2                	cmp    %eax,%edx
c010764c:	72 24                	jb     c0107672 <check_vma_overlap+0xa2>
c010764e:	c7 44 24 0c af a9 10 	movl   $0xc010a9af,0xc(%esp)
c0107655:	c0 
c0107656:	c7 44 24 08 6b a9 10 	movl   $0xc010a96b,0x8(%esp)
c010765d:	c0 
c010765e:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0107665:	00 
c0107666:	c7 04 24 80 a9 10 c0 	movl   $0xc010a980,(%esp)
c010766d:	e8 9c 96 ff ff       	call   c0100d0e <__panic>
}
c0107672:	90                   	nop
c0107673:	89 ec                	mov    %ebp,%esp
c0107675:	5d                   	pop    %ebp
c0107676:	c3                   	ret    

c0107677 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
//将vma插入双向链表，用的方法是，找到第一个start比vma的start大的节点，然后把vma后插到它的前一个节点上
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c0107677:	55                   	push   %ebp
c0107678:	89 e5                	mov    %esp,%ebp
c010767a:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c010767d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107680:	8b 50 04             	mov    0x4(%eax),%edx
c0107683:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107686:	8b 40 08             	mov    0x8(%eax),%eax
c0107689:	39 c2                	cmp    %eax,%edx
c010768b:	72 24                	jb     c01076b1 <insert_vma_struct+0x3a>
c010768d:	c7 44 24 0c cd a9 10 	movl   $0xc010a9cd,0xc(%esp)
c0107694:	c0 
c0107695:	c7 44 24 08 6b a9 10 	movl   $0xc010a96b,0x8(%esp)
c010769c:	c0 
c010769d:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
c01076a4:	00 
c01076a5:	c7 04 24 80 a9 10 c0 	movl   $0xc010a980,(%esp)
c01076ac:	e8 5d 96 ff ff       	call   c0100d0e <__panic>
    list_entry_t *list = &(mm->mmap_list);
c01076b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01076b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c01076b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01076ba:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c01076bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01076c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c01076c3:	eb 1f                	jmp    c01076e4 <insert_vma_struct+0x6d>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c01076c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01076c8:	83 e8 10             	sub    $0x10,%eax
c01076cb:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c01076ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01076d1:	8b 50 04             	mov    0x4(%eax),%edx
c01076d4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01076d7:	8b 40 04             	mov    0x4(%eax),%eax
c01076da:	39 c2                	cmp    %eax,%edx
c01076dc:	77 1f                	ja     c01076fd <insert_vma_struct+0x86>
                break;
            }
            le_prev = le;
c01076de:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01076e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01076e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01076e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01076ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01076ed:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c01076f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01076f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01076f6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01076f9:	75 ca                	jne    c01076c5 <insert_vma_struct+0x4e>
c01076fb:	eb 01                	jmp    c01076fe <insert_vma_struct+0x87>
                break;
c01076fd:	90                   	nop
c01076fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107701:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0107704:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107707:	8b 40 04             	mov    0x4(%eax),%eax
        }

    le_next = list_next(le_prev);
c010770a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list) {
c010770d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107710:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107713:	74 15                	je     c010772a <insert_vma_struct+0xb3>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c0107715:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107718:	8d 50 f0             	lea    -0x10(%eax),%edx
c010771b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010771e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107722:	89 14 24             	mov    %edx,(%esp)
c0107725:	e8 a6 fe ff ff       	call   c01075d0 <check_vma_overlap>
    }
    if (le_next != list) {
c010772a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010772d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107730:	74 15                	je     c0107747 <insert_vma_struct+0xd0>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c0107732:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107735:	83 e8 10             	sub    $0x10,%eax
c0107738:	89 44 24 04          	mov    %eax,0x4(%esp)
c010773c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010773f:	89 04 24             	mov    %eax,(%esp)
c0107742:	e8 89 fe ff ff       	call   c01075d0 <check_vma_overlap>
    }

    vma->vm_mm = mm;
c0107747:	8b 45 0c             	mov    0xc(%ebp),%eax
c010774a:	8b 55 08             	mov    0x8(%ebp),%edx
c010774d:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c010774f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107752:	8d 50 10             	lea    0x10(%eax),%edx
c0107755:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107758:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010775b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c010775e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107761:	8b 40 04             	mov    0x4(%eax),%eax
c0107764:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107767:	89 55 d0             	mov    %edx,-0x30(%ebp)
c010776a:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010776d:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0107770:	89 45 c8             	mov    %eax,-0x38(%ebp)
    prev->next = next->prev = elm;
c0107773:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0107776:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0107779:	89 10                	mov    %edx,(%eax)
c010777b:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010777e:	8b 10                	mov    (%eax),%edx
c0107780:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0107783:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0107786:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107789:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010778c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010778f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107792:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0107795:	89 10                	mov    %edx,(%eax)
}
c0107797:	90                   	nop
}
c0107798:	90                   	nop

    mm->map_count ++;
c0107799:	8b 45 08             	mov    0x8(%ebp),%eax
c010779c:	8b 40 10             	mov    0x10(%eax),%eax
c010779f:	8d 50 01             	lea    0x1(%eax),%edx
c01077a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01077a5:	89 50 10             	mov    %edx,0x10(%eax)
}
c01077a8:	90                   	nop
c01077a9:	89 ec                	mov    %ebp,%esp
c01077ab:	5d                   	pop    %ebp
c01077ac:	c3                   	ret    

c01077ad <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c01077ad:	55                   	push   %ebp
c01077ae:	89 e5                	mov    %esp,%ebp
c01077b0:	83 ec 38             	sub    $0x38,%esp

    list_entry_t *list = &(mm->mmap_list), *le;
c01077b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01077b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c01077b9:	eb 40                	jmp    c01077fb <mm_destroy+0x4e>
c01077bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01077be:	89 45 ec             	mov    %eax,-0x14(%ebp)
    __list_del(listelm->prev, listelm->next);
c01077c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01077c4:	8b 40 04             	mov    0x4(%eax),%eax
c01077c7:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01077ca:	8b 12                	mov    (%edx),%edx
c01077cc:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01077cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    prev->next = next;
c01077d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01077d5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01077d8:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01077db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01077de:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01077e1:	89 10                	mov    %edx,(%eax)
}
c01077e3:	90                   	nop
}
c01077e4:	90                   	nop
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
c01077e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01077e8:	83 e8 10             	sub    $0x10,%eax
c01077eb:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
c01077f2:	00 
c01077f3:	89 04 24             	mov    %eax,(%esp)
c01077f6:	e8 f4 e9 ff ff       	call   c01061ef <kfree>
c01077fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01077fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c0107801:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107804:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(list)) != list) {
c0107807:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010780a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010780d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0107810:	75 a9                	jne    c01077bb <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
c0107812:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
c0107819:	00 
c010781a:	8b 45 08             	mov    0x8(%ebp),%eax
c010781d:	89 04 24             	mov    %eax,(%esp)
c0107820:	e8 ca e9 ff ff       	call   c01061ef <kfree>
    mm=NULL;
c0107825:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c010782c:	90                   	nop
c010782d:	89 ec                	mov    %ebp,%esp
c010782f:	5d                   	pop    %ebp
c0107830:	c3                   	ret    

c0107831 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c0107831:	55                   	push   %ebp
c0107832:	89 e5                	mov    %esp,%ebp
c0107834:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c0107837:	e8 05 00 00 00       	call   c0107841 <check_vmm>
}
c010783c:	90                   	nop
c010783d:	89 ec                	mov    %ebp,%esp
c010783f:	5d                   	pop    %ebp
c0107840:	c3                   	ret    

c0107841 <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c0107841:	55                   	push   %ebp
c0107842:	89 e5                	mov    %esp,%ebp
c0107844:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0107847:	e8 b9 d1 ff ff       	call   c0104a05 <nr_free_pages>
c010784c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c010784f:	e8 44 00 00 00       	call   c0107898 <check_vma_struct>
    check_pgfault();
c0107854:	e8 01 05 00 00       	call   c0107d5a <check_pgfault>

    assert(nr_free_pages_store == nr_free_pages());
c0107859:	e8 a7 d1 ff ff       	call   c0104a05 <nr_free_pages>
c010785e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0107861:	74 24                	je     c0107887 <check_vmm+0x46>
c0107863:	c7 44 24 0c ec a9 10 	movl   $0xc010a9ec,0xc(%esp)
c010786a:	c0 
c010786b:	c7 44 24 08 6b a9 10 	movl   $0xc010a96b,0x8(%esp)
c0107872:	c0 
c0107873:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
c010787a:	00 
c010787b:	c7 04 24 80 a9 10 c0 	movl   $0xc010a980,(%esp)
c0107882:	e8 87 94 ff ff       	call   c0100d0e <__panic>

    cprintf("check_vmm() succeeded.\n");
c0107887:	c7 04 24 13 aa 10 c0 	movl   $0xc010aa13,(%esp)
c010788e:	e8 d2 8a ff ff       	call   c0100365 <cprintf>
}
c0107893:	90                   	nop
c0107894:	89 ec                	mov    %ebp,%esp
c0107896:	5d                   	pop    %ebp
c0107897:	c3                   	ret    

c0107898 <check_vma_struct>:

static void
check_vma_struct(void) {
c0107898:	55                   	push   %ebp
c0107899:	89 e5                	mov    %esp,%ebp
c010789b:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c010789e:	e8 62 d1 ff ff       	call   c0104a05 <nr_free_pages>
c01078a3:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c01078a6:	e8 ba fb ff ff       	call   c0107465 <mm_create>
c01078ab:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c01078ae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01078b2:	75 24                	jne    c01078d8 <check_vma_struct+0x40>
c01078b4:	c7 44 24 0c 2b aa 10 	movl   $0xc010aa2b,0xc(%esp)
c01078bb:	c0 
c01078bc:	c7 44 24 08 6b a9 10 	movl   $0xc010a96b,0x8(%esp)
c01078c3:	c0 
c01078c4:	c7 44 24 04 b8 00 00 	movl   $0xb8,0x4(%esp)
c01078cb:	00 
c01078cc:	c7 04 24 80 a9 10 c0 	movl   $0xc010a980,(%esp)
c01078d3:	e8 36 94 ff ff       	call   c0100d0e <__panic>

    int step1 = 10, step2 = step1 * 10;
c01078d8:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c01078df:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01078e2:	89 d0                	mov    %edx,%eax
c01078e4:	c1 e0 02             	shl    $0x2,%eax
c01078e7:	01 d0                	add    %edx,%eax
c01078e9:	01 c0                	add    %eax,%eax
c01078eb:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c01078ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01078f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01078f4:	eb 6f                	jmp    c0107965 <check_vma_struct+0xcd>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c01078f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01078f9:	89 d0                	mov    %edx,%eax
c01078fb:	c1 e0 02             	shl    $0x2,%eax
c01078fe:	01 d0                	add    %edx,%eax
c0107900:	83 c0 02             	add    $0x2,%eax
c0107903:	89 c1                	mov    %eax,%ecx
c0107905:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107908:	89 d0                	mov    %edx,%eax
c010790a:	c1 e0 02             	shl    $0x2,%eax
c010790d:	01 d0                	add    %edx,%eax
c010790f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107916:	00 
c0107917:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c010791b:	89 04 24             	mov    %eax,(%esp)
c010791e:	e8 bd fb ff ff       	call   c01074e0 <vma_create>
c0107923:	89 45 bc             	mov    %eax,-0x44(%ebp)
        assert(vma != NULL);
c0107926:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c010792a:	75 24                	jne    c0107950 <check_vma_struct+0xb8>
c010792c:	c7 44 24 0c 36 aa 10 	movl   $0xc010aa36,0xc(%esp)
c0107933:	c0 
c0107934:	c7 44 24 08 6b a9 10 	movl   $0xc010a96b,0x8(%esp)
c010793b:	c0 
c010793c:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
c0107943:	00 
c0107944:	c7 04 24 80 a9 10 c0 	movl   $0xc010a980,(%esp)
c010794b:	e8 be 93 ff ff       	call   c0100d0e <__panic>
        insert_vma_struct(mm, vma);
c0107950:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0107953:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107957:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010795a:	89 04 24             	mov    %eax,(%esp)
c010795d:	e8 15 fd ff ff       	call   c0107677 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
c0107962:	ff 4d f4             	decl   -0xc(%ebp)
c0107965:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107969:	7f 8b                	jg     c01078f6 <check_vma_struct+0x5e>
    }

    for (i = step1 + 1; i <= step2; i ++) {
c010796b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010796e:	40                   	inc    %eax
c010796f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107972:	eb 6f                	jmp    c01079e3 <check_vma_struct+0x14b>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0107974:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107977:	89 d0                	mov    %edx,%eax
c0107979:	c1 e0 02             	shl    $0x2,%eax
c010797c:	01 d0                	add    %edx,%eax
c010797e:	83 c0 02             	add    $0x2,%eax
c0107981:	89 c1                	mov    %eax,%ecx
c0107983:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107986:	89 d0                	mov    %edx,%eax
c0107988:	c1 e0 02             	shl    $0x2,%eax
c010798b:	01 d0                	add    %edx,%eax
c010798d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107994:	00 
c0107995:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0107999:	89 04 24             	mov    %eax,(%esp)
c010799c:	e8 3f fb ff ff       	call   c01074e0 <vma_create>
c01079a1:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma != NULL);
c01079a4:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c01079a8:	75 24                	jne    c01079ce <check_vma_struct+0x136>
c01079aa:	c7 44 24 0c 36 aa 10 	movl   $0xc010aa36,0xc(%esp)
c01079b1:	c0 
c01079b2:	c7 44 24 08 6b a9 10 	movl   $0xc010a96b,0x8(%esp)
c01079b9:	c0 
c01079ba:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
c01079c1:	00 
c01079c2:	c7 04 24 80 a9 10 c0 	movl   $0xc010a980,(%esp)
c01079c9:	e8 40 93 ff ff       	call   c0100d0e <__panic>
        insert_vma_struct(mm, vma);
c01079ce:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01079d1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01079d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01079d8:	89 04 24             	mov    %eax,(%esp)
c01079db:	e8 97 fc ff ff       	call   c0107677 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
c01079e0:	ff 45 f4             	incl   -0xc(%ebp)
c01079e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01079e6:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01079e9:	7e 89                	jle    c0107974 <check_vma_struct+0xdc>
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c01079eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01079ee:	89 45 b8             	mov    %eax,-0x48(%ebp)
c01079f1:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01079f4:	8b 40 04             	mov    0x4(%eax),%eax
c01079f7:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c01079fa:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c0107a01:	e9 96 00 00 00       	jmp    c0107a9c <check_vma_struct+0x204>
        assert(le != &(mm->mmap_list));
c0107a06:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107a09:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0107a0c:	75 24                	jne    c0107a32 <check_vma_struct+0x19a>
c0107a0e:	c7 44 24 0c 42 aa 10 	movl   $0xc010aa42,0xc(%esp)
c0107a15:	c0 
c0107a16:	c7 44 24 08 6b a9 10 	movl   $0xc010a96b,0x8(%esp)
c0107a1d:	c0 
c0107a1e:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c0107a25:	00 
c0107a26:	c7 04 24 80 a9 10 c0 	movl   $0xc010a980,(%esp)
c0107a2d:	e8 dc 92 ff ff       	call   c0100d0e <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c0107a32:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107a35:	83 e8 10             	sub    $0x10,%eax
c0107a38:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c0107a3b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0107a3e:	8b 48 04             	mov    0x4(%eax),%ecx
c0107a41:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107a44:	89 d0                	mov    %edx,%eax
c0107a46:	c1 e0 02             	shl    $0x2,%eax
c0107a49:	01 d0                	add    %edx,%eax
c0107a4b:	39 c1                	cmp    %eax,%ecx
c0107a4d:	75 17                	jne    c0107a66 <check_vma_struct+0x1ce>
c0107a4f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0107a52:	8b 48 08             	mov    0x8(%eax),%ecx
c0107a55:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107a58:	89 d0                	mov    %edx,%eax
c0107a5a:	c1 e0 02             	shl    $0x2,%eax
c0107a5d:	01 d0                	add    %edx,%eax
c0107a5f:	83 c0 02             	add    $0x2,%eax
c0107a62:	39 c1                	cmp    %eax,%ecx
c0107a64:	74 24                	je     c0107a8a <check_vma_struct+0x1f2>
c0107a66:	c7 44 24 0c 5c aa 10 	movl   $0xc010aa5c,0xc(%esp)
c0107a6d:	c0 
c0107a6e:	c7 44 24 08 6b a9 10 	movl   $0xc010a96b,0x8(%esp)
c0107a75:	c0 
c0107a76:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0107a7d:	00 
c0107a7e:	c7 04 24 80 a9 10 c0 	movl   $0xc010a980,(%esp)
c0107a85:	e8 84 92 ff ff       	call   c0100d0e <__panic>
c0107a8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107a8d:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0107a90:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0107a93:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0107a96:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (i = 1; i <= step2; i ++) {
c0107a99:	ff 45 f4             	incl   -0xc(%ebp)
c0107a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a9f:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0107aa2:	0f 8e 5e ff ff ff    	jle    c0107a06 <check_vma_struct+0x16e>
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0107aa8:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c0107aaf:	e9 cb 01 00 00       	jmp    c0107c7f <check_vma_struct+0x3e7>
        struct vma_struct *vma1 = find_vma(mm, i);
c0107ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ab7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107abb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107abe:	89 04 24             	mov    %eax,(%esp)
c0107ac1:	e8 57 fa ff ff       	call   c010751d <find_vma>
c0107ac6:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma1 != NULL);
c0107ac9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0107acd:	75 24                	jne    c0107af3 <check_vma_struct+0x25b>
c0107acf:	c7 44 24 0c 91 aa 10 	movl   $0xc010aa91,0xc(%esp)
c0107ad6:	c0 
c0107ad7:	c7 44 24 08 6b a9 10 	movl   $0xc010a96b,0x8(%esp)
c0107ade:	c0 
c0107adf:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c0107ae6:	00 
c0107ae7:	c7 04 24 80 a9 10 c0 	movl   $0xc010a980,(%esp)
c0107aee:	e8 1b 92 ff ff       	call   c0100d0e <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c0107af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107af6:	40                   	inc    %eax
c0107af7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107afb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107afe:	89 04 24             	mov    %eax,(%esp)
c0107b01:	e8 17 fa ff ff       	call   c010751d <find_vma>
c0107b06:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(vma2 != NULL);
c0107b09:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0107b0d:	75 24                	jne    c0107b33 <check_vma_struct+0x29b>
c0107b0f:	c7 44 24 0c 9e aa 10 	movl   $0xc010aa9e,0xc(%esp)
c0107b16:	c0 
c0107b17:	c7 44 24 08 6b a9 10 	movl   $0xc010a96b,0x8(%esp)
c0107b1e:	c0 
c0107b1f:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0107b26:	00 
c0107b27:	c7 04 24 80 a9 10 c0 	movl   $0xc010a980,(%esp)
c0107b2e:	e8 db 91 ff ff       	call   c0100d0e <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c0107b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107b36:	83 c0 02             	add    $0x2,%eax
c0107b39:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107b3d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107b40:	89 04 24             	mov    %eax,(%esp)
c0107b43:	e8 d5 f9 ff ff       	call   c010751d <find_vma>
c0107b48:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma3 == NULL);
c0107b4b:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0107b4f:	74 24                	je     c0107b75 <check_vma_struct+0x2dd>
c0107b51:	c7 44 24 0c ab aa 10 	movl   $0xc010aaab,0xc(%esp)
c0107b58:	c0 
c0107b59:	c7 44 24 08 6b a9 10 	movl   $0xc010a96b,0x8(%esp)
c0107b60:	c0 
c0107b61:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
c0107b68:	00 
c0107b69:	c7 04 24 80 a9 10 c0 	movl   $0xc010a980,(%esp)
c0107b70:	e8 99 91 ff ff       	call   c0100d0e <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c0107b75:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107b78:	83 c0 03             	add    $0x3,%eax
c0107b7b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107b7f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107b82:	89 04 24             	mov    %eax,(%esp)
c0107b85:	e8 93 f9 ff ff       	call   c010751d <find_vma>
c0107b8a:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma4 == NULL);
c0107b8d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0107b91:	74 24                	je     c0107bb7 <check_vma_struct+0x31f>
c0107b93:	c7 44 24 0c b8 aa 10 	movl   $0xc010aab8,0xc(%esp)
c0107b9a:	c0 
c0107b9b:	c7 44 24 08 6b a9 10 	movl   $0xc010a96b,0x8(%esp)
c0107ba2:	c0 
c0107ba3:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c0107baa:	00 
c0107bab:	c7 04 24 80 a9 10 c0 	movl   $0xc010a980,(%esp)
c0107bb2:	e8 57 91 ff ff       	call   c0100d0e <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c0107bb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107bba:	83 c0 04             	add    $0x4,%eax
c0107bbd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107bc1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107bc4:	89 04 24             	mov    %eax,(%esp)
c0107bc7:	e8 51 f9 ff ff       	call   c010751d <find_vma>
c0107bcc:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma5 == NULL);
c0107bcf:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0107bd3:	74 24                	je     c0107bf9 <check_vma_struct+0x361>
c0107bd5:	c7 44 24 0c c5 aa 10 	movl   $0xc010aac5,0xc(%esp)
c0107bdc:	c0 
c0107bdd:	c7 44 24 08 6b a9 10 	movl   $0xc010a96b,0x8(%esp)
c0107be4:	c0 
c0107be5:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c0107bec:	00 
c0107bed:	c7 04 24 80 a9 10 c0 	movl   $0xc010a980,(%esp)
c0107bf4:	e8 15 91 ff ff       	call   c0100d0e <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c0107bf9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107bfc:	8b 50 04             	mov    0x4(%eax),%edx
c0107bff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c02:	39 c2                	cmp    %eax,%edx
c0107c04:	75 10                	jne    c0107c16 <check_vma_struct+0x37e>
c0107c06:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107c09:	8b 40 08             	mov    0x8(%eax),%eax
c0107c0c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107c0f:	83 c2 02             	add    $0x2,%edx
c0107c12:	39 d0                	cmp    %edx,%eax
c0107c14:	74 24                	je     c0107c3a <check_vma_struct+0x3a2>
c0107c16:	c7 44 24 0c d4 aa 10 	movl   $0xc010aad4,0xc(%esp)
c0107c1d:	c0 
c0107c1e:	c7 44 24 08 6b a9 10 	movl   $0xc010a96b,0x8(%esp)
c0107c25:	c0 
c0107c26:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c0107c2d:	00 
c0107c2e:	c7 04 24 80 a9 10 c0 	movl   $0xc010a980,(%esp)
c0107c35:	e8 d4 90 ff ff       	call   c0100d0e <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c0107c3a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107c3d:	8b 50 04             	mov    0x4(%eax),%edx
c0107c40:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c43:	39 c2                	cmp    %eax,%edx
c0107c45:	75 10                	jne    c0107c57 <check_vma_struct+0x3bf>
c0107c47:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107c4a:	8b 40 08             	mov    0x8(%eax),%eax
c0107c4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107c50:	83 c2 02             	add    $0x2,%edx
c0107c53:	39 d0                	cmp    %edx,%eax
c0107c55:	74 24                	je     c0107c7b <check_vma_struct+0x3e3>
c0107c57:	c7 44 24 0c 04 ab 10 	movl   $0xc010ab04,0xc(%esp)
c0107c5e:	c0 
c0107c5f:	c7 44 24 08 6b a9 10 	movl   $0xc010a96b,0x8(%esp)
c0107c66:	c0 
c0107c67:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
c0107c6e:	00 
c0107c6f:	c7 04 24 80 a9 10 c0 	movl   $0xc010a980,(%esp)
c0107c76:	e8 93 90 ff ff       	call   c0100d0e <__panic>
    for (i = 5; i <= 5 * step2; i +=5) {
c0107c7b:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c0107c7f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107c82:	89 d0                	mov    %edx,%eax
c0107c84:	c1 e0 02             	shl    $0x2,%eax
c0107c87:	01 d0                	add    %edx,%eax
c0107c89:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0107c8c:	0f 8e 22 fe ff ff    	jle    c0107ab4 <check_vma_struct+0x21c>
    }

    for (i =4; i>=0; i--) {
c0107c92:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0107c99:	eb 6f                	jmp    c0107d0a <check_vma_struct+0x472>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c0107c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c9e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107ca2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107ca5:	89 04 24             	mov    %eax,(%esp)
c0107ca8:	e8 70 f8 ff ff       	call   c010751d <find_vma>
c0107cad:	89 45 dc             	mov    %eax,-0x24(%ebp)
        if (vma_below_5 != NULL ) {
c0107cb0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0107cb4:	74 27                	je     c0107cdd <check_vma_struct+0x445>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c0107cb6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107cb9:	8b 50 08             	mov    0x8(%eax),%edx
c0107cbc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107cbf:	8b 40 04             	mov    0x4(%eax),%eax
c0107cc2:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0107cc6:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ccd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107cd1:	c7 04 24 34 ab 10 c0 	movl   $0xc010ab34,(%esp)
c0107cd8:	e8 88 86 ff ff       	call   c0100365 <cprintf>
        }
        assert(vma_below_5 == NULL);
c0107cdd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0107ce1:	74 24                	je     c0107d07 <check_vma_struct+0x46f>
c0107ce3:	c7 44 24 0c 59 ab 10 	movl   $0xc010ab59,0xc(%esp)
c0107cea:	c0 
c0107ceb:	c7 44 24 08 6b a9 10 	movl   $0xc010a96b,0x8(%esp)
c0107cf2:	c0 
c0107cf3:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c0107cfa:	00 
c0107cfb:	c7 04 24 80 a9 10 c0 	movl   $0xc010a980,(%esp)
c0107d02:	e8 07 90 ff ff       	call   c0100d0e <__panic>
    for (i =4; i>=0; i--) {
c0107d07:	ff 4d f4             	decl   -0xc(%ebp)
c0107d0a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107d0e:	79 8b                	jns    c0107c9b <check_vma_struct+0x403>
    }

    mm_destroy(mm);
c0107d10:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107d13:	89 04 24             	mov    %eax,(%esp)
c0107d16:	e8 92 fa ff ff       	call   c01077ad <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
c0107d1b:	e8 e5 cc ff ff       	call   c0104a05 <nr_free_pages>
c0107d20:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0107d23:	74 24                	je     c0107d49 <check_vma_struct+0x4b1>
c0107d25:	c7 44 24 0c ec a9 10 	movl   $0xc010a9ec,0xc(%esp)
c0107d2c:	c0 
c0107d2d:	c7 44 24 08 6b a9 10 	movl   $0xc010a96b,0x8(%esp)
c0107d34:	c0 
c0107d35:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
c0107d3c:	00 
c0107d3d:	c7 04 24 80 a9 10 c0 	movl   $0xc010a980,(%esp)
c0107d44:	e8 c5 8f ff ff       	call   c0100d0e <__panic>

    cprintf("check_vma_struct() succeeded!\n");
c0107d49:	c7 04 24 70 ab 10 c0 	movl   $0xc010ab70,(%esp)
c0107d50:	e8 10 86 ff ff       	call   c0100365 <cprintf>
}
c0107d55:	90                   	nop
c0107d56:	89 ec                	mov    %ebp,%esp
c0107d58:	5d                   	pop    %ebp
c0107d59:	c3                   	ret    

c0107d5a <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c0107d5a:	55                   	push   %ebp
c0107d5b:	89 e5                	mov    %esp,%ebp
c0107d5d:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0107d60:	e8 a0 cc ff ff       	call   c0104a05 <nr_free_pages>
c0107d65:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c0107d68:	e8 f8 f6 ff ff       	call   c0107465 <mm_create>
c0107d6d:	a3 0c 71 12 c0       	mov    %eax,0xc012710c
    assert(check_mm_struct != NULL);
c0107d72:	a1 0c 71 12 c0       	mov    0xc012710c,%eax
c0107d77:	85 c0                	test   %eax,%eax
c0107d79:	75 24                	jne    c0107d9f <check_pgfault+0x45>
c0107d7b:	c7 44 24 0c 8f ab 10 	movl   $0xc010ab8f,0xc(%esp)
c0107d82:	c0 
c0107d83:	c7 44 24 08 6b a9 10 	movl   $0xc010a96b,0x8(%esp)
c0107d8a:	c0 
c0107d8b:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c0107d92:	00 
c0107d93:	c7 04 24 80 a9 10 c0 	movl   $0xc010a980,(%esp)
c0107d9a:	e8 6f 8f ff ff       	call   c0100d0e <__panic>

    struct mm_struct *mm = check_mm_struct;
c0107d9f:	a1 0c 71 12 c0       	mov    0xc012710c,%eax
c0107da4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0107da7:	8b 15 e0 39 12 c0    	mov    0xc01239e0,%edx
c0107dad:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107db0:	89 50 0c             	mov    %edx,0xc(%eax)
c0107db3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107db6:	8b 40 0c             	mov    0xc(%eax),%eax
c0107db9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c0107dbc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107dbf:	8b 00                	mov    (%eax),%eax
c0107dc1:	85 c0                	test   %eax,%eax
c0107dc3:	74 24                	je     c0107de9 <check_pgfault+0x8f>
c0107dc5:	c7 44 24 0c a7 ab 10 	movl   $0xc010aba7,0xc(%esp)
c0107dcc:	c0 
c0107dcd:	c7 44 24 08 6b a9 10 	movl   $0xc010a96b,0x8(%esp)
c0107dd4:	c0 
c0107dd5:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
c0107ddc:	00 
c0107ddd:	c7 04 24 80 a9 10 c0 	movl   $0xc010a980,(%esp)
c0107de4:	e8 25 8f ff ff       	call   c0100d0e <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c0107de9:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c0107df0:	00 
c0107df1:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c0107df8:	00 
c0107df9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0107e00:	e8 db f6 ff ff       	call   c01074e0 <vma_create>
c0107e05:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c0107e08:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0107e0c:	75 24                	jne    c0107e32 <check_pgfault+0xd8>
c0107e0e:	c7 44 24 0c 36 aa 10 	movl   $0xc010aa36,0xc(%esp)
c0107e15:	c0 
c0107e16:	c7 44 24 08 6b a9 10 	movl   $0xc010a96b,0x8(%esp)
c0107e1d:	c0 
c0107e1e:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c0107e25:	00 
c0107e26:	c7 04 24 80 a9 10 c0 	movl   $0xc010a980,(%esp)
c0107e2d:	e8 dc 8e ff ff       	call   c0100d0e <__panic>

    insert_vma_struct(mm, vma);
c0107e32:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107e35:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107e39:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107e3c:	89 04 24             	mov    %eax,(%esp)
c0107e3f:	e8 33 f8 ff ff       	call   c0107677 <insert_vma_struct>

    uintptr_t addr = 0x100;
c0107e44:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c0107e4b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107e4e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107e52:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107e55:	89 04 24             	mov    %eax,(%esp)
c0107e58:	e8 c0 f6 ff ff       	call   c010751d <find_vma>
c0107e5d:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0107e60:	74 24                	je     c0107e86 <check_pgfault+0x12c>
c0107e62:	c7 44 24 0c b5 ab 10 	movl   $0xc010abb5,0xc(%esp)
c0107e69:	c0 
c0107e6a:	c7 44 24 08 6b a9 10 	movl   $0xc010a96b,0x8(%esp)
c0107e71:	c0 
c0107e72:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
c0107e79:	00 
c0107e7a:	c7 04 24 80 a9 10 c0 	movl   $0xc010a980,(%esp)
c0107e81:	e8 88 8e ff ff       	call   c0100d0e <__panic>

    int i, sum = 0;
c0107e86:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0107e8d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0107e94:	eb 16                	jmp    c0107eac <check_pgfault+0x152>
        *(char *)(addr + i) = i;
c0107e96:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107e99:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107e9c:	01 d0                	add    %edx,%eax
c0107e9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107ea1:	88 10                	mov    %dl,(%eax)
        sum += i;
c0107ea3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ea6:	01 45 f0             	add    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0107ea9:	ff 45 f4             	incl   -0xc(%ebp)
c0107eac:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0107eb0:	7e e4                	jle    c0107e96 <check_pgfault+0x13c>
    }
    for (i = 0; i < 100; i ++) {
c0107eb2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0107eb9:	eb 14                	jmp    c0107ecf <check_pgfault+0x175>
        sum -= *(char *)(addr + i);
c0107ebb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107ebe:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107ec1:	01 d0                	add    %edx,%eax
c0107ec3:	0f b6 00             	movzbl (%eax),%eax
c0107ec6:	0f be c0             	movsbl %al,%eax
c0107ec9:	29 45 f0             	sub    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0107ecc:	ff 45 f4             	incl   -0xc(%ebp)
c0107ecf:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0107ed3:	7e e6                	jle    c0107ebb <check_pgfault+0x161>
    }
    assert(sum == 0);
c0107ed5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107ed9:	74 24                	je     c0107eff <check_pgfault+0x1a5>
c0107edb:	c7 44 24 0c cf ab 10 	movl   $0xc010abcf,0xc(%esp)
c0107ee2:	c0 
c0107ee3:	c7 44 24 08 6b a9 10 	movl   $0xc010a96b,0x8(%esp)
c0107eea:	c0 
c0107eeb:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
c0107ef2:	00 
c0107ef3:	c7 04 24 80 a9 10 c0 	movl   $0xc010a980,(%esp)
c0107efa:	e8 0f 8e ff ff       	call   c0100d0e <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c0107eff:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107f02:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0107f05:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107f08:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107f0d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107f11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107f14:	89 04 24             	mov    %eax,(%esp)
c0107f17:	e8 5b d3 ff ff       	call   c0105277 <page_remove>
    free_page(pde2page(pgdir[0]));
c0107f1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107f1f:	8b 00                	mov    (%eax),%eax
c0107f21:	89 04 24             	mov    %eax,(%esp)
c0107f24:	e8 22 f5 ff ff       	call   c010744b <pde2page>
c0107f29:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107f30:	00 
c0107f31:	89 04 24             	mov    %eax,(%esp)
c0107f34:	e8 97 ca ff ff       	call   c01049d0 <free_pages>
    pgdir[0] = 0;
c0107f39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107f3c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c0107f42:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107f45:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c0107f4c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107f4f:	89 04 24             	mov    %eax,(%esp)
c0107f52:	e8 56 f8 ff ff       	call   c01077ad <mm_destroy>
    check_mm_struct = NULL;
c0107f57:	c7 05 0c 71 12 c0 00 	movl   $0x0,0xc012710c
c0107f5e:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c0107f61:	e8 9f ca ff ff       	call   c0104a05 <nr_free_pages>
c0107f66:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0107f69:	74 24                	je     c0107f8f <check_pgfault+0x235>
c0107f6b:	c7 44 24 0c ec a9 10 	movl   $0xc010a9ec,0xc(%esp)
c0107f72:	c0 
c0107f73:	c7 44 24 08 6b a9 10 	movl   $0xc010a96b,0x8(%esp)
c0107f7a:	c0 
c0107f7b:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c0107f82:	00 
c0107f83:	c7 04 24 80 a9 10 c0 	movl   $0xc010a980,(%esp)
c0107f8a:	e8 7f 8d ff ff       	call   c0100d0e <__panic>

    cprintf("check_pgfault() succeeded!\n");
c0107f8f:	c7 04 24 d8 ab 10 c0 	movl   $0xc010abd8,(%esp)
c0107f96:	e8 ca 83 ff ff       	call   c0100365 <cprintf>
}
c0107f9b:	90                   	nop
c0107f9c:	89 ec                	mov    %ebp,%esp
c0107f9e:	5d                   	pop    %ebp
c0107f9f:	c3                   	ret    

c0107fa0 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c0107fa0:	55                   	push   %ebp
c0107fa1:	89 e5                	mov    %esp,%ebp
c0107fa3:	83 ec 38             	sub    $0x38,%esp
    //应该返回不同类型的错误，只有为0时才正确执行函数
    int ret = -E_INVAL;
c0107fa6:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c0107fad:	8b 45 10             	mov    0x10(%ebp),%eax
c0107fb0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107fb4:	8b 45 08             	mov    0x8(%ebp),%eax
c0107fb7:	89 04 24             	mov    %eax,(%esp)
c0107fba:	e8 5e f5 ff ff       	call   c010751d <find_vma>
c0107fbf:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c0107fc2:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c0107fc7:	40                   	inc    %eax
c0107fc8:	a3 10 71 12 c0       	mov    %eax,0xc0127110
    //If the addr is in the range of a mm's vma?个人感觉||之后的好像没有必要
    if (vma == NULL || vma->vm_start > addr) {
c0107fcd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107fd1:	74 0b                	je     c0107fde <do_pgfault+0x3e>
c0107fd3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107fd6:	8b 40 04             	mov    0x4(%eax),%eax
c0107fd9:	39 45 10             	cmp    %eax,0x10(%ebp)
c0107fdc:	73 18                	jae    c0107ff6 <do_pgfault+0x56>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c0107fde:	8b 45 10             	mov    0x10(%ebp),%eax
c0107fe1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107fe5:	c7 04 24 f4 ab 10 c0 	movl   $0xc010abf4,(%esp)
c0107fec:	e8 74 83 ff ff       	call   c0100365 <cprintf>
        goto failed;
c0107ff1:	e9 ba 01 00 00       	jmp    c01081b0 <do_pgfault+0x210>
    }
    //check the error_code
    switch (error_code & 3) {
c0107ff6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107ff9:	83 e0 03             	and    $0x3,%eax
c0107ffc:	85 c0                	test   %eax,%eax
c0107ffe:	74 34                	je     c0108034 <do_pgfault+0x94>
c0108000:	83 f8 01             	cmp    $0x1,%eax
c0108003:	74 1e                	je     c0108023 <do_pgfault+0x83>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
            //表示写异常且对应的页表存在，个人推测可能是对应的物理内存页被换出了，还有可能就是页表项为0
    case 2: /* error code flag : (W/R=1, P=0): write, not present */ //表示写时发生的异常，对应的页表物理页不存在
        if (!(vma->vm_flags & VM_WRITE)) { //如果虚拟地址不可写
c0108005:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108008:	8b 40 0c             	mov    0xc(%eax),%eax
c010800b:	83 e0 02             	and    $0x2,%eax
c010800e:	85 c0                	test   %eax,%eax
c0108010:	75 40                	jne    c0108052 <do_pgfault+0xb2>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c0108012:	c7 04 24 24 ac 10 c0 	movl   $0xc010ac24,(%esp)
c0108019:	e8 47 83 ff ff       	call   c0100365 <cprintf>
            goto failed;
c010801e:	e9 8d 01 00 00       	jmp    c01081b0 <do_pgfault+0x210>
        }
        break;
    case 1: /* error code flag : (W/R=0, P=1): read, present */ //表示读异常，对应的物理页存在
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c0108023:	c7 04 24 84 ac 10 c0 	movl   $0xc010ac84,(%esp)
c010802a:	e8 36 83 ff ff       	call   c0100365 <cprintf>
        goto failed;
c010802f:	e9 7c 01 00 00       	jmp    c01081b0 <do_pgfault+0x210>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */ //表示读异常，对应的物理页不存在
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) { //如果虚拟地址不可读或是不可执行
c0108034:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108037:	8b 40 0c             	mov    0xc(%eax),%eax
c010803a:	83 e0 05             	and    $0x5,%eax
c010803d:	85 c0                	test   %eax,%eax
c010803f:	75 12                	jne    c0108053 <do_pgfault+0xb3>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c0108041:	c7 04 24 bc ac 10 c0 	movl   $0xc010acbc,(%esp)
c0108048:	e8 18 83 ff ff       	call   c0100365 <cprintf>
            goto failed;
c010804d:	e9 5e 01 00 00       	jmp    c01081b0 <do_pgfault+0x210>
        break;
c0108052:	90                   	nop
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c0108053:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c010805a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010805d:	8b 40 0c             	mov    0xc(%eax),%eax
c0108060:	83 e0 02             	and    $0x2,%eax
c0108063:	85 c0                	test   %eax,%eax
c0108065:	74 04                	je     c010806b <do_pgfault+0xcb>
        perm |= PTE_W;
c0108067:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    //找到虚拟页的基址
    addr = ROUNDDOWN(addr, PGSIZE);
c010806b:	8b 45 10             	mov    0x10(%ebp),%eax
c010806e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108071:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108074:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108079:	89 45 10             	mov    %eax,0x10(%ebp)

    //之后的错误是由于内存短缺引起的
    ret = -E_NO_MEM;
c010807c:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c0108083:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
            goto failed;
        }
   }
#endif

    if((ptep=get_pte(mm->pgdir,addr,1))==NULL)
c010808a:	8b 45 08             	mov    0x8(%ebp),%eax
c010808d:	8b 40 0c             	mov    0xc(%eax),%eax
c0108090:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0108097:	00 
c0108098:	8b 55 10             	mov    0x10(%ebp),%edx
c010809b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010809f:	89 04 24             	mov    %eax,(%esp)
c01080a2:	e8 72 cf ff ff       	call   c0105019 <get_pte>
c01080a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01080aa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01080ae:	75 11                	jne    c01080c1 <do_pgfault+0x121>
    {
        cprintf("get_pte in do_pgfault failed\n");
c01080b0:	c7 04 24 1f ad 10 c0 	movl   $0xc010ad1f,(%esp)
c01080b7:	e8 a9 82 ff ff       	call   c0100365 <cprintf>
        goto failed;
c01080bc:	e9 ef 00 00 00       	jmp    c01081b0 <do_pgfault+0x210>
    }
    if(*ptep==0)
c01080c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01080c4:	8b 00                	mov    (%eax),%eax
c01080c6:	85 c0                	test   %eax,%eax
c01080c8:	75 35                	jne    c01080ff <do_pgfault+0x15f>
    {
        if(pgdir_alloc_page(mm->pgdir,addr,perm)==NULL)
c01080ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01080cd:	8b 40 0c             	mov    0xc(%eax),%eax
c01080d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01080d3:	89 54 24 08          	mov    %edx,0x8(%esp)
c01080d7:	8b 55 10             	mov    0x10(%ebp),%edx
c01080da:	89 54 24 04          	mov    %edx,0x4(%esp)
c01080de:	89 04 24             	mov    %eax,(%esp)
c01080e1:	e8 f2 d2 ff ff       	call   c01053d8 <pgdir_alloc_page>
c01080e6:	85 c0                	test   %eax,%eax
c01080e8:	0f 85 bb 00 00 00    	jne    c01081a9 <do_pgfault+0x209>
        {
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
c01080ee:	c7 04 24 40 ad 10 c0 	movl   $0xc010ad40,(%esp)
c01080f5:	e8 6b 82 ff ff       	call   c0100365 <cprintf>
            goto failed;
c01080fa:	e9 b1 00 00 00       	jmp    c01081b0 <do_pgfault+0x210>
        
        }
    }
    else
    {
        if(swap_init_ok)
c01080ff:	a1 44 70 12 c0       	mov    0xc0127044,%eax
c0108104:	85 c0                	test   %eax,%eax
c0108106:	0f 84 86 00 00 00    	je     c0108192 <do_pgfault+0x1f2>
        {
            struct Page* page=NULL;
c010810c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            if ((ret = swap_in(mm, addr, &page)) != 0)
c0108113:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0108116:	89 44 24 08          	mov    %eax,0x8(%esp)
c010811a:	8b 45 10             	mov    0x10(%ebp),%eax
c010811d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108121:	8b 45 08             	mov    0x8(%ebp),%eax
c0108124:	89 04 24             	mov    %eax,(%esp)
c0108127:	e8 76 e4 ff ff       	call   c01065a2 <swap_in>
c010812c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010812f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108133:	74 0e                	je     c0108143 <do_pgfault+0x1a3>
            {
                cprintf("swap_in in do_pgfault failed\n");
c0108135:	c7 04 24 67 ad 10 c0 	movl   $0xc010ad67,(%esp)
c010813c:	e8 24 82 ff ff       	call   c0100365 <cprintf>
c0108141:	eb 6d                	jmp    c01081b0 <do_pgfault+0x210>
                goto failed;
            }  

            page_insert(mm->pgdir,page, addr,perm);
c0108143:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108146:	8b 45 08             	mov    0x8(%ebp),%eax
c0108149:	8b 40 0c             	mov    0xc(%eax),%eax
c010814c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010814f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0108153:	8b 4d 10             	mov    0x10(%ebp),%ecx
c0108156:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010815a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010815e:	89 04 24             	mov    %eax,(%esp)
c0108161:	e8 58 d1 ff ff       	call   c01052be <page_insert>
            swap_map_swappable(mm, addr, page, 1);
c0108166:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108169:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c0108170:	00 
c0108171:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108175:	8b 45 10             	mov    0x10(%ebp),%eax
c0108178:	89 44 24 04          	mov    %eax,0x4(%esp)
c010817c:	8b 45 08             	mov    0x8(%ebp),%eax
c010817f:	89 04 24             	mov    %eax,(%esp)
c0108182:	e8 53 e2 ff ff       	call   c01063da <swap_map_swappable>
            page->pra_vaddr= addr;
c0108187:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010818a:	8b 55 10             	mov    0x10(%ebp),%edx
c010818d:	89 50 1c             	mov    %edx,0x1c(%eax)
c0108190:	eb 17                	jmp    c01081a9 <do_pgfault+0x209>
        }
        else{
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
c0108192:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108195:	8b 00                	mov    (%eax),%eax
c0108197:	89 44 24 04          	mov    %eax,0x4(%esp)
c010819b:	c7 04 24 88 ad 10 c0 	movl   $0xc010ad88,(%esp)
c01081a2:	e8 be 81 ff ff       	call   c0100365 <cprintf>
            goto failed;
c01081a7:	eb 07                	jmp    c01081b0 <do_pgfault+0x210>
    }

   


   ret = 0;
c01081a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c01081b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01081b3:	89 ec                	mov    %ebp,%esp
c01081b5:	5d                   	pop    %ebp
c01081b6:	c3                   	ret    

c01081b7 <page2ppn>:
page2ppn(struct Page *page) {
c01081b7:	55                   	push   %ebp
c01081b8:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01081ba:	8b 15 a0 6f 12 c0    	mov    0xc0126fa0,%edx
c01081c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01081c3:	29 d0                	sub    %edx,%eax
c01081c5:	c1 f8 05             	sar    $0x5,%eax
}
c01081c8:	5d                   	pop    %ebp
c01081c9:	c3                   	ret    

c01081ca <page2pa>:
page2pa(struct Page *page) {
c01081ca:	55                   	push   %ebp
c01081cb:	89 e5                	mov    %esp,%ebp
c01081cd:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01081d0:	8b 45 08             	mov    0x8(%ebp),%eax
c01081d3:	89 04 24             	mov    %eax,(%esp)
c01081d6:	e8 dc ff ff ff       	call   c01081b7 <page2ppn>
c01081db:	c1 e0 0c             	shl    $0xc,%eax
}
c01081de:	89 ec                	mov    %ebp,%esp
c01081e0:	5d                   	pop    %ebp
c01081e1:	c3                   	ret    

c01081e2 <page2kva>:
page2kva(struct Page *page) {
c01081e2:	55                   	push   %ebp
c01081e3:	89 e5                	mov    %esp,%ebp
c01081e5:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01081e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01081eb:	89 04 24             	mov    %eax,(%esp)
c01081ee:	e8 d7 ff ff ff       	call   c01081ca <page2pa>
c01081f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01081f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01081f9:	c1 e8 0c             	shr    $0xc,%eax
c01081fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01081ff:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c0108204:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0108207:	72 23                	jb     c010822c <page2kva+0x4a>
c0108209:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010820c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108210:	c7 44 24 08 b0 ad 10 	movl   $0xc010adb0,0x8(%esp)
c0108217:	c0 
c0108218:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c010821f:	00 
c0108220:	c7 04 24 d3 ad 10 c0 	movl   $0xc010add3,(%esp)
c0108227:	e8 e2 8a ff ff       	call   c0100d0e <__panic>
c010822c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010822f:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0108234:	89 ec                	mov    %ebp,%esp
c0108236:	5d                   	pop    %ebp
c0108237:	c3                   	ret    

c0108238 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c0108238:	55                   	push   %ebp
c0108239:	89 e5                	mov    %esp,%ebp
c010823b:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c010823e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108245:	e8 73 98 ff ff       	call   c0101abd <ide_device_valid>
c010824a:	85 c0                	test   %eax,%eax
c010824c:	75 1c                	jne    c010826a <swapfs_init+0x32>
        panic("swap fs isn't available.\n");
c010824e:	c7 44 24 08 e1 ad 10 	movl   $0xc010ade1,0x8(%esp)
c0108255:	c0 
c0108256:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c010825d:	00 
c010825e:	c7 04 24 fb ad 10 c0 	movl   $0xc010adfb,(%esp)
c0108265:	e8 a4 8a ff ff       	call   c0100d0e <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c010826a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108271:	e8 87 98 ff ff       	call   c0101afd <ide_device_size>
c0108276:	c1 e8 03             	shr    $0x3,%eax
c0108279:	a3 40 70 12 c0       	mov    %eax,0xc0127040
}
c010827e:	90                   	nop
c010827f:	89 ec                	mov    %ebp,%esp
c0108281:	5d                   	pop    %ebp
c0108282:	c3                   	ret    

c0108283 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c0108283:	55                   	push   %ebp
c0108284:	89 e5                	mov    %esp,%ebp
c0108286:	83 ec 28             	sub    $0x28,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0108289:	8b 45 0c             	mov    0xc(%ebp),%eax
c010828c:	89 04 24             	mov    %eax,(%esp)
c010828f:	e8 4e ff ff ff       	call   c01081e2 <page2kva>
c0108294:	8b 55 08             	mov    0x8(%ebp),%edx
c0108297:	c1 ea 08             	shr    $0x8,%edx
c010829a:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010829d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01082a1:	74 0b                	je     c01082ae <swapfs_read+0x2b>
c01082a3:	8b 15 40 70 12 c0    	mov    0xc0127040,%edx
c01082a9:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c01082ac:	72 23                	jb     c01082d1 <swapfs_read+0x4e>
c01082ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01082b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01082b5:	c7 44 24 08 0c ae 10 	movl   $0xc010ae0c,0x8(%esp)
c01082bc:	c0 
c01082bd:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c01082c4:	00 
c01082c5:	c7 04 24 fb ad 10 c0 	movl   $0xc010adfb,(%esp)
c01082cc:	e8 3d 8a ff ff       	call   c0100d0e <__panic>
c01082d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01082d4:	c1 e2 03             	shl    $0x3,%edx
c01082d7:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c01082de:	00 
c01082df:	89 44 24 08          	mov    %eax,0x8(%esp)
c01082e3:	89 54 24 04          	mov    %edx,0x4(%esp)
c01082e7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01082ee:	e8 47 98 ff ff       	call   c0101b3a <ide_read_secs>
}
c01082f3:	89 ec                	mov    %ebp,%esp
c01082f5:	5d                   	pop    %ebp
c01082f6:	c3                   	ret    

c01082f7 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c01082f7:	55                   	push   %ebp
c01082f8:	89 e5                	mov    %esp,%ebp
c01082fa:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c01082fd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108300:	89 04 24             	mov    %eax,(%esp)
c0108303:	e8 da fe ff ff       	call   c01081e2 <page2kva>
c0108308:	8b 55 08             	mov    0x8(%ebp),%edx
c010830b:	c1 ea 08             	shr    $0x8,%edx
c010830e:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0108311:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108315:	74 0b                	je     c0108322 <swapfs_write+0x2b>
c0108317:	8b 15 40 70 12 c0    	mov    0xc0127040,%edx
c010831d:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0108320:	72 23                	jb     c0108345 <swapfs_write+0x4e>
c0108322:	8b 45 08             	mov    0x8(%ebp),%eax
c0108325:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108329:	c7 44 24 08 0c ae 10 	movl   $0xc010ae0c,0x8(%esp)
c0108330:	c0 
c0108331:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c0108338:	00 
c0108339:	c7 04 24 fb ad 10 c0 	movl   $0xc010adfb,(%esp)
c0108340:	e8 c9 89 ff ff       	call   c0100d0e <__panic>
c0108345:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108348:	c1 e2 03             	shl    $0x3,%edx
c010834b:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c0108352:	00 
c0108353:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108357:	89 54 24 04          	mov    %edx,0x4(%esp)
c010835b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108362:	e8 14 9a ff ff       	call   c0101d7b <ide_write_secs>
}
c0108367:	89 ec                	mov    %ebp,%esp
c0108369:	5d                   	pop    %ebp
c010836a:	c3                   	ret    

c010836b <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010836b:	55                   	push   %ebp
c010836c:	89 e5                	mov    %esp,%ebp
c010836e:	83 ec 58             	sub    $0x58,%esp
c0108371:	8b 45 10             	mov    0x10(%ebp),%eax
c0108374:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0108377:	8b 45 14             	mov    0x14(%ebp),%eax
c010837a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c010837d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108380:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0108383:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108386:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0108389:	8b 45 18             	mov    0x18(%ebp),%eax
c010838c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010838f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108392:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108395:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108398:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010839b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010839e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01083a1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01083a5:	74 1c                	je     c01083c3 <printnum+0x58>
c01083a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01083aa:	ba 00 00 00 00       	mov    $0x0,%edx
c01083af:	f7 75 e4             	divl   -0x1c(%ebp)
c01083b2:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01083b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01083b8:	ba 00 00 00 00       	mov    $0x0,%edx
c01083bd:	f7 75 e4             	divl   -0x1c(%ebp)
c01083c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01083c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01083c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01083c9:	f7 75 e4             	divl   -0x1c(%ebp)
c01083cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01083cf:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01083d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01083d5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01083d8:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01083db:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01083de:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01083e1:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c01083e4:	8b 45 18             	mov    0x18(%ebp),%eax
c01083e7:	ba 00 00 00 00       	mov    $0x0,%edx
c01083ec:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c01083ef:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c01083f2:	19 d1                	sbb    %edx,%ecx
c01083f4:	72 4c                	jb     c0108442 <printnum+0xd7>
        printnum(putch, putdat, result, base, width - 1, padc);
c01083f6:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01083f9:	8d 50 ff             	lea    -0x1(%eax),%edx
c01083fc:	8b 45 20             	mov    0x20(%ebp),%eax
c01083ff:	89 44 24 18          	mov    %eax,0x18(%esp)
c0108403:	89 54 24 14          	mov    %edx,0x14(%esp)
c0108407:	8b 45 18             	mov    0x18(%ebp),%eax
c010840a:	89 44 24 10          	mov    %eax,0x10(%esp)
c010840e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108411:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108414:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108418:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010841c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010841f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108423:	8b 45 08             	mov    0x8(%ebp),%eax
c0108426:	89 04 24             	mov    %eax,(%esp)
c0108429:	e8 3d ff ff ff       	call   c010836b <printnum>
c010842e:	eb 1b                	jmp    c010844b <printnum+0xe0>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0108430:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108433:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108437:	8b 45 20             	mov    0x20(%ebp),%eax
c010843a:	89 04 24             	mov    %eax,(%esp)
c010843d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108440:	ff d0                	call   *%eax
        while (-- width > 0)
c0108442:	ff 4d 1c             	decl   0x1c(%ebp)
c0108445:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0108449:	7f e5                	jg     c0108430 <printnum+0xc5>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c010844b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010844e:	05 ac ae 10 c0       	add    $0xc010aeac,%eax
c0108453:	0f b6 00             	movzbl (%eax),%eax
c0108456:	0f be c0             	movsbl %al,%eax
c0108459:	8b 55 0c             	mov    0xc(%ebp),%edx
c010845c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108460:	89 04 24             	mov    %eax,(%esp)
c0108463:	8b 45 08             	mov    0x8(%ebp),%eax
c0108466:	ff d0                	call   *%eax
}
c0108468:	90                   	nop
c0108469:	89 ec                	mov    %ebp,%esp
c010846b:	5d                   	pop    %ebp
c010846c:	c3                   	ret    

c010846d <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c010846d:	55                   	push   %ebp
c010846e:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0108470:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0108474:	7e 14                	jle    c010848a <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c0108476:	8b 45 08             	mov    0x8(%ebp),%eax
c0108479:	8b 00                	mov    (%eax),%eax
c010847b:	8d 48 08             	lea    0x8(%eax),%ecx
c010847e:	8b 55 08             	mov    0x8(%ebp),%edx
c0108481:	89 0a                	mov    %ecx,(%edx)
c0108483:	8b 50 04             	mov    0x4(%eax),%edx
c0108486:	8b 00                	mov    (%eax),%eax
c0108488:	eb 30                	jmp    c01084ba <getuint+0x4d>
    }
    else if (lflag) {
c010848a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010848e:	74 16                	je     c01084a6 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c0108490:	8b 45 08             	mov    0x8(%ebp),%eax
c0108493:	8b 00                	mov    (%eax),%eax
c0108495:	8d 48 04             	lea    0x4(%eax),%ecx
c0108498:	8b 55 08             	mov    0x8(%ebp),%edx
c010849b:	89 0a                	mov    %ecx,(%edx)
c010849d:	8b 00                	mov    (%eax),%eax
c010849f:	ba 00 00 00 00       	mov    $0x0,%edx
c01084a4:	eb 14                	jmp    c01084ba <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c01084a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01084a9:	8b 00                	mov    (%eax),%eax
c01084ab:	8d 48 04             	lea    0x4(%eax),%ecx
c01084ae:	8b 55 08             	mov    0x8(%ebp),%edx
c01084b1:	89 0a                	mov    %ecx,(%edx)
c01084b3:	8b 00                	mov    (%eax),%eax
c01084b5:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c01084ba:	5d                   	pop    %ebp
c01084bb:	c3                   	ret    

c01084bc <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c01084bc:	55                   	push   %ebp
c01084bd:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01084bf:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01084c3:	7e 14                	jle    c01084d9 <getint+0x1d>
        return va_arg(*ap, long long);
c01084c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01084c8:	8b 00                	mov    (%eax),%eax
c01084ca:	8d 48 08             	lea    0x8(%eax),%ecx
c01084cd:	8b 55 08             	mov    0x8(%ebp),%edx
c01084d0:	89 0a                	mov    %ecx,(%edx)
c01084d2:	8b 50 04             	mov    0x4(%eax),%edx
c01084d5:	8b 00                	mov    (%eax),%eax
c01084d7:	eb 28                	jmp    c0108501 <getint+0x45>
    }
    else if (lflag) {
c01084d9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01084dd:	74 12                	je     c01084f1 <getint+0x35>
        return va_arg(*ap, long);
c01084df:	8b 45 08             	mov    0x8(%ebp),%eax
c01084e2:	8b 00                	mov    (%eax),%eax
c01084e4:	8d 48 04             	lea    0x4(%eax),%ecx
c01084e7:	8b 55 08             	mov    0x8(%ebp),%edx
c01084ea:	89 0a                	mov    %ecx,(%edx)
c01084ec:	8b 00                	mov    (%eax),%eax
c01084ee:	99                   	cltd   
c01084ef:	eb 10                	jmp    c0108501 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c01084f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01084f4:	8b 00                	mov    (%eax),%eax
c01084f6:	8d 48 04             	lea    0x4(%eax),%ecx
c01084f9:	8b 55 08             	mov    0x8(%ebp),%edx
c01084fc:	89 0a                	mov    %ecx,(%edx)
c01084fe:	8b 00                	mov    (%eax),%eax
c0108500:	99                   	cltd   
    }
}
c0108501:	5d                   	pop    %ebp
c0108502:	c3                   	ret    

c0108503 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c0108503:	55                   	push   %ebp
c0108504:	89 e5                	mov    %esp,%ebp
c0108506:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0108509:	8d 45 14             	lea    0x14(%ebp),%eax
c010850c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c010850f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108512:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108516:	8b 45 10             	mov    0x10(%ebp),%eax
c0108519:	89 44 24 08          	mov    %eax,0x8(%esp)
c010851d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108520:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108524:	8b 45 08             	mov    0x8(%ebp),%eax
c0108527:	89 04 24             	mov    %eax,(%esp)
c010852a:	e8 05 00 00 00       	call   c0108534 <vprintfmt>
    va_end(ap);
}
c010852f:	90                   	nop
c0108530:	89 ec                	mov    %ebp,%esp
c0108532:	5d                   	pop    %ebp
c0108533:	c3                   	ret    

c0108534 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0108534:	55                   	push   %ebp
c0108535:	89 e5                	mov    %esp,%ebp
c0108537:	56                   	push   %esi
c0108538:	53                   	push   %ebx
c0108539:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010853c:	eb 17                	jmp    c0108555 <vprintfmt+0x21>
            if (ch == '\0') {
c010853e:	85 db                	test   %ebx,%ebx
c0108540:	0f 84 bf 03 00 00    	je     c0108905 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c0108546:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108549:	89 44 24 04          	mov    %eax,0x4(%esp)
c010854d:	89 1c 24             	mov    %ebx,(%esp)
c0108550:	8b 45 08             	mov    0x8(%ebp),%eax
c0108553:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0108555:	8b 45 10             	mov    0x10(%ebp),%eax
c0108558:	8d 50 01             	lea    0x1(%eax),%edx
c010855b:	89 55 10             	mov    %edx,0x10(%ebp)
c010855e:	0f b6 00             	movzbl (%eax),%eax
c0108561:	0f b6 d8             	movzbl %al,%ebx
c0108564:	83 fb 25             	cmp    $0x25,%ebx
c0108567:	75 d5                	jne    c010853e <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c0108569:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c010856d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0108574:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108577:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c010857a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0108581:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108584:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0108587:	8b 45 10             	mov    0x10(%ebp),%eax
c010858a:	8d 50 01             	lea    0x1(%eax),%edx
c010858d:	89 55 10             	mov    %edx,0x10(%ebp)
c0108590:	0f b6 00             	movzbl (%eax),%eax
c0108593:	0f b6 d8             	movzbl %al,%ebx
c0108596:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0108599:	83 f8 55             	cmp    $0x55,%eax
c010859c:	0f 87 37 03 00 00    	ja     c01088d9 <vprintfmt+0x3a5>
c01085a2:	8b 04 85 d0 ae 10 c0 	mov    -0x3fef5130(,%eax,4),%eax
c01085a9:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c01085ab:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c01085af:	eb d6                	jmp    c0108587 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c01085b1:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c01085b5:	eb d0                	jmp    c0108587 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c01085b7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c01085be:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01085c1:	89 d0                	mov    %edx,%eax
c01085c3:	c1 e0 02             	shl    $0x2,%eax
c01085c6:	01 d0                	add    %edx,%eax
c01085c8:	01 c0                	add    %eax,%eax
c01085ca:	01 d8                	add    %ebx,%eax
c01085cc:	83 e8 30             	sub    $0x30,%eax
c01085cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c01085d2:	8b 45 10             	mov    0x10(%ebp),%eax
c01085d5:	0f b6 00             	movzbl (%eax),%eax
c01085d8:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c01085db:	83 fb 2f             	cmp    $0x2f,%ebx
c01085de:	7e 38                	jle    c0108618 <vprintfmt+0xe4>
c01085e0:	83 fb 39             	cmp    $0x39,%ebx
c01085e3:	7f 33                	jg     c0108618 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
c01085e5:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c01085e8:	eb d4                	jmp    c01085be <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c01085ea:	8b 45 14             	mov    0x14(%ebp),%eax
c01085ed:	8d 50 04             	lea    0x4(%eax),%edx
c01085f0:	89 55 14             	mov    %edx,0x14(%ebp)
c01085f3:	8b 00                	mov    (%eax),%eax
c01085f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c01085f8:	eb 1f                	jmp    c0108619 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c01085fa:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01085fe:	79 87                	jns    c0108587 <vprintfmt+0x53>
                width = 0;
c0108600:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0108607:	e9 7b ff ff ff       	jmp    c0108587 <vprintfmt+0x53>

        case '#':
            altflag = 1;
c010860c:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0108613:	e9 6f ff ff ff       	jmp    c0108587 <vprintfmt+0x53>
            goto process_precision;
c0108618:	90                   	nop

        process_precision:
            if (width < 0)
c0108619:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010861d:	0f 89 64 ff ff ff    	jns    c0108587 <vprintfmt+0x53>
                width = precision, precision = -1;
c0108623:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108626:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108629:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0108630:	e9 52 ff ff ff       	jmp    c0108587 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0108635:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c0108638:	e9 4a ff ff ff       	jmp    c0108587 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c010863d:	8b 45 14             	mov    0x14(%ebp),%eax
c0108640:	8d 50 04             	lea    0x4(%eax),%edx
c0108643:	89 55 14             	mov    %edx,0x14(%ebp)
c0108646:	8b 00                	mov    (%eax),%eax
c0108648:	8b 55 0c             	mov    0xc(%ebp),%edx
c010864b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010864f:	89 04 24             	mov    %eax,(%esp)
c0108652:	8b 45 08             	mov    0x8(%ebp),%eax
c0108655:	ff d0                	call   *%eax
            break;
c0108657:	e9 a4 02 00 00       	jmp    c0108900 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c010865c:	8b 45 14             	mov    0x14(%ebp),%eax
c010865f:	8d 50 04             	lea    0x4(%eax),%edx
c0108662:	89 55 14             	mov    %edx,0x14(%ebp)
c0108665:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0108667:	85 db                	test   %ebx,%ebx
c0108669:	79 02                	jns    c010866d <vprintfmt+0x139>
                err = -err;
c010866b:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c010866d:	83 fb 06             	cmp    $0x6,%ebx
c0108670:	7f 0b                	jg     c010867d <vprintfmt+0x149>
c0108672:	8b 34 9d 90 ae 10 c0 	mov    -0x3fef5170(,%ebx,4),%esi
c0108679:	85 f6                	test   %esi,%esi
c010867b:	75 23                	jne    c01086a0 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c010867d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0108681:	c7 44 24 08 bd ae 10 	movl   $0xc010aebd,0x8(%esp)
c0108688:	c0 
c0108689:	8b 45 0c             	mov    0xc(%ebp),%eax
c010868c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108690:	8b 45 08             	mov    0x8(%ebp),%eax
c0108693:	89 04 24             	mov    %eax,(%esp)
c0108696:	e8 68 fe ff ff       	call   c0108503 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c010869b:	e9 60 02 00 00       	jmp    c0108900 <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
c01086a0:	89 74 24 0c          	mov    %esi,0xc(%esp)
c01086a4:	c7 44 24 08 c6 ae 10 	movl   $0xc010aec6,0x8(%esp)
c01086ab:	c0 
c01086ac:	8b 45 0c             	mov    0xc(%ebp),%eax
c01086af:	89 44 24 04          	mov    %eax,0x4(%esp)
c01086b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01086b6:	89 04 24             	mov    %eax,(%esp)
c01086b9:	e8 45 fe ff ff       	call   c0108503 <printfmt>
            break;
c01086be:	e9 3d 02 00 00       	jmp    c0108900 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c01086c3:	8b 45 14             	mov    0x14(%ebp),%eax
c01086c6:	8d 50 04             	lea    0x4(%eax),%edx
c01086c9:	89 55 14             	mov    %edx,0x14(%ebp)
c01086cc:	8b 30                	mov    (%eax),%esi
c01086ce:	85 f6                	test   %esi,%esi
c01086d0:	75 05                	jne    c01086d7 <vprintfmt+0x1a3>
                p = "(null)";
c01086d2:	be c9 ae 10 c0       	mov    $0xc010aec9,%esi
            }
            if (width > 0 && padc != '-') {
c01086d7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01086db:	7e 76                	jle    c0108753 <vprintfmt+0x21f>
c01086dd:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c01086e1:	74 70                	je     c0108753 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c01086e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01086e6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01086ea:	89 34 24             	mov    %esi,(%esp)
c01086ed:	e8 ee 03 00 00       	call   c0108ae0 <strnlen>
c01086f2:	89 c2                	mov    %eax,%edx
c01086f4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01086f7:	29 d0                	sub    %edx,%eax
c01086f9:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01086fc:	eb 16                	jmp    c0108714 <vprintfmt+0x1e0>
                    putch(padc, putdat);
c01086fe:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0108702:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108705:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108709:	89 04 24             	mov    %eax,(%esp)
c010870c:	8b 45 08             	mov    0x8(%ebp),%eax
c010870f:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c0108711:	ff 4d e8             	decl   -0x18(%ebp)
c0108714:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108718:	7f e4                	jg     c01086fe <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010871a:	eb 37                	jmp    c0108753 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c010871c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0108720:	74 1f                	je     c0108741 <vprintfmt+0x20d>
c0108722:	83 fb 1f             	cmp    $0x1f,%ebx
c0108725:	7e 05                	jle    c010872c <vprintfmt+0x1f8>
c0108727:	83 fb 7e             	cmp    $0x7e,%ebx
c010872a:	7e 15                	jle    c0108741 <vprintfmt+0x20d>
                    putch('?', putdat);
c010872c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010872f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108733:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c010873a:	8b 45 08             	mov    0x8(%ebp),%eax
c010873d:	ff d0                	call   *%eax
c010873f:	eb 0f                	jmp    c0108750 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c0108741:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108744:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108748:	89 1c 24             	mov    %ebx,(%esp)
c010874b:	8b 45 08             	mov    0x8(%ebp),%eax
c010874e:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0108750:	ff 4d e8             	decl   -0x18(%ebp)
c0108753:	89 f0                	mov    %esi,%eax
c0108755:	8d 70 01             	lea    0x1(%eax),%esi
c0108758:	0f b6 00             	movzbl (%eax),%eax
c010875b:	0f be d8             	movsbl %al,%ebx
c010875e:	85 db                	test   %ebx,%ebx
c0108760:	74 27                	je     c0108789 <vprintfmt+0x255>
c0108762:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0108766:	78 b4                	js     c010871c <vprintfmt+0x1e8>
c0108768:	ff 4d e4             	decl   -0x1c(%ebp)
c010876b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010876f:	79 ab                	jns    c010871c <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
c0108771:	eb 16                	jmp    c0108789 <vprintfmt+0x255>
                putch(' ', putdat);
c0108773:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108776:	89 44 24 04          	mov    %eax,0x4(%esp)
c010877a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0108781:	8b 45 08             	mov    0x8(%ebp),%eax
c0108784:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c0108786:	ff 4d e8             	decl   -0x18(%ebp)
c0108789:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010878d:	7f e4                	jg     c0108773 <vprintfmt+0x23f>
            }
            break;
c010878f:	e9 6c 01 00 00       	jmp    c0108900 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0108794:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108797:	89 44 24 04          	mov    %eax,0x4(%esp)
c010879b:	8d 45 14             	lea    0x14(%ebp),%eax
c010879e:	89 04 24             	mov    %eax,(%esp)
c01087a1:	e8 16 fd ff ff       	call   c01084bc <getint>
c01087a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01087a9:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c01087ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01087af:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01087b2:	85 d2                	test   %edx,%edx
c01087b4:	79 26                	jns    c01087dc <vprintfmt+0x2a8>
                putch('-', putdat);
c01087b6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01087b9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01087bd:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c01087c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01087c7:	ff d0                	call   *%eax
                num = -(long long)num;
c01087c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01087cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01087cf:	f7 d8                	neg    %eax
c01087d1:	83 d2 00             	adc    $0x0,%edx
c01087d4:	f7 da                	neg    %edx
c01087d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01087d9:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c01087dc:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01087e3:	e9 a8 00 00 00       	jmp    c0108890 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c01087e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01087eb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01087ef:	8d 45 14             	lea    0x14(%ebp),%eax
c01087f2:	89 04 24             	mov    %eax,(%esp)
c01087f5:	e8 73 fc ff ff       	call   c010846d <getuint>
c01087fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01087fd:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0108800:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0108807:	e9 84 00 00 00       	jmp    c0108890 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c010880c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010880f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108813:	8d 45 14             	lea    0x14(%ebp),%eax
c0108816:	89 04 24             	mov    %eax,(%esp)
c0108819:	e8 4f fc ff ff       	call   c010846d <getuint>
c010881e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108821:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0108824:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c010882b:	eb 63                	jmp    c0108890 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c010882d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108830:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108834:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c010883b:	8b 45 08             	mov    0x8(%ebp),%eax
c010883e:	ff d0                	call   *%eax
            putch('x', putdat);
c0108840:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108843:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108847:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c010884e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108851:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0108853:	8b 45 14             	mov    0x14(%ebp),%eax
c0108856:	8d 50 04             	lea    0x4(%eax),%edx
c0108859:	89 55 14             	mov    %edx,0x14(%ebp)
c010885c:	8b 00                	mov    (%eax),%eax
c010885e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108861:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0108868:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c010886f:	eb 1f                	jmp    c0108890 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0108871:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108874:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108878:	8d 45 14             	lea    0x14(%ebp),%eax
c010887b:	89 04 24             	mov    %eax,(%esp)
c010887e:	e8 ea fb ff ff       	call   c010846d <getuint>
c0108883:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108886:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0108889:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0108890:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0108894:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108897:	89 54 24 18          	mov    %edx,0x18(%esp)
c010889b:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010889e:	89 54 24 14          	mov    %edx,0x14(%esp)
c01088a2:	89 44 24 10          	mov    %eax,0x10(%esp)
c01088a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01088a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01088ac:	89 44 24 08          	mov    %eax,0x8(%esp)
c01088b0:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01088b4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01088b7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01088bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01088be:	89 04 24             	mov    %eax,(%esp)
c01088c1:	e8 a5 fa ff ff       	call   c010836b <printnum>
            break;
c01088c6:	eb 38                	jmp    c0108900 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c01088c8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01088cb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01088cf:	89 1c 24             	mov    %ebx,(%esp)
c01088d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01088d5:	ff d0                	call   *%eax
            break;
c01088d7:	eb 27                	jmp    c0108900 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c01088d9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01088dc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01088e0:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c01088e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01088ea:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c01088ec:	ff 4d 10             	decl   0x10(%ebp)
c01088ef:	eb 03                	jmp    c01088f4 <vprintfmt+0x3c0>
c01088f1:	ff 4d 10             	decl   0x10(%ebp)
c01088f4:	8b 45 10             	mov    0x10(%ebp),%eax
c01088f7:	48                   	dec    %eax
c01088f8:	0f b6 00             	movzbl (%eax),%eax
c01088fb:	3c 25                	cmp    $0x25,%al
c01088fd:	75 f2                	jne    c01088f1 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c01088ff:	90                   	nop
    while (1) {
c0108900:	e9 37 fc ff ff       	jmp    c010853c <vprintfmt+0x8>
                return;
c0108905:	90                   	nop
        }
    }
}
c0108906:	83 c4 40             	add    $0x40,%esp
c0108909:	5b                   	pop    %ebx
c010890a:	5e                   	pop    %esi
c010890b:	5d                   	pop    %ebp
c010890c:	c3                   	ret    

c010890d <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c010890d:	55                   	push   %ebp
c010890e:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0108910:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108913:	8b 40 08             	mov    0x8(%eax),%eax
c0108916:	8d 50 01             	lea    0x1(%eax),%edx
c0108919:	8b 45 0c             	mov    0xc(%ebp),%eax
c010891c:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c010891f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108922:	8b 10                	mov    (%eax),%edx
c0108924:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108927:	8b 40 04             	mov    0x4(%eax),%eax
c010892a:	39 c2                	cmp    %eax,%edx
c010892c:	73 12                	jae    c0108940 <sprintputch+0x33>
        *b->buf ++ = ch;
c010892e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108931:	8b 00                	mov    (%eax),%eax
c0108933:	8d 48 01             	lea    0x1(%eax),%ecx
c0108936:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108939:	89 0a                	mov    %ecx,(%edx)
c010893b:	8b 55 08             	mov    0x8(%ebp),%edx
c010893e:	88 10                	mov    %dl,(%eax)
    }
}
c0108940:	90                   	nop
c0108941:	5d                   	pop    %ebp
c0108942:	c3                   	ret    

c0108943 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0108943:	55                   	push   %ebp
c0108944:	89 e5                	mov    %esp,%ebp
c0108946:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0108949:	8d 45 14             	lea    0x14(%ebp),%eax
c010894c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c010894f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108952:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108956:	8b 45 10             	mov    0x10(%ebp),%eax
c0108959:	89 44 24 08          	mov    %eax,0x8(%esp)
c010895d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108960:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108964:	8b 45 08             	mov    0x8(%ebp),%eax
c0108967:	89 04 24             	mov    %eax,(%esp)
c010896a:	e8 0a 00 00 00       	call   c0108979 <vsnprintf>
c010896f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0108972:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108975:	89 ec                	mov    %ebp,%esp
c0108977:	5d                   	pop    %ebp
c0108978:	c3                   	ret    

c0108979 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0108979:	55                   	push   %ebp
c010897a:	89 e5                	mov    %esp,%ebp
c010897c:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c010897f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108982:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108985:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108988:	8d 50 ff             	lea    -0x1(%eax),%edx
c010898b:	8b 45 08             	mov    0x8(%ebp),%eax
c010898e:	01 d0                	add    %edx,%eax
c0108990:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108993:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c010899a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010899e:	74 0a                	je     c01089aa <vsnprintf+0x31>
c01089a0:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01089a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01089a6:	39 c2                	cmp    %eax,%edx
c01089a8:	76 07                	jbe    c01089b1 <vsnprintf+0x38>
        return -E_INVAL;
c01089aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c01089af:	eb 2a                	jmp    c01089db <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c01089b1:	8b 45 14             	mov    0x14(%ebp),%eax
c01089b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01089b8:	8b 45 10             	mov    0x10(%ebp),%eax
c01089bb:	89 44 24 08          	mov    %eax,0x8(%esp)
c01089bf:	8d 45 ec             	lea    -0x14(%ebp),%eax
c01089c2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01089c6:	c7 04 24 0d 89 10 c0 	movl   $0xc010890d,(%esp)
c01089cd:	e8 62 fb ff ff       	call   c0108534 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c01089d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01089d5:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c01089d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01089db:	89 ec                	mov    %ebp,%esp
c01089dd:	5d                   	pop    %ebp
c01089de:	c3                   	ret    

c01089df <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c01089df:	55                   	push   %ebp
c01089e0:	89 e5                	mov    %esp,%ebp
c01089e2:	57                   	push   %edi
c01089e3:	56                   	push   %esi
c01089e4:	53                   	push   %ebx
c01089e5:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c01089e8:	a1 60 3a 12 c0       	mov    0xc0123a60,%eax
c01089ed:	8b 15 64 3a 12 c0    	mov    0xc0123a64,%edx
c01089f3:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c01089f9:	6b f0 05             	imul   $0x5,%eax,%esi
c01089fc:	01 fe                	add    %edi,%esi
c01089fe:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
c0108a03:	f7 e7                	mul    %edi
c0108a05:	01 d6                	add    %edx,%esi
c0108a07:	89 f2                	mov    %esi,%edx
c0108a09:	83 c0 0b             	add    $0xb,%eax
c0108a0c:	83 d2 00             	adc    $0x0,%edx
c0108a0f:	89 c7                	mov    %eax,%edi
c0108a11:	83 e7 ff             	and    $0xffffffff,%edi
c0108a14:	89 f9                	mov    %edi,%ecx
c0108a16:	0f b7 da             	movzwl %dx,%ebx
c0108a19:	89 0d 60 3a 12 c0    	mov    %ecx,0xc0123a60
c0108a1f:	89 1d 64 3a 12 c0    	mov    %ebx,0xc0123a64
    unsigned long long result = (next >> 12);
c0108a25:	a1 60 3a 12 c0       	mov    0xc0123a60,%eax
c0108a2a:	8b 15 64 3a 12 c0    	mov    0xc0123a64,%edx
c0108a30:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0108a34:	c1 ea 0c             	shr    $0xc,%edx
c0108a37:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108a3a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c0108a3d:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c0108a44:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108a47:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108a4a:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108a4d:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0108a50:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108a53:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108a56:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108a5a:	74 1c                	je     c0108a78 <rand+0x99>
c0108a5c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108a5f:	ba 00 00 00 00       	mov    $0x0,%edx
c0108a64:	f7 75 dc             	divl   -0x24(%ebp)
c0108a67:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0108a6a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108a6d:	ba 00 00 00 00       	mov    $0x0,%edx
c0108a72:	f7 75 dc             	divl   -0x24(%ebp)
c0108a75:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108a78:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108a7b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108a7e:	f7 75 dc             	divl   -0x24(%ebp)
c0108a81:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108a84:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0108a87:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108a8a:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0108a8d:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108a90:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0108a93:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c0108a96:	83 c4 24             	add    $0x24,%esp
c0108a99:	5b                   	pop    %ebx
c0108a9a:	5e                   	pop    %esi
c0108a9b:	5f                   	pop    %edi
c0108a9c:	5d                   	pop    %ebp
c0108a9d:	c3                   	ret    

c0108a9e <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c0108a9e:	55                   	push   %ebp
c0108a9f:	89 e5                	mov    %esp,%ebp
    next = seed;
c0108aa1:	8b 45 08             	mov    0x8(%ebp),%eax
c0108aa4:	ba 00 00 00 00       	mov    $0x0,%edx
c0108aa9:	a3 60 3a 12 c0       	mov    %eax,0xc0123a60
c0108aae:	89 15 64 3a 12 c0    	mov    %edx,0xc0123a64
}
c0108ab4:	90                   	nop
c0108ab5:	5d                   	pop    %ebp
c0108ab6:	c3                   	ret    

c0108ab7 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0108ab7:	55                   	push   %ebp
c0108ab8:	89 e5                	mov    %esp,%ebp
c0108aba:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0108abd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0108ac4:	eb 03                	jmp    c0108ac9 <strlen+0x12>
        cnt ++;
c0108ac6:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c0108ac9:	8b 45 08             	mov    0x8(%ebp),%eax
c0108acc:	8d 50 01             	lea    0x1(%eax),%edx
c0108acf:	89 55 08             	mov    %edx,0x8(%ebp)
c0108ad2:	0f b6 00             	movzbl (%eax),%eax
c0108ad5:	84 c0                	test   %al,%al
c0108ad7:	75 ed                	jne    c0108ac6 <strlen+0xf>
    }
    return cnt;
c0108ad9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0108adc:	89 ec                	mov    %ebp,%esp
c0108ade:	5d                   	pop    %ebp
c0108adf:	c3                   	ret    

c0108ae0 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0108ae0:	55                   	push   %ebp
c0108ae1:	89 e5                	mov    %esp,%ebp
c0108ae3:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0108ae6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0108aed:	eb 03                	jmp    c0108af2 <strnlen+0x12>
        cnt ++;
c0108aef:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0108af2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108af5:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108af8:	73 10                	jae    c0108b0a <strnlen+0x2a>
c0108afa:	8b 45 08             	mov    0x8(%ebp),%eax
c0108afd:	8d 50 01             	lea    0x1(%eax),%edx
c0108b00:	89 55 08             	mov    %edx,0x8(%ebp)
c0108b03:	0f b6 00             	movzbl (%eax),%eax
c0108b06:	84 c0                	test   %al,%al
c0108b08:	75 e5                	jne    c0108aef <strnlen+0xf>
    }
    return cnt;
c0108b0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0108b0d:	89 ec                	mov    %ebp,%esp
c0108b0f:	5d                   	pop    %ebp
c0108b10:	c3                   	ret    

c0108b11 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0108b11:	55                   	push   %ebp
c0108b12:	89 e5                	mov    %esp,%ebp
c0108b14:	57                   	push   %edi
c0108b15:	56                   	push   %esi
c0108b16:	83 ec 20             	sub    $0x20,%esp
c0108b19:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b1c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108b1f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b22:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0108b25:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108b2b:	89 d1                	mov    %edx,%ecx
c0108b2d:	89 c2                	mov    %eax,%edx
c0108b2f:	89 ce                	mov    %ecx,%esi
c0108b31:	89 d7                	mov    %edx,%edi
c0108b33:	ac                   	lods   %ds:(%esi),%al
c0108b34:	aa                   	stos   %al,%es:(%edi)
c0108b35:	84 c0                	test   %al,%al
c0108b37:	75 fa                	jne    c0108b33 <strcpy+0x22>
c0108b39:	89 fa                	mov    %edi,%edx
c0108b3b:	89 f1                	mov    %esi,%ecx
c0108b3d:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0108b40:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0108b43:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0108b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0108b49:	83 c4 20             	add    $0x20,%esp
c0108b4c:	5e                   	pop    %esi
c0108b4d:	5f                   	pop    %edi
c0108b4e:	5d                   	pop    %ebp
c0108b4f:	c3                   	ret    

c0108b50 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0108b50:	55                   	push   %ebp
c0108b51:	89 e5                	mov    %esp,%ebp
c0108b53:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0108b56:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b59:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0108b5c:	eb 1e                	jmp    c0108b7c <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c0108b5e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b61:	0f b6 10             	movzbl (%eax),%edx
c0108b64:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108b67:	88 10                	mov    %dl,(%eax)
c0108b69:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108b6c:	0f b6 00             	movzbl (%eax),%eax
c0108b6f:	84 c0                	test   %al,%al
c0108b71:	74 03                	je     c0108b76 <strncpy+0x26>
            src ++;
c0108b73:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c0108b76:	ff 45 fc             	incl   -0x4(%ebp)
c0108b79:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c0108b7c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108b80:	75 dc                	jne    c0108b5e <strncpy+0xe>
    }
    return dst;
c0108b82:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0108b85:	89 ec                	mov    %ebp,%esp
c0108b87:	5d                   	pop    %ebp
c0108b88:	c3                   	ret    

c0108b89 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0108b89:	55                   	push   %ebp
c0108b8a:	89 e5                	mov    %esp,%ebp
c0108b8c:	57                   	push   %edi
c0108b8d:	56                   	push   %esi
c0108b8e:	83 ec 20             	sub    $0x20,%esp
c0108b91:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b94:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108b97:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c0108b9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108ba0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108ba3:	89 d1                	mov    %edx,%ecx
c0108ba5:	89 c2                	mov    %eax,%edx
c0108ba7:	89 ce                	mov    %ecx,%esi
c0108ba9:	89 d7                	mov    %edx,%edi
c0108bab:	ac                   	lods   %ds:(%esi),%al
c0108bac:	ae                   	scas   %es:(%edi),%al
c0108bad:	75 08                	jne    c0108bb7 <strcmp+0x2e>
c0108baf:	84 c0                	test   %al,%al
c0108bb1:	75 f8                	jne    c0108bab <strcmp+0x22>
c0108bb3:	31 c0                	xor    %eax,%eax
c0108bb5:	eb 04                	jmp    c0108bbb <strcmp+0x32>
c0108bb7:	19 c0                	sbb    %eax,%eax
c0108bb9:	0c 01                	or     $0x1,%al
c0108bbb:	89 fa                	mov    %edi,%edx
c0108bbd:	89 f1                	mov    %esi,%ecx
c0108bbf:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108bc2:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0108bc5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c0108bc8:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0108bcb:	83 c4 20             	add    $0x20,%esp
c0108bce:	5e                   	pop    %esi
c0108bcf:	5f                   	pop    %edi
c0108bd0:	5d                   	pop    %ebp
c0108bd1:	c3                   	ret    

c0108bd2 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0108bd2:	55                   	push   %ebp
c0108bd3:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0108bd5:	eb 09                	jmp    c0108be0 <strncmp+0xe>
        n --, s1 ++, s2 ++;
c0108bd7:	ff 4d 10             	decl   0x10(%ebp)
c0108bda:	ff 45 08             	incl   0x8(%ebp)
c0108bdd:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0108be0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108be4:	74 1a                	je     c0108c00 <strncmp+0x2e>
c0108be6:	8b 45 08             	mov    0x8(%ebp),%eax
c0108be9:	0f b6 00             	movzbl (%eax),%eax
c0108bec:	84 c0                	test   %al,%al
c0108bee:	74 10                	je     c0108c00 <strncmp+0x2e>
c0108bf0:	8b 45 08             	mov    0x8(%ebp),%eax
c0108bf3:	0f b6 10             	movzbl (%eax),%edx
c0108bf6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108bf9:	0f b6 00             	movzbl (%eax),%eax
c0108bfc:	38 c2                	cmp    %al,%dl
c0108bfe:	74 d7                	je     c0108bd7 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0108c00:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108c04:	74 18                	je     c0108c1e <strncmp+0x4c>
c0108c06:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c09:	0f b6 00             	movzbl (%eax),%eax
c0108c0c:	0f b6 d0             	movzbl %al,%edx
c0108c0f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108c12:	0f b6 00             	movzbl (%eax),%eax
c0108c15:	0f b6 c8             	movzbl %al,%ecx
c0108c18:	89 d0                	mov    %edx,%eax
c0108c1a:	29 c8                	sub    %ecx,%eax
c0108c1c:	eb 05                	jmp    c0108c23 <strncmp+0x51>
c0108c1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108c23:	5d                   	pop    %ebp
c0108c24:	c3                   	ret    

c0108c25 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0108c25:	55                   	push   %ebp
c0108c26:	89 e5                	mov    %esp,%ebp
c0108c28:	83 ec 04             	sub    $0x4,%esp
c0108c2b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108c2e:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0108c31:	eb 13                	jmp    c0108c46 <strchr+0x21>
        if (*s == c) {
c0108c33:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c36:	0f b6 00             	movzbl (%eax),%eax
c0108c39:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0108c3c:	75 05                	jne    c0108c43 <strchr+0x1e>
            return (char *)s;
c0108c3e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c41:	eb 12                	jmp    c0108c55 <strchr+0x30>
        }
        s ++;
c0108c43:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0108c46:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c49:	0f b6 00             	movzbl (%eax),%eax
c0108c4c:	84 c0                	test   %al,%al
c0108c4e:	75 e3                	jne    c0108c33 <strchr+0xe>
    }
    return NULL;
c0108c50:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108c55:	89 ec                	mov    %ebp,%esp
c0108c57:	5d                   	pop    %ebp
c0108c58:	c3                   	ret    

c0108c59 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0108c59:	55                   	push   %ebp
c0108c5a:	89 e5                	mov    %esp,%ebp
c0108c5c:	83 ec 04             	sub    $0x4,%esp
c0108c5f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108c62:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0108c65:	eb 0e                	jmp    c0108c75 <strfind+0x1c>
        if (*s == c) {
c0108c67:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c6a:	0f b6 00             	movzbl (%eax),%eax
c0108c6d:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0108c70:	74 0f                	je     c0108c81 <strfind+0x28>
            break;
        }
        s ++;
c0108c72:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0108c75:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c78:	0f b6 00             	movzbl (%eax),%eax
c0108c7b:	84 c0                	test   %al,%al
c0108c7d:	75 e8                	jne    c0108c67 <strfind+0xe>
c0108c7f:	eb 01                	jmp    c0108c82 <strfind+0x29>
            break;
c0108c81:	90                   	nop
    }
    return (char *)s;
c0108c82:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0108c85:	89 ec                	mov    %ebp,%esp
c0108c87:	5d                   	pop    %ebp
c0108c88:	c3                   	ret    

c0108c89 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0108c89:	55                   	push   %ebp
c0108c8a:	89 e5                	mov    %esp,%ebp
c0108c8c:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0108c8f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0108c96:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0108c9d:	eb 03                	jmp    c0108ca2 <strtol+0x19>
        s ++;
c0108c9f:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c0108ca2:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ca5:	0f b6 00             	movzbl (%eax),%eax
c0108ca8:	3c 20                	cmp    $0x20,%al
c0108caa:	74 f3                	je     c0108c9f <strtol+0x16>
c0108cac:	8b 45 08             	mov    0x8(%ebp),%eax
c0108caf:	0f b6 00             	movzbl (%eax),%eax
c0108cb2:	3c 09                	cmp    $0x9,%al
c0108cb4:	74 e9                	je     c0108c9f <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c0108cb6:	8b 45 08             	mov    0x8(%ebp),%eax
c0108cb9:	0f b6 00             	movzbl (%eax),%eax
c0108cbc:	3c 2b                	cmp    $0x2b,%al
c0108cbe:	75 05                	jne    c0108cc5 <strtol+0x3c>
        s ++;
c0108cc0:	ff 45 08             	incl   0x8(%ebp)
c0108cc3:	eb 14                	jmp    c0108cd9 <strtol+0x50>
    }
    else if (*s == '-') {
c0108cc5:	8b 45 08             	mov    0x8(%ebp),%eax
c0108cc8:	0f b6 00             	movzbl (%eax),%eax
c0108ccb:	3c 2d                	cmp    $0x2d,%al
c0108ccd:	75 0a                	jne    c0108cd9 <strtol+0x50>
        s ++, neg = 1;
c0108ccf:	ff 45 08             	incl   0x8(%ebp)
c0108cd2:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0108cd9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108cdd:	74 06                	je     c0108ce5 <strtol+0x5c>
c0108cdf:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0108ce3:	75 22                	jne    c0108d07 <strtol+0x7e>
c0108ce5:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ce8:	0f b6 00             	movzbl (%eax),%eax
c0108ceb:	3c 30                	cmp    $0x30,%al
c0108ced:	75 18                	jne    c0108d07 <strtol+0x7e>
c0108cef:	8b 45 08             	mov    0x8(%ebp),%eax
c0108cf2:	40                   	inc    %eax
c0108cf3:	0f b6 00             	movzbl (%eax),%eax
c0108cf6:	3c 78                	cmp    $0x78,%al
c0108cf8:	75 0d                	jne    c0108d07 <strtol+0x7e>
        s += 2, base = 16;
c0108cfa:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0108cfe:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0108d05:	eb 29                	jmp    c0108d30 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c0108d07:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108d0b:	75 16                	jne    c0108d23 <strtol+0x9a>
c0108d0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d10:	0f b6 00             	movzbl (%eax),%eax
c0108d13:	3c 30                	cmp    $0x30,%al
c0108d15:	75 0c                	jne    c0108d23 <strtol+0x9a>
        s ++, base = 8;
c0108d17:	ff 45 08             	incl   0x8(%ebp)
c0108d1a:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0108d21:	eb 0d                	jmp    c0108d30 <strtol+0xa7>
    }
    else if (base == 0) {
c0108d23:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108d27:	75 07                	jne    c0108d30 <strtol+0xa7>
        base = 10;
c0108d29:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0108d30:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d33:	0f b6 00             	movzbl (%eax),%eax
c0108d36:	3c 2f                	cmp    $0x2f,%al
c0108d38:	7e 1b                	jle    c0108d55 <strtol+0xcc>
c0108d3a:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d3d:	0f b6 00             	movzbl (%eax),%eax
c0108d40:	3c 39                	cmp    $0x39,%al
c0108d42:	7f 11                	jg     c0108d55 <strtol+0xcc>
            dig = *s - '0';
c0108d44:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d47:	0f b6 00             	movzbl (%eax),%eax
c0108d4a:	0f be c0             	movsbl %al,%eax
c0108d4d:	83 e8 30             	sub    $0x30,%eax
c0108d50:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108d53:	eb 48                	jmp    c0108d9d <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0108d55:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d58:	0f b6 00             	movzbl (%eax),%eax
c0108d5b:	3c 60                	cmp    $0x60,%al
c0108d5d:	7e 1b                	jle    c0108d7a <strtol+0xf1>
c0108d5f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d62:	0f b6 00             	movzbl (%eax),%eax
c0108d65:	3c 7a                	cmp    $0x7a,%al
c0108d67:	7f 11                	jg     c0108d7a <strtol+0xf1>
            dig = *s - 'a' + 10;
c0108d69:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d6c:	0f b6 00             	movzbl (%eax),%eax
c0108d6f:	0f be c0             	movsbl %al,%eax
c0108d72:	83 e8 57             	sub    $0x57,%eax
c0108d75:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108d78:	eb 23                	jmp    c0108d9d <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0108d7a:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d7d:	0f b6 00             	movzbl (%eax),%eax
c0108d80:	3c 40                	cmp    $0x40,%al
c0108d82:	7e 3b                	jle    c0108dbf <strtol+0x136>
c0108d84:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d87:	0f b6 00             	movzbl (%eax),%eax
c0108d8a:	3c 5a                	cmp    $0x5a,%al
c0108d8c:	7f 31                	jg     c0108dbf <strtol+0x136>
            dig = *s - 'A' + 10;
c0108d8e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d91:	0f b6 00             	movzbl (%eax),%eax
c0108d94:	0f be c0             	movsbl %al,%eax
c0108d97:	83 e8 37             	sub    $0x37,%eax
c0108d9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0108d9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108da0:	3b 45 10             	cmp    0x10(%ebp),%eax
c0108da3:	7d 19                	jge    c0108dbe <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c0108da5:	ff 45 08             	incl   0x8(%ebp)
c0108da8:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108dab:	0f af 45 10          	imul   0x10(%ebp),%eax
c0108daf:	89 c2                	mov    %eax,%edx
c0108db1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108db4:	01 d0                	add    %edx,%eax
c0108db6:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c0108db9:	e9 72 ff ff ff       	jmp    c0108d30 <strtol+0xa7>
            break;
c0108dbe:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c0108dbf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0108dc3:	74 08                	je     c0108dcd <strtol+0x144>
        *endptr = (char *) s;
c0108dc5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108dc8:	8b 55 08             	mov    0x8(%ebp),%edx
c0108dcb:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0108dcd:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0108dd1:	74 07                	je     c0108dda <strtol+0x151>
c0108dd3:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108dd6:	f7 d8                	neg    %eax
c0108dd8:	eb 03                	jmp    c0108ddd <strtol+0x154>
c0108dda:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0108ddd:	89 ec                	mov    %ebp,%esp
c0108ddf:	5d                   	pop    %ebp
c0108de0:	c3                   	ret    

c0108de1 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0108de1:	55                   	push   %ebp
c0108de2:	89 e5                	mov    %esp,%ebp
c0108de4:	83 ec 28             	sub    $0x28,%esp
c0108de7:	89 7d fc             	mov    %edi,-0x4(%ebp)
c0108dea:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108ded:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0108df0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
c0108df4:	8b 45 08             	mov    0x8(%ebp),%eax
c0108df7:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0108dfa:	88 55 f7             	mov    %dl,-0x9(%ebp)
c0108dfd:	8b 45 10             	mov    0x10(%ebp),%eax
c0108e00:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0108e03:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0108e06:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0108e0a:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0108e0d:	89 d7                	mov    %edx,%edi
c0108e0f:	f3 aa                	rep stos %al,%es:(%edi)
c0108e11:	89 fa                	mov    %edi,%edx
c0108e13:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0108e16:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0108e19:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0108e1c:	8b 7d fc             	mov    -0x4(%ebp),%edi
c0108e1f:	89 ec                	mov    %ebp,%esp
c0108e21:	5d                   	pop    %ebp
c0108e22:	c3                   	ret    

c0108e23 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0108e23:	55                   	push   %ebp
c0108e24:	89 e5                	mov    %esp,%ebp
c0108e26:	57                   	push   %edi
c0108e27:	56                   	push   %esi
c0108e28:	53                   	push   %ebx
c0108e29:	83 ec 30             	sub    $0x30,%esp
c0108e2c:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108e32:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108e35:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108e38:	8b 45 10             	mov    0x10(%ebp),%eax
c0108e3b:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0108e3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108e41:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0108e44:	73 42                	jae    c0108e88 <memmove+0x65>
c0108e46:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108e49:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108e4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108e4f:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108e52:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108e55:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0108e58:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108e5b:	c1 e8 02             	shr    $0x2,%eax
c0108e5e:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0108e60:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108e63:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108e66:	89 d7                	mov    %edx,%edi
c0108e68:	89 c6                	mov    %eax,%esi
c0108e6a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0108e6c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0108e6f:	83 e1 03             	and    $0x3,%ecx
c0108e72:	74 02                	je     c0108e76 <memmove+0x53>
c0108e74:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0108e76:	89 f0                	mov    %esi,%eax
c0108e78:	89 fa                	mov    %edi,%edx
c0108e7a:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0108e7d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0108e80:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c0108e83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
c0108e86:	eb 36                	jmp    c0108ebe <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0108e88:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108e8b:	8d 50 ff             	lea    -0x1(%eax),%edx
c0108e8e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108e91:	01 c2                	add    %eax,%edx
c0108e93:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108e96:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0108e99:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108e9c:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c0108e9f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108ea2:	89 c1                	mov    %eax,%ecx
c0108ea4:	89 d8                	mov    %ebx,%eax
c0108ea6:	89 d6                	mov    %edx,%esi
c0108ea8:	89 c7                	mov    %eax,%edi
c0108eaa:	fd                   	std    
c0108eab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0108ead:	fc                   	cld    
c0108eae:	89 f8                	mov    %edi,%eax
c0108eb0:	89 f2                	mov    %esi,%edx
c0108eb2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0108eb5:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0108eb8:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c0108ebb:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0108ebe:	83 c4 30             	add    $0x30,%esp
c0108ec1:	5b                   	pop    %ebx
c0108ec2:	5e                   	pop    %esi
c0108ec3:	5f                   	pop    %edi
c0108ec4:	5d                   	pop    %ebp
c0108ec5:	c3                   	ret    

c0108ec6 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0108ec6:	55                   	push   %ebp
c0108ec7:	89 e5                	mov    %esp,%ebp
c0108ec9:	57                   	push   %edi
c0108eca:	56                   	push   %esi
c0108ecb:	83 ec 20             	sub    $0x20,%esp
c0108ece:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ed1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108ed4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108ed7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108eda:	8b 45 10             	mov    0x10(%ebp),%eax
c0108edd:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0108ee0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108ee3:	c1 e8 02             	shr    $0x2,%eax
c0108ee6:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0108ee8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108eeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108eee:	89 d7                	mov    %edx,%edi
c0108ef0:	89 c6                	mov    %eax,%esi
c0108ef2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0108ef4:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0108ef7:	83 e1 03             	and    $0x3,%ecx
c0108efa:	74 02                	je     c0108efe <memcpy+0x38>
c0108efc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0108efe:	89 f0                	mov    %esi,%eax
c0108f00:	89 fa                	mov    %edi,%edx
c0108f02:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0108f05:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0108f08:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c0108f0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0108f0e:	83 c4 20             	add    $0x20,%esp
c0108f11:	5e                   	pop    %esi
c0108f12:	5f                   	pop    %edi
c0108f13:	5d                   	pop    %ebp
c0108f14:	c3                   	ret    

c0108f15 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0108f15:	55                   	push   %ebp
c0108f16:	89 e5                	mov    %esp,%ebp
c0108f18:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0108f1b:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f1e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0108f21:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108f24:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0108f27:	eb 2e                	jmp    c0108f57 <memcmp+0x42>
        if (*s1 != *s2) {
c0108f29:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108f2c:	0f b6 10             	movzbl (%eax),%edx
c0108f2f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108f32:	0f b6 00             	movzbl (%eax),%eax
c0108f35:	38 c2                	cmp    %al,%dl
c0108f37:	74 18                	je     c0108f51 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0108f39:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108f3c:	0f b6 00             	movzbl (%eax),%eax
c0108f3f:	0f b6 d0             	movzbl %al,%edx
c0108f42:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108f45:	0f b6 00             	movzbl (%eax),%eax
c0108f48:	0f b6 c8             	movzbl %al,%ecx
c0108f4b:	89 d0                	mov    %edx,%eax
c0108f4d:	29 c8                	sub    %ecx,%eax
c0108f4f:	eb 18                	jmp    c0108f69 <memcmp+0x54>
        }
        s1 ++, s2 ++;
c0108f51:	ff 45 fc             	incl   -0x4(%ebp)
c0108f54:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c0108f57:	8b 45 10             	mov    0x10(%ebp),%eax
c0108f5a:	8d 50 ff             	lea    -0x1(%eax),%edx
c0108f5d:	89 55 10             	mov    %edx,0x10(%ebp)
c0108f60:	85 c0                	test   %eax,%eax
c0108f62:	75 c5                	jne    c0108f29 <memcmp+0x14>
    }
    return 0;
c0108f64:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108f69:	89 ec                	mov    %ebp,%esp
c0108f6b:	5d                   	pop    %ebp
c0108f6c:	c3                   	ret    
