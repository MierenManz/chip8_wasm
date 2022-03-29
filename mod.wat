(module
  ;; First 16 bytes are general purpose registries (v registries)
  ;; The 32b after this are the stack as 16xu16
  ;; The 4kb after this is the ram
  ;; The 2kb after this is the writable frame buffer
  (memory (export "memory") 1)

  ;; Constants
  (global $stack_base_ptr (export "stackBasePtr") i32 (i32.const 16))
  (global $ram_base_ptr (export "ramBasePtr") i32 (i32.const 48))
  (global $frame_buffer_base_ptr (export "frameBufferBasePtr") i32 (i32.const 4144))

  ;; Emulator registers
  ;; Also known as `pc`
  (global $program_counter (export "programCounter") (mut i32) (i32.const 512))
  ;; Also known as `i_reg`
  (global $movable_ram_ptr (export "movableRamPtr") (mut i32) (i32.const 0))
  ;; Also known as `sp`
  (global $movable_stack_ptr (export "movableStackPtr") (mut i32) (i32.const 0))
  ;; Also known as `dt`
  (global $delay_timer (export "delayTimer") (mut i32) (i32.const 0))
  ;; Also known as `st`
  (global $sound_timer (export "soundTimer") (mut i32) (i32.const 0))

  (func $stack_push
    (export "stackPush")
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
    (export "stackPop")
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