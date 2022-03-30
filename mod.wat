(module
  ;; First 16 bytes are general purpose registries (v registries)
  ;; The 80b after this is the font
  ;; The 32b after this are the stack as 16xu16
  ;; The 4kb after this is the ram
  ;; The 2kb after this is the writable frame buffer
  (memory (export "memory") 1)

  ;; Font datasection
  (data
    (i32.const 16) 
    "\F0\90\90\90\F0\20\60\20\20\70\F0\10\F0\80\F0\F0\10\F0\10\F0\90\90\F0\10\10\F0\80\F0\10\F0\F0\80\F0\90\F0\F0\10\20\40\40\F0\90\F0\90\F0\F0\90\F0\10\F0\F0\90\F0\90\90\E0\90\E0\90\E0\F0\80\80\80\F0\E0\90\90\90\E0\F0\80\F0\80\F0\F0\80\F0\80\80"
  )

  ;; Constants
  (global $stack_base_ptr i32 (i32.const 96))
  (global $ram_base_ptr i32 (i32.const 128))
  (global $frame_buffer_base_ptr i32 (i32.const 4224))

  ;; Emulator registers
  ;; Also known as `pc`
  (global $program_counter (mut i32) (i32.const 512))
  ;; Also known as `i_reg`
  (global $movable_ram_ptr (mut i32) (i32.const 0))
  ;; Also known as `sp`
  (global $movable_stack_ptr (mut i32) (i32.const 0))
  ;; Also known as `dt`
  (global $delay_timer (mut i32) (i32.const 0))
  ;; Also known as `st`
  (global $sound_timer (mut i32) (i32.const 0))

  ;;
  ;; Utility Functions
  ;;

(func $fetch_opcode
    (export "fetchOpcode")
    (result i32)

    ;; Get opcode
    global.get $program_counter
    global.get $ram_base_ptr
    i32.add
    i32.load16_u

    ;; Increment counter by 2
    global.get $program_counter
    i32.const 2
    i32.add
    global.set $program_counter
  )

  (func $reset
    (export "reset")

    ;; Clear registries
    i32.const 0
    i32.const 0
    i32.const 16
    memory.fill

    ;; Clear Stack
    global.get $stack_base_ptr
    i32.const 0
    i32.const 32    
    memory.fill

    ;; Clear Ram
    global.get $ram_base_ptr
    i32.const 0
    i32.const 4096
    memory.fill

    ;; Copy default font back
    i32.const 80
    i32.const 16
    global.get $ram_base_ptr
    memory.copy

    ;; Set stack pointer back to base
    global.get $stack_base_ptr
    global.set $movable_stack_ptr

    ;; Set ram pointer back to base
    global.get $ram_base_ptr
    global.set $movable_ram_ptr

    ;; Set program counter back to 512
    i32.const 512
    global.set $program_counter
    
    ;; Set delay timer to 0
    i32.const 0
    global.set $delay_timer

    i32.const 0
    global.set $sound_timer
  )

  ;;
  ;; Stack Functionality
  ;;

  (func $stack_push
    (param $val i32)

    ;; Throw if stack at 32 already
    (block $B0
      global.get $movable_stack_ptr
      i32.const 32
      i32.eq
      br_if $B0
      unreachable
    )

    ;; get ptr
    global.get $movable_stack_ptr
    ;; get value
    local.get $val
    ;; push to stack
    i32.store16

    ;; move stack ptr forward by 1
    global.get $movable_stack_ptr
    i32.const 2
    i32.add
    global.set $movable_stack_ptr
  )

  (func $stack_pop
    (result i32)
    (local $temp i32)

    ;; Throw if stack is at 0 already
    (block $B0
      global.get $movable_stack_ptr
      i32.eqz
      i32.eqz
      br_if $B0
      unreachable
    )

    ;; move pointer back by 1
    global.get $movable_stack_ptr
    i32.const -2
    i32.add
    ;; Set temp but tee further
    local.tee $temp
    ;; Pop from stack
    i32.load16_u

    ;; Set pointer
    local.get $temp
    global.set $movable_stack_ptr
  )
)