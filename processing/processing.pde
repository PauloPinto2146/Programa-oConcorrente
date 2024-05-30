import processing.net.*;

float angle1;
float angle2;
float angle3;
float angle4;
float centerX = 540; // Coordenada x do centro (Sol)
float centerY = 360; // Coordenada y do centro (Sol)
float velocidade1,velocidade2,velocidade3, velocidade4;

float x1,x2,x3,x4;
float y1,y2,y3,y4;
float raio1,raio2,raio3,raio4;

float p1x=50,p2x=1030,p3x=1030,p4x=50;
float p1y=50,p2y=690,p3y=50,p4y=690;

int curr_level;

float combustivel1,combustivel2,combustivel3,combustivel4;
float angulo1,angulo2,angulo3,angulo4;
float velocidade1p,velocidade2p,velocidade3p,velocidade4p;
float acceleration1,acceleration2,acceleration3,acceleration4;

float[] starX = new float[100];
float[] starY = new float[100];
float[] starSize = new float[100];

float numEstrelas = 100;

float angle = 0;
float orbitRadius = 100;
float tamanho = 0.7;

int numJogador;

boolean loggedIn = false;
boolean waitingForLobby = false;
String receivedData = ""; 

int buttonWidth = 150, buttonHeight = 40, buttonSpacing = 10;
int buttonX, buttonY;
int TextBoxWidth = 250, TextBoxHeight = 40;

String activeScreen = "MENU";
String prevMenu = "MENU";

String popupUsername = "Username", popupPassword = "Password", confirmPassword = "Confirm Password";
String returnText = "Press BACKSPACE to return", errorText = "Sample error text.";
int menuButtonIndex = 1, popupButtonIndex = 1;

boolean typing = false;
boolean matchfound = false; // ativar este boolean para impedir cancelamento da procura
boolean left_boost = false;
boolean right_boost = false;
boolean main_boost = false;

color blue = color(66, 135, 245);
color white = color(255);
color boost = color(138, 210, 245);
float fuel = 100;

Client socket;

void setup() {
  size(1080, 720); 
  for (int i = 0; i < numEstrelas; i++) {
    starX[i] = random(0,1080);
    starY[i] = random(0,720);
    starSize[i] = random(1, 3);
  }
  buttonX = width / 2 - buttonWidth / 2;
  buttonY = height / 2 - buttonHeight * 2;
  socket = new Client(this, "127.0.0.1", 8080);
  if (socket.active()) {
    println("Connected to server");
  } else {
    println("Failed to connect to server");
  }
}

void draw() {
  background(white);
  if (activeScreen == "MENU") {
    drawMenu();
  } else if (activeScreen == "LOGIN_POPUP") {
    drawLoginPopup();
  } else if (activeScreen == "REGISTER_POPUP") {
    drawRegisterPopup();
  } else if (activeScreen == "TUTORIAL_POPUP") {
    drawTutorialPopup();
  } else if (activeScreen == "LOBBY") {
    drawLobby();
  } else if (activeScreen == "ERROR_POPUP"){
    drawErrorPopup();
  } else if (activeScreen == "LOADING"){
    drawLoadingScreen();
  } else if (activeScreen == "GAME"){
    drawGame();
  } else if (activeScreen == "LOSE"){
    drawLossScreen();
  } else if(activeScreen == "WIN"){
    drawWinScreen();
  }
}

void backgroundStars(){
  background(11, 18, 77);
  
  fill(white);
  noStroke();
  for (int i = 0; i < numEstrelas; i++) {
    ellipse(starX[i], starY[i], starSize[i], starSize[i]);
  }
}

