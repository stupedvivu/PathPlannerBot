//bot has 8,9 & 10,11 motor input l293d ic h-bridge
//bot for conquest at kshitij..
//bluetooth...


int leftmotfwd = 11;
int leftmotrvs = 10;
int rightmotfwd = 9;
int rightmotrvs = 8;
int ledPin = 13;
int pickupAndDropLed = 12;
char state;

int del = 120;
int del_low = 70;
int del_led = 200;

void setup() {
  Serial.begin(9600);
  pinMode(leftmotfwd, OUTPUT);
  pinMode(leftmotrvs, OUTPUT);
  pinMode(rightmotfwd, OUTPUT);
  pinMode(rightmotrvs, OUTPUT);
  pinMode(ledPin, OUTPUT);
  pinMode(pickupAndDropLed, OUTPUT);
}

void loop() {
  digitalWrite(pickupAndDropLed, LOW);
  digitalWrite(ledPin, LOW);
  digitalWrite(leftmotfwd, LOW);
  digitalWrite(rightmotfwd, LOW);
  digitalWrite(leftmotrvs, LOW);
  digitalWrite(rightmotrvs, LOW);
  while (Serial.available() == 0);
  
  state = Serial.read();
  digitalWrite(ledPin, HIGH);

  if ((state == 'f') || (state == 'F')) //forward
  { digitalWrite(leftmotfwd, HIGH);
    digitalWrite(rightmotfwd, HIGH);
    delay(del);
    digitalWrite(leftmotfwd, LOW);
    digitalWrite(rightmotfwd, LOW);
  }
  else if ((state == 'b') || (state == 'B')) //reverse
  { digitalWrite(leftmotrvs, HIGH);
    digitalWrite(rightmotrvs, HIGH);
    delay(del);
    digitalWrite(leftmotrvs, LOW);
    digitalWrite(rightmotrvs, LOW);
  }
  else if ((state == 'l') || (state == 'L')) //turn left
  { digitalWrite(leftmotrvs, HIGH);
    digitalWrite(rightmotfwd, HIGH);
    delay(del_low);
    digitalWrite(leftmotrvs, LOW);
    digitalWrite(rightmotfwd, LOW);
  }
  else if ((state == 'r') || (state == 'R')) //turn right
  { digitalWrite(leftmotfwd, HIGH);
    digitalWrite(rightmotrvs, HIGH);
    delay(del_low);
    digitalWrite(leftmotfwd, LOW);
    digitalWrite(rightmotrvs, LOW);
  }
  else if ((state == 'm') || (state == 'M')) //checking connection
  { delay(0.5);
    Serial.print('y');
  }
 else if ((state == 'p') || (state == 'P')) //light up pickup led
  { 
    digitalWrite(pickupAndDropLed, HIGH);
    delay(del_led);
    digitalWrite(pickupAndDropLed, LOW);
  }
}



