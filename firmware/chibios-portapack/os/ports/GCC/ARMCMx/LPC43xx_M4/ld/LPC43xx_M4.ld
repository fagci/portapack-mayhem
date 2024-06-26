/*
    ChibiOS/RT - Copyright (C) 2006-2013 Giovanni Di Sirio
                 Copyright (C) 2014 Jared Boone, ShareBrained Technology

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

/*
 * LPC43xx M4 memory setup.
 */
__main_stack_size__     = 0x0400;   /* Exceptions/interrupts stack */
__process_stack_size__  = 0x1000;   /* main() stack */

MEMORY
{
    flash (rx)  : org = 0x00000000, len = 32752	/* Local SRAM @ 0x10080000 */
    ram   (rwx) : org = 0x10000000, len = 96k   /* Local SRAM @ 0x10000000 */
	ram_usb (rwx) : org = 0x20008000, len = 32K
}

usb_bulk_buffer         = ORIGIN(ram_usb);
__ram_start__           = ORIGIN(ram);
__ram_size__            = LENGTH(ram);
__ram_end__             = __ram_start__ + __ram_size__;

ENTRY(ResetHandler)

SECTIONS
{
    . = 0;
    _text = .;

    startup : ALIGN(16) SUBALIGN(16)
    {
        KEEP(*(vectors))
    } > flash

    constructors : ALIGN(4) SUBALIGN(4)
    {
        PROVIDE(__init_array_start = .);
        KEEP(*(SORT(.init_array.*)))
        KEEP(*(.init_array))
        PROVIDE(__init_array_end = .);
    } > flash

    destructors : ALIGN(4) SUBALIGN(4)
    {
        PROVIDE(__fini_array_start = .);
        KEEP(*(.fini_array))
        KEEP(*(SORT(.fini_array.*)))
        PROVIDE(__fini_array_end = .);
    } > flash

    .text : ALIGN(4) SUBALIGN(4)
    {
        *(.text.startup.*)
        *(.text)
        *(.text.*)
        *(.rodata)
        *(.rodata.*)
        *(.glue_7t)
        *(.glue_7)
        *(.gcc*)
    } > flash

    .ARM.extab :
    {
        *(.ARM.extab* .gnu.linkonce.armextab.*)
    } > flash

    .ARM.exidx : {
        PROVIDE(__exidx_start = .);
        *(.ARM.exidx* .gnu.linkonce.armexidx.*)
        PROVIDE(__exidx_end = .);
     } > flash

    .eh_frame_hdr :
    {
        *(.eh_frame_hdr)
    } > flash

    .eh_frame : ONLY_IF_RO
    {
        *(.eh_frame)
    } > flash
    
    .textalign : ONLY_IF_RO
    {
        . = ALIGN(8);
    } > flash

    . = ALIGN(4);
    _etext = .;
    _textdata = _etext;

    .stacks :
    {
        . = ALIGN(8);
        __main_stack_base__ = .;
        . += __main_stack_size__;
        . = ALIGN(8);
        __main_stack_end__ = .;
        __process_stack_base__ = .;
        __main_thread_stack_base__ = .;
        . += __process_stack_size__;
        . = ALIGN(8);
        __process_stack_end__ = .;
        __main_thread_stack_end__ = .;
    } > ram

    .data ALIGN(4) : AT (_textdata)
    {
        . = ALIGN(4);
        PROVIDE(_data = .);
        *(.data)
        *(.data.*)
        *(.ramtext)
        . = ALIGN(4);
        PROVIDE(_edata = .);
    } > ram

    _textend = LOADADDR(.data) + SIZEOF(.data);

    .bss ALIGN(4) : ALIGN(4)
    {
        . = ALIGN(4);
        PROVIDE(_bss_start = .);
        *(.bss)
        *(.bss.*)
        *(COMMON)
        . = ALIGN(4);
        PROVIDE(_bss_end = .);
    } > ram    
}

PROVIDE(end = .);
_end            = .;

__heap_base__   = _end;
__heap_end__    = __ram_end__;