void drawGame() {
  backgroundStars();
  
  if (socket.available() > 0) {
    String data = socket.readString();
    if (data != null) {
       receivedData = data.trim();
    }
    else{
      errorText = "Unknown Error";
      activeScreen = "ERROR_POPUP";
      println("Null Socket");
    }
  }
  if (receivedData.startsWith("[{")){
    String cleanInput = receivedData.substring(1, receivedData.length() - 1);
    String[] elements = cleanInput.split(",");
    ArrayList<Float> resultList = new ArrayList<Float>();
    for (String element : elements) {
        String cleanElement = element.replaceAll("\\[\\{", "")
                                     .replaceAll("\\{", "")
                                     .replaceAll("}", "")
                                     .replaceAll("}]","")
                                     .replaceAll(" ","");
        resultList.add(float(cleanElement));
    }
      //[{Velocidade1,Angle1,Raio1,DistSol1},
      // {Velocidade2,Angle2,Raio2,DistSol2},
      // {Velocidade3,Angle3,Raio3,DistSol3},
      // {Velocidade4,Angle4,Raio4,DistSol4}]
      velocidade1 = resultList.remove(0);
      angle1 = resultList.remove(0);
      raio1 = resultList.remove(0);resultList.remove(0);
      
      velocidade2 = resultList.remove(0);
      angle2 = resultList.remove(0);
      raio2 = resultList.remove(0);resultList.remove(0);
      
      velocidade3 = resultList.remove(0);
      angle3 = resultList.remove(0);
      raio3 = resultList.remove(0);resultList.remove(0);
      
      velocidade4 = resultList.remove(0);
      angle4 = resultList.remove(0);
      raio4 = resultList.remove(0);resultList.remove(0);
      
      // Desenha o Sol
      fill(255, 204, 0); 
      noStroke();
      ellipse(centerX, centerY, 150, 150);
      
      //Planeta 1
      drawPlanet(color(186, 183, 175), 15.0, x1, y1);
      x1 = 540 + cos(angle1) * 120;
      y1 = 360 + sin(angle1) * 120;
      angle1 += velocidade1;
      
      //Planeta 2
      drawPlanet(color(189, 126, 0), 25.0, x2, y2);
      x2 = 540 + cos(angle2) * 220;
      y2 = 360 + sin(angle2) * 220;
      angle2 += velocidade2;
      
      //Planeta 3
      drawPlanet(color(86, 227, 150), 30.0, x3, y3);
      x3 = 540 + cos(angle3) * 280;
      y3 = 360 + sin(angle3) * 280;
      angle3 += velocidade3;
      
      //Planeta 4
      drawPlanet(color(194, 17, 191), 36.0, x4, y4);
      x4 = 540 + cos(angle4) * 340;
      y4 = 360 + sin(angle4) * 340;
      angle4 += velocidade4;
    //[{Combustivel1,Angulo1,velocidade1,aceleração1,Pid1,P1X,P1Y},
    // {Combustivel2,Angulo2,velocidade2,aceleração2,Pid2,P2X,P2Y},
    // {Combustivel3,Angulo3,velocidade3,aceleração3,Pid3,P3X,P3Y},
    // {Combustivel4,Angulo4,velocidade4,aceleração4,Pid4,P4X,P4Y}]
    if(resultList.size() == 7){
      combustivel1 = resultList.remove(0);
      angulo1 = 90 - resultList.remove(0);
      velocidade1p = resultList.remove(0);
      acceleration1 = resultList.remove(0);
      resultList.remove(0);
      p1x = resultList.remove(0);
      p1y = resultList.remove(0);

      if(numJogador == 1)
        drawNave(p1x,p1y,angulo1,0.7,color(0,0,255));
      else
        drawNave(p1x,p1y,angulo1,0.7,color(255,0,0));
      
      switch(numJogador){
        case 1:
          drawFuelBar(combustivel1);
        case 2:
          drawFuelBar(combustivel2);
      }
    }
    if(resultList.size() == 14){
      combustivel1 = resultList.remove(0);
      angulo1 = 90 - resultList.remove(0);
      velocidade1p = resultList.remove(0);
      acceleration1 = resultList.remove(0);
      resultList.remove(0);
      p1x = resultList.remove(0);
      p1y = resultList.remove(0);
      
      combustivel2 = resultList.remove(0);
      angulo2 = 90 - resultList.remove(0);
      velocidade2p = resultList.remove(0);
      acceleration2 = resultList.remove(0);
      resultList.remove(0);
      p2x = resultList.remove(0);
      p2y = resultList.remove(0);
      
      drawNave(p1x,p1y,angulo1,0.7,color(0,0,255));
      drawNave(p2x,p2y,angulo2,0.7,color(255,0,0));
      
      switch(numJogador){
        case 1:
          drawFuelBar(combustivel1);
        case 2:
          drawFuelBar(combustivel2);
      }
    }
    if(resultList.size() == 21){
      combustivel1 = resultList.remove(0);
      angulo1 = 90 - resultList.remove(0);
      velocidade1p = resultList.remove(0);
      acceleration1 = resultList.remove(0);
      resultList.remove(0);resultList.remove(0);resultList.remove(0);
      
      combustivel2 = resultList.remove(0);
      angulo2 = 90 - resultList.remove(0);
      velocidade2p = resultList.remove(0);
      acceleration2 = resultList.remove(0);
      resultList.remove(0);resultList.remove(0);resultList.remove(0);
      
      combustivel3 = resultList.remove(0);
      angulo3 = 90 - resultList.remove(0);
      velocidade3p = resultList.remove(0);
      acceleration3 = resultList.remove(0);
      
      drawNave(p1x,p1y,angulo1,50,color(0,0,255));
      drawNave(p2x,p2y,angulo1,50,color(255,0,0));
      drawNave(p3x,p3y,angulo3,50,color(0,255,0));
      
      switch(numJogador){
        case 1:
          drawFuelBar(combustivel1);
        case 2:
          drawFuelBar(combustivel2);
        case 3:
          drawFuelBar(combustivel3);
      }
    }
    if(resultList.size() == 28){
      combustivel1 = resultList.remove(0);
      angulo1 = 90 - resultList.remove(0);
      velocidade1p = resultList.remove(0);
      acceleration1 = resultList.remove(0);
      resultList.remove(0);resultList.remove(0);
      p1x = resultList.remove(0);
      p1y = resultList.remove(0);
      
      combustivel2 = resultList.remove(0);
      angulo2 = 90 - resultList.remove(0);
      velocidade2p = resultList.remove(0);
      acceleration2 = resultList.remove(0);
      resultList.remove(0);resultList.remove(0);
      p2x = resultList.remove(0);
      p2y = resultList.remove(0);
      
      combustivel3 = resultList.remove(0);
      angulo3 = 90 - resultList.remove(0);
      velocidade3p = resultList.remove(0);
      acceleration3 = resultList.remove(0);
      resultList.remove(0);resultList.remove(0);
      p3x = resultList.remove(0);
      p3y = resultList.remove(0);
      
      combustivel4 = resultList.remove(0);
      angulo4 = 90 - resultList.remove(0);
      velocidade4p = resultList.remove(0);
      acceleration4 = resultList.remove(0);resultList.remove(0);
      p4x = resultList.remove(0);
      p4y = resultList.remove(0);

      drawNave(p1x,p1y,angulo1,50,color(0,0,255));
      drawNave(p2x,p2y,angulo1,50,color(255,0,0));
      drawNave(p3x,p3y,angulo3,50,color(0,255,0));
      drawNave(p4x,p4y,angulo4,50,color(255,255,0));
      
      switch(numJogador){
        case 1:
          drawFuelBar(combustivel1);
        case 2:
          drawFuelBar(combustivel2);
        case 3:
          drawFuelBar(combustivel3);
        case 4:
          drawFuelBar(combustivel4);
      }
    }
  }
  if (receivedData.endsWith("lost")){
    println("Recebi Collision Detected");
    activeScreen = "LOSE";
  }
  else if (receivedData.endsWith("win") || receivedData.startsWith("win")){
    println("GANHEI");
    activeScreen = "WIN";
  }
  else if(receivedData.equals("Error")){
    activeScreen = "ERROR_POPUP";
    println("ERROR_POPUP");
  }
}
