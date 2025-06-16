void kernel_main() {
    char* video_memory = (char*) 0xb8000;
    video_memory[0] = 'O';
    video_memory[1] = 0x0F;
    video_memory[2] = 'K';
    video_memory[3] = 0x0F;
    while(1);
}
