#include <SoftwareSerial.h>
SoftwareSerial BTSerial(10, 11);
byte sertialBT;
const int led = 8;


void setup() {
  Serial.begin(1200);
  BTSerial.begin(9600);
  pinMode(led,OUTPUT);
}

void loop() {
  sertialBT = BTSerial.read();
  Serial.print(sertialBT);
  if (sertialBT == 'A') {
    BTSerial.print("Hola");
    digitalWrite(led, HIGH);
    sertialBT == 'B';
  }
  if (sertialBT == 'C') {
    BTSerial.print("F");
    digitalWrite(led, LOW);
    sertialBT == 'B';
  }
  delay(100);
}
