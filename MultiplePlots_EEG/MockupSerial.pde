// If you want to debug the plotter without using a real serial port

int mockupValue = 0;
int mockupDirection = 10;
float angle_mock = 0;

int Fs_mock = 250;

String mockupSerialFunction() {
 
  while (true) {
    String r = "";
    
    if (millis() - lastStepTime > (1000/Fs_mock)) {
      //int val = int((random(30)-15)*1000);
      float val2 = (1*sin(angle_mock*21)+(1*sin(angle_mock*2))+(1*sin(angle_mock*5.5))+(1*sin(angle_mock*10.5))+(20*sin(angle_mock*60))+(random(10)-5)/10)*8000;

      r += val2;
      r += '\r';
      
      angle_mock += (2*3.14159/Fs_mock);
      lastStepTime = millis();
      return r;
    }
    
  }
}
