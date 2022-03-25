(module
  ;; First 16 bytes are general purpose registries (v registries)
  ;; The 32 bytes after this are the stack as 16xu16
  ;; The 4kb after this is the ram
  ;; The 2kb after this is the writable frame buffer
  (memory (export "memory") 1)

  ;; Constants
  (global $stack_base_ptr (export "stackBasePtr") i32 (i32.const 16))
  (global $ram_base_ptr (export "ramBasePtr") i32 (i32.const 48))

  ;; Emulator registers
  ;; Also known as `pc`
  (global $program_counter (export "programCounter" (mut i32) (i32.const 512)))
  ;; Also known as `i_reg`
  (global $movable_ram_ptr (export "movableRamPtr" (mut i32) (i32.const 0)))
  ;; Also known as `sp`
  (global $movable_stack_ptr (export "movableStackPtr" (mut i32) (i32.const 0)))
  ;; Also known as `dt`
  (global $delay_timer (export "delayTimer") (mut i32) (i32.const 0))
  ;; Also known as `st`
  (global $sound_timer (export "soundTimer") (mut i32) (i32.const 0))
)