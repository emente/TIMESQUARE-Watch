// micro-word-clock display

const int min_offset=4; // 12:00 + 5*4 min = zehn vor halb EINS

const char minutes[12][8] ={
    { // punkt
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000
    }
    , { // fuenf nach
        0B11110000,
        0B00011110,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000
    }
    , { // zehn nach
        0B00001111,
        0B00011110,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000
    }
    ,{ // fuenfzehn nach
        0B11111111,
        0B00011110,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000
    }
    ,{ // zehn vor halb
        0B00001111,
        0B11100000,
        0B11110000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000
    }
    ,{ // fuenf vor halb
        0B11110000,
        0B11100000,
        0B11110000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000
    }
    ,{ // halb
        0B00000000,
        0B00000000,
        0B11110000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000
    }
    ,{ // fuenf nach halb
        0B11110000,
        0B00011110,
        0B11110000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000
    }
    ,{ // zehn nach halb
        0B00001111,
        0B00011110,
        0B11110000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000
    }
    ,{ // fuenfzehn vor
        0B11111111,
        0B11100000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000
    }
    ,{ // zehn vor
        0B00001111,
        0B11100000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000
    }
    ,{ // 5 vor
        0B11110000,
        0B11100000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000
    }
};
const char hours[12][8] ={
    { // zwoelf
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00011111,
        0B00000000,
        0B00000000,
        0B00000000
    }
    ,{ // eins
        0B00000000,
        0B00000000,
        0B00000000,
        0B11110000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000
    }
    ,{ // zwei
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00011000,
        0B00000110,
        0B00000000,
        0B00000000,
    }
    ,{ // drei
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00011110,
        0B00000000,
        0B00000000,
    }
    ,{ // vier
        0B00000000,
        0B00000000,
        0B00001111,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
    }
    ,{ // fuenf
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000001,
        0B00000001,
        0B00000001,
        0B00000001,
    }
    ,{ // sechs
        0B00000000,
        0B00000000,
        0B00000000,
        0B00011111,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
    }
    ,{ // sieben
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B11100000,
        0B11100000,
        0B00000000,
        0B00000000,
    }
    ,{ // acht
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B11110000,
    }
    ,{ // neun
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00001111,
        0B00000000,
    }
    ,{ // zehn
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B01111000,
        0B00000000,
    }
    ,{ // elf
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000000,
        0B00000111,
    }
};

unsigned long disp_min;
unsigned long disp_hrs;

void drawByte(uint8_t b,uint8_t y) {
    for (uint8_t i=0;i<8;i++) {
       uint8_t p=1 << i;
//       watch.drawPixel(p-1,7,15);

       if (b & p) {
           watch.drawPixel(7-i,y,15);
       } 
    }   
}

void mode_marquee(uint8_t action) {
    if(action != ACTION_NONE) {
        // If we just arrived here (whether through mode change
        // or wake from sleep), initialize the matrix driver:
        if(action >= ACTION_HOLD_LEFT) {
            uint8_t depth = 2, plex = LED_PLEX_4;
            // Reduce depth/plex if battery voltage is low
            if(watch.getmV() < BATT_LOW_MV) {
                depth = 2;
                plex  = LED_PLEX_1;
            }
            // Reconfigure display if needed
            if((watch.getDepth() != depth) || (watch.getPlex() != plex))
                fps = watch.setDisplayMode(depth, plex, true);
                 watch.setRotation(0);
                 
            // Adjust 2.5 minutes = 150 seconds forward
            // So at 12:03 it already reads "five past 12"
            DateTime now = RTC.now().unixtime() + 150;

            disp_min = now.minute();
            disp_hrs = now.hour();

            disp_min /= 5;

            if(disp_min >= min_offset) 
                ++disp_hrs %= 12;
            else
                disp_hrs   %= 12;
        }

        // Reset sleep timeout on ANY button action
        watch.setTimeout(fps * 3);
    }

    uint16_t t = watch.getTimeout();
    uint8_t  b = (t < sizeof(fade)) ? (uint8_t)pgm_read_byte(&fade[t]) : 255;

    watch.fillScreen(BACKGROUND);

    for (uint8_t y=0; y<8; y++) {
        drawByte(hours[disp_hrs][y],y);
    }  
    for (uint8_t y=0; y<8; y++) {
        drawByte(minutes[disp_min][y],y);
    }  


}




