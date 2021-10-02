int ledPin = 8;
int cmd = -1;
int flag = 0;
float temperature = 23;
unsigned long time_ = 0;
unsigned long interval = 10000;

void setup()
{
  pinMode(ledPin, OUTPUT);
  digitalWrite(ledPin, LOW);
  Serial.begin(9600);
  time_ = millis();
}

void loop()
{
  if (Serial.available() > 0)
  {
    cmd = Serial.read();
    flag = 1;
  }

  if (flag == 1)
  {
    if (cmd == '0')
    {
      digitalWrite(ledPin, LOW);
    }
    else if (cmd == '1')
    {
      digitalWrite(ledPin, HIGH);
    }
    flag = 0;
    cmd = 65;
  }

  if(millis()-time_ > interval ){
    float decimal = random(0, 99);
    decimal = decimal / 100;
    temperature = random(22, 28);
    temperature = temperature + decimal;
    Serial.println(temperature);
    time_ = millis();
  }
  
  Serial.flush();
  delay(100);
}
