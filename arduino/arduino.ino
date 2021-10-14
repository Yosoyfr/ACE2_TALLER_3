int ledPin = 8;
int cmd = -1;
int flag = 0;
float temperature = 23;
unsigned long time_ = 0;
unsigned long interval = 10000;

void setup()
{
  pinMode(ledPin, OUTPUT);   // Configuramos el ledPin como output
  digitalWrite(ledPin, LOW); // Apagamos la LED
  Serial.begin(9600);        // Comunicación a los pines RX y TX
  time_ = millis();
}

void loop()
{
  if (Serial.available() > 0) // Función que obtiene el número de bytes (caracteres) disponibles para su lectura
  {
    cmd = Serial.read(); // Función que permite leer (recibir) bytes mediante un puerto Serial
    flag = 1;
  }

  if (flag == 1)
  {
    if (cmd == '0')
    {
      digitalWrite(ledPin, LOW); // Apagamos la LED
    }
    else if (cmd == '1')
    {
      digitalWrite(ledPin, HIGH); // Prendemos la LED
    }
    flag = 0;
    cmd = 65;
  }

  if (millis() - time_ > interval)
  { // Simulacion de proceso en otro plano
    float decimal = random(0, 99);
    decimal = decimal / 100;
    temperature = random(22, 28);
    temperature = temperature + decimal;
    Serial.println(temperature); // Envio del dato de temperatura
    time_ = millis();
  }

  Serial.flush(); // Asegura que se transmitan todos los datos y que el búfer esté vacío ahora.
  delay(100);
}
