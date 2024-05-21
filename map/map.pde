float angle1 = random(360);
float angle2 = random(360);
float angle3 = random(360);
float angle4 = random(360);
float centerX = 540; // Coordenada x do centro (Sol)
float centerY = 360; // Coordenada y do centro (Sol)
float velocidade1 = random(0.005,0.04);
float velocidade2 = random(0.001,0.02);
float velocidade3 = random(0.0008,0.012);
float velocidade4 = random(0.0005,0.008);

float[] starX = new float[100];
float[] starY = new float[100];
float[] starSize = new float[100];

float numEstrelas = 100;

import java.io.*;
import java.net.*;
import java.util.Scanner;
public class Client {
    public void main(String[] args) {
        Socket connection = new Socket("localhost", Port);
        DataOutputStream output = new DataOutputStream(connection.getOutputStream());
        Scanner sc = new Scanner(System.in);
        while(true) {
            output.writeBytes(sc.nextLine());
        }
    }
}

void setup() {
  size(1080, 720); 
  for (int i = 0; i < numEstrelas; i++) {
    starX[i] = random(0,1080);
    starY[i] = random(0,720);
    starSize[i] = random(1, 3); // Tamanho das estrelas varia entre 1 e 3 pixels
  }
}

void draw() {
  background(11, 18, 77);
  
  //estrelas
  fill(255, 255, 255);
  noStroke();
  for (int i = 0; i < numEstrelas; i++) {
    ellipse(starX[i], starY[i], starSize[i], starSize[i]);
  }
  
  // Desenha o Sol
  fill(255, 204, 0); 
  noStroke();
  ellipse(centerX, centerY, 150, 150);
  
  //Planeta 1
  float x1 = centerX + cos(angle1) * 120;
  float y1 = centerY + sin(angle1) * 120;
  fill(161, 89, 8); 
  noStroke(); 
  ellipse(x1, y1, 15, 15);
  angle1 += velocidade1;
  
  //Planeta 2
  float x2 = centerX + cos(angle2) * 220;
  float y2 = centerY + sin(angle2) * 220;
  fill(88, 237, 230); 
  noStroke(); 
  ellipse(x2, y2, 25, 25);
  angle2 += velocidade2;
  
  //Planeta 3
  float x3 = centerX + cos(angle3) * 280;
  float y3 = centerY + sin(angle3) * 280;
  fill(10, 120, 10); 
  noStroke(); 
  ellipse(x3, y3, 30, 30);
  angle3 += velocidade3;
  
  //Planeta 4
  float x4 = centerX + cos(angle4) * 340;
  float y4 = centerY + sin(angle4) * 340;
  fill(119, 2, 222); 
  noStroke(); 
  ellipse(x4, y4, 36, 36);
  angle4 += velocidade4;
}
