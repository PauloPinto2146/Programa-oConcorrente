float angle1;
float angle2;
float angle3;
float angle4;
float centerX = 540; // Coordenada x do centro (Sol)
float centerY = 360; // Coordenada y do centro (Sol)
float velocidade1,velocidade2,velocidade3, velocidade4;

float x1,x2,x3,x4;
float y1,y2,y3,y4;
float distSol1,distSol2,distSol3,distSol4;

int curr_level;

float[] starX = new float[100];
float[] starY = new float[100];
float[] starSize = new float[100];

float numEstrelas = 100;

float angle = 0;
float orbitRadius = 100;
float tamanho = 0.7;

boolean loggedIn = false;
boolean waitingForLobby = false;
String receivedData = ""; 

import processing.net.*;

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

color blue = color(66, 135, 245);
color white = color(255);

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
  } else if (activeScreen == "START_GAME"){
    drawGame();
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
  
  println("Socket lançado: " +"11 " + curr_level + " " + popupUsername);
  socket.write("11 "+ curr_level + " " + popupUsername);
  //delay(30);
  if (socket.available() > 0) {
    String data = socket.readString();
    if (data != null) {
       receivedData = data.trim();
       println("Received: " + receivedData);
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
    ArrayList<Integer> resultList = new ArrayList<Integer>(20);
    for (String element : elements) {
        String cleanElement = element.replaceAll("{", "").replaceAll("}", "");
        resultList.add(int(cleanElement));
    }

    //[{Posição1X,Posicao1Y,Angulo1,Velocidade1,DistSol1},
    // {Posição2X,Posicao2Y,Angulo2,Velocidade2,DistSol2},
    // {Posição3X,Posicao3Y,Angulo3,Velocidade3,DistSol3},
    // {Posição4X,Posicao4Y,Angulo4,Velocidade4,DistSol4}]
    
    x1 = resultList.get(0);
    y1 = resultList.get(1);
    angle1 = resultList.get(2);
    velocidade1 = resultList.get(3);
    distSol1 = resultList.get(4);
    x2 = resultList.get(5);
    y2 = resultList.get(6);
    angle2 = resultList.get(7);
    velocidade2 = resultList.get(8);
    distSol2 = resultList.get(9);
    x3 = resultList.get(10);
    y3 = resultList.get(11);
    angle3 = resultList.get(12);
    velocidade3 = resultList.get(13);
    distSol3 = resultList.get(14);
    x4 = resultList.get(15);
    y4 = resultList.get(16);
    angle4 = resultList.get(17);
    velocidade4 = resultList.get(18);
    distSol4 = resultList.get(19);
    
    
    // Desenha o Sol
    fill(255, 204, 0); 
    noStroke();
    ellipse(centerX, centerY, 150, 150);
    
    //Planeta 1
    fill(161, 89, 8); 
    noStroke(); 
    ellipse(x1, y1, 15, 15);
    angle1 += velocidade1;
    
    //Planeta 2
    fill(88, 237, 230); 
    noStroke(); 
    ellipse(x2, y2, 25, 25);
    angle2 += velocidade2;
    
    //Planeta 3
    fill(10, 120, 10); 
    noStroke(); 
    ellipse(x3, y3, 30, 30);
    angle3 += velocidade3;
    
    //Planeta 4
    fill(119, 2, 222); 
    noStroke(); 
    ellipse(x4, y4, 36, 36);
    angle4 += velocidade4;
  }
  if(receivedData.equals("Error")){
    activeScreen = "ERROR_POPUP";
    println("ERROR");
  }
}

void drawPopupWindow(int w, int h, int px, int py){
  fill(white);
  rect(px, py, w, h, 20);
}

void drawReturnMessage(int w, int h, int px, int py){
  fill(100); // Gray
  textAlign(CENTER, CENTER);
  textSize(18);
  text("Press BACKSPACE to return", px, py + h - 35, w, 40);
}

void drawMenu() {
  int popupWidth = 600, popupHeight = 400;
  int popupX = width / 2 - popupWidth / 2;
  int popupY = height / 2 - popupHeight / 2;

  backgroundStars();
  drawPopupWindow(popupWidth, popupHeight, popupX, popupY);
  
  // Draw title
  textAlign(CENTER, CENTER);
  textSize(48);
  fill(blue); // Blue color
  text("The Game", width / 2, height / 4 + 25);

  // Calculate the y-position for the first button
  int startY = height / 2 - buttonHeight;
  stroke(0);
  drawButton(buttonX, startY, "Login", menuButtonIndex == 1, blue);
  drawButton(buttonX, startY + buttonHeight + buttonSpacing, "Register", menuButtonIndex == 2, blue);
  drawButton(buttonX, startY + buttonHeight * 2 + buttonSpacing * 2, "Quit", menuButtonIndex == 3, blue);
}

void drawLoginPopup() {
  int popupWidth = 300, popupHeight = 260;
  int popupX = width / 2 - popupWidth / 2;
  int popupY = height / 2 - popupHeight / 2;

  backgroundStars();
  drawPopupWindow(popupWidth, popupHeight, popupX, popupY);
  
  // Draw title
  textAlign(CENTER, CENTER);
  textSize(24);
  fill(blue);
  text("Login", popupX, popupY + 10, popupWidth, 30);
   
  stroke(0);

  // Draw username label and password label
  drawTextBox(popupX + 25, popupY + 50, popupButtonIndex == 1, white, popupUsername);
  drawTextBox(popupX + 25, popupY + 110, popupButtonIndex == 2, white, popupPassword);

  // Draw confirm button
  drawButton(popupX + 75, popupY + popupHeight - 70, "Confirm", popupButtonIndex == 3, blue);
  
  drawReturnMessage(popupWidth, popupHeight, popupX, popupY);
}

// Draw register popup screen
void drawRegisterPopup() {
  int popupWidth = 300, popupHeight = 310;
  int popupX = width / 2 - popupWidth / 2;
  int popupY = height / 2 - popupHeight / 2;

  backgroundStars();
  drawPopupWindow(popupWidth, popupHeight, popupX, popupY);

  // Draw title
  textAlign(CENTER, CENTER);
  textSize(24);
  fill(blue);
  text("Register", popupX, popupY + 10, popupWidth, 30);

  stroke(0);
  // Draw username, password, and confirm password labels
  drawTextBox(popupX + 25, popupY + 50, popupButtonIndex == 1, white, popupUsername);
  drawTextBox(popupX + 25, popupY + 110, popupButtonIndex == 2, white, popupPassword);
  drawTextBox(popupX + 25, popupY + 170, popupButtonIndex == 3, white, confirmPassword);

  // Draw confirm button
  drawButton(popupX + 75, popupY + popupHeight - 70, "Confirm", popupButtonIndex == 4, blue);
  
  drawReturnMessage(popupWidth, popupHeight, popupX, popupY);
}

void drawLobby(){
  int popupWidth = 600, popupHeight = 400;
  int popupX = width / 2 - popupWidth / 2;
  int popupY = height / 2 - popupHeight / 2;

  backgroundStars();
  drawPopupWindow(popupWidth, popupHeight, popupX, popupY);
  
  // Draw title
  textAlign(CENTER, CENTER);
  textSize(48);
  fill(blue);
  text("Welcome, " + popupUsername + "!", width / 2, height / 4 + 25);
  textSize(24);
  fill(0,0,0);
  text("You are level " + curr_level + "!", width / 2, height / 4 +75);
  // Calculate the y-position for the first button
  int startY = height / 2 - buttonHeight;
  stroke(0);
  drawButton(buttonX, startY, "Start Game", menuButtonIndex == 1, blue);
  drawButton(buttonX, startY + buttonHeight  + buttonSpacing, "Tutorial", menuButtonIndex == 2, blue);
  drawButton(buttonX, startY + buttonHeight * 2 + buttonSpacing * 2, "Logout", menuButtonIndex == 3, blue);
}

void drawTutorialPopup() {
  int popupWidth = 400, popupHeight = 300;
  int popupX = width / 2 - popupWidth / 2;
  int popupY = height / 2 - popupHeight / 2;

  backgroundStars();
  drawPopupWindow(popupWidth, popupHeight, popupX, popupY);
  
  // Draw title
  textAlign(CENTER, CENTER);
  textSize(24);
  fill(blue);
  text("Tutorial", popupX, popupY +10, popupWidth, 30);
  
  // Draw tutorial text
  String tutorialText = "Welcome to the Tutorial!\n\nUse AWSD keys to move around.\n\nBe the last one standing and win the game!.";
  fill(0); // Black color
  textAlign(LEFT, TOP);
  textSize(18);
  text(tutorialText, popupX + 20, popupY + 50, popupWidth - 40, popupHeight - 40);
  
  drawReturnMessage(popupWidth, popupHeight, popupX, popupY);
}

void drawErrorPopup() {
  int popupWidth = 400, popupHeight = 200;
  int popupX = width / 2 - popupWidth / 2;
  int popupY = height / 2 - popupHeight / 2;

  backgroundStars();
  drawPopupWindow(popupWidth, popupHeight, popupX, popupY);
  
  // Draw title
  textAlign(CENTER, CENTER);
  textSize(24);
  fill(blue);
  text("Oops!", popupX, popupY + 10, popupWidth, 30);
  
  // Draw error text
  fill(0); // Black color
  textAlign(CENTER, CENTER);
  textSize(18);
  text(errorText, popupX, popupY + 20, popupWidth, popupHeight - 40);
  
  drawReturnMessage(popupWidth, popupHeight, popupX, popupY);
}

void drawLoadingScreen() {
  
  backgroundStars();
  
  // Draw popup window
  int popupWidth = 600;
  int popupHeight = 350;
  int popupX = width/2 - popupWidth/2;
  int popupY = height/2 - popupHeight/2;
  drawPopupWindow(popupWidth, popupHeight, popupX, popupY);
  
  // Draw title
  textAlign(CENTER, CENTER);
  textSize(24);
  fill(66, 135, 245);
  text("Looking for a Match...", popupX, popupY + 10, popupWidth, 30);
  
  drawReturnMessage(popupWidth, popupHeight, popupX, popupY);
  
  //trajetória
  noFill();
  stroke(0);
  ellipse(width/2, height/2, 210, 210);
  
  // Desenha o planeta no centro
  noStroke();
  fill(210, 105, 30);
  ellipse(width / 2, height / 2, 100, 100);
  

  // Adiciona sombras para criar profundidade
  for (int i = 0; i < 30; i++) {
    fill(210 - i * 2, 105 - i, 30 - i / 2, 150 - i); // Gradiente de cor para sombra
    ellipse(width / 2 - i / 10, height / 2 - i / 10, 100 - i, 100 - i);
  }

  // Adiciona manchas escuras
  fill(139, 69, 19, 180); // Cor marrom escuro semi-transparente
  ellipse(width / 2 - 20, height / 2 + 10, 20, 10);
  ellipse(width / 2 + 15, height / 2 - 20, 15, 8);
  ellipse(width / 2 - 10, height / 2 - 30, 25, 12);

  // Adiciona pequenos pontos brilhantes
  fill(255, 255, 255, 200); // Cor branca semi-transparente
  ellipse(width / 2 + 5, height / 2 + 15, 5, 5);
  ellipse(width / 2 - 15, height / 2 - 10, 4, 4);
  ellipse(width / 2 + 10, height / 2 - 5, 3, 3);

  float x = width / 2 + cos(angle) * orbitRadius;
  float y = height / 2 + sin(angle) * orbitRadius;

  pushMatrix();
  translate(x, y);
  rotate(atan2(height / 2 - y, width / 2 - x));
  
  // Área do foguete
  fill(255);
  stroke(255);
  ellipse(0, 0, 80 * tamanho, 150 * tamanho);
  
  stroke(0);
  
  // Janela
  fill(105, 208, 247);
  ellipse(0, -19 * tamanho, 28 * tamanho, 25 * tamanho);
  
  // Propulsores
  fill(121,121,121);
  rect(-35 * tamanho, 8 * tamanho, 70 * tamanho, 10 * tamanho);
  
  beginShape();
  vertex(-5 * tamanho, 26 * tamanho);
  vertex(5 * tamanho, 26 * tamanho);
  vertex(15 * tamanho, 36 * tamanho);
  vertex(-15 * tamanho, 36 * tamanho);
  endShape(CLOSE);
  
  // Asas da nave
  fill(255, 0, 0);
  beginShape();
  vertex(-22 * tamanho, -10 * tamanho);
  vertex(-48 * tamanho, 25 * tamanho);
  vertex(-10 * tamanho, 2 * tamanho);
  endShape(CLOSE);

  beginShape();
  vertex(22 * tamanho, -10 * tamanho);
  vertex(48 * tamanho, 25 * tamanho);
  vertex(10 * tamanho, 2 * tamanho);
  endShape(CLOSE);
  
  rect(-12.5 * tamanho, 20 * tamanho, 25 * tamanho, 10 * tamanho);
  
  // Corpo da nave
  fill(200);
  ellipse(0, 0, 50 * tamanho, 50 * tamanho);
  
  popMatrix();

  angle += 0.02;
  
  if (socket.available() > 0) {
     String data = socket.readString();
     if (data != null) {
     receivedData = data.trim();
     println("Received: " + receivedData);
     }
     else{
        println("Null Socket");
     }
  }
  if (receivedData.equals("game_started")) {
    activeScreen = "START_GAME";
  }
  if(receivedData.equals("ERROR:Lobby_found_but_full")){
     activeScreen = "LOADING";
  }
}

// Draw button function
void drawButton(int x, int y, String label, boolean focused, color buttonColor) {
  if (focused) {
    fill(lerpColor(buttonColor, color(0), 0.3));
  } else {
    fill(buttonColor);
  }
  rect(x, y, buttonWidth, buttonHeight, 20);

  // Button text
  fill(white);
  textSize(24);
  text(label, x + buttonWidth / 2, y + buttonHeight / 2);
}

void drawTextBox(int x, int y, boolean focused, color boxColor, String text) {
  if (focused) {
    fill(lerpColor(boxColor, color(0), 0.1));
  } else {
    fill(boxColor);
  }
  rect(x, y, TextBoxWidth, TextBoxHeight);

  // Display the text
  fill(0); // Black color
  textAlign(CENTER, CENTER);
  textSize(24);
  text(text, x + TextBoxWidth / 2, y + TextBoxHeight / 2);
}

void keyPressed() {
  if (activeScreen == "START_GAME"){
    if(keyCode == UP || key == 'w'){
      println("Started game");
    }
  }
  if (activeScreen == "MENU") {
    if (keyCode == UP || key == 'w') {
      menuButtonIndex = max(1, menuButtonIndex - 1);
    } else if (keyCode == DOWN || key == 's') {
      menuButtonIndex = min(3, menuButtonIndex + 1);
    }
    println(menuButtonIndex);
  } else if (activeScreen == "LOGIN_POPUP") {
    if (typing) {
      typing();
    } else {
      if (key == BACKSPACE) {
        popupUsername = "Username";
        popupPassword = "Password";
        activeScreen = "MENU";
      }
      if (keyCode == UP || key == 'w') {
        popupButtonIndex = max(1, popupButtonIndex - 1);
      } else if (keyCode == DOWN || key == 's') {
        popupButtonIndex = min(3, popupButtonIndex + 1);
      }
    }
  } else if (activeScreen == "REGISTER_POPUP") {
    if (typing) {
      typing();
    } else {
      if (key == BACKSPACE) {
        popupUsername = "Username";
        popupPassword = "Password";
        confirmPassword = "Confirm Password";
        activeScreen = "MENU";
      }
      if (keyCode == UP || key == 'w') {
        popupButtonIndex = max(1, popupButtonIndex - 1);
      } else if (keyCode == DOWN || key == 's') {
        popupButtonIndex = min(4, popupButtonIndex + 1);
      }
    }
  } if (activeScreen == "LOBBY") {
      if (keyCode == UP || key == 'w') {
        menuButtonIndex = max(1, menuButtonIndex - 1);
      } else if (keyCode == DOWN || key == 's') {
        menuButtonIndex = min(3, menuButtonIndex + 1);
      }
  } else if (activeScreen == "TUTORIAL_POPUP") {
    if (key == BACKSPACE) {
      activeScreen = "LOBBY";
    }
  } else if (activeScreen == "ERROR_POPUP") {
    if (key == BACKSPACE) {
      activeScreen = prevMenu;
    }
  }else if (activeScreen == "LOADING") {
    if (key == BACKSPACE && !matchfound) {
      println("Socket lançado: " +"11 " + curr_level + " " + popupUsername);
          socket.write("11 "+ curr_level + " " + popupUsername);
          delay(30);
          if (socket.available() > 0) {
            String data = socket.readString();
            if (data != null) {
              receivedData = data.trim();
              println("Received: " + receivedData);
              }
            else{
              errorText = "Unknown Error";
              activeScreen = "ERROR_POPUP";
              println("Null Socket");
            }
          }
          if (receivedData.equals("Cancelled_find")){
            println("Cancelei procura de partida");
            activeScreen = "LOBBY";
          }
          if(receivedData.equals("Error 11")){
            errorText = "Player Not Found";
            activeScreen = "ERROR_POPUP";
            println("Couldn't Cancel");
          } 
    }
     else {
          println("Outra tecla pressionada: " + key);
        }
    }
  }

// Check if Enter or Space keys are pressed
void keyReleased() {
  if (activeScreen == "MENU") {
    if (key == ENTER || key == ' ') {
      switch (menuButtonIndex) {
        case 1:
          activeScreen = "LOGIN_POPUP";
          break;
        case 2:
          activeScreen = "REGISTER_POPUP";
          break;
        case 3:
          exit();
          break;
      }
    }
  } else if (activeScreen == "LOGIN_POPUP") {
    if (key == ENTER || key == ' ') {
      switch (popupButtonIndex) {
        case 1:
          typing = !typing;
          if(popupUsername == "Username") popupUsername = "";
          println(popupUsername);
          break;
        case 2:
          typing = !typing;
          if(popupPassword == "Password") popupPassword = "";
          println(popupPassword);
          break;
        case 3:
          println("Confirm pressed!");
          println("Socket lançado: " +"00 "+popupUsername + " " + popupPassword);
          socket.write("00 "+popupUsername + " " + popupPassword);
          delay(30);
          if (socket.available() > 0) {
            String data = socket.readString();
            if (data != null) {
              receivedData = data.trim();
              println("Received: " + receivedData);
              }
            else{
              println("Null Socket");
            }
          }
          if (receivedData.startsWith("Logged_in,")) {
            String[] parts = receivedData.split(", ");
            if (parts.length == 2) {
            try {
              curr_level = Integer.parseInt(parts[1]);
              loggedIn = true;
              activeScreen = "LOBBY";
            } catch (NumberFormatException e) {
              println("Erro ao converter o nível: " + e.getMessage());
              }
            }
          }
          if(receivedData.equals("Error 00")){
            errorText = "This account doesn't exist";
            activeScreen = "ERROR_POPUP";
          }
          break;
      }
    }
  } else if (activeScreen == "REGISTER_POPUP") {
    if (key == ENTER || key == ' ') {
      switch (popupButtonIndex) {
        case 1:
          typing = !typing;
          if(popupUsername == "Username") popupUsername = "";
          println(popupUsername);
          break;
        case 2:
          typing = !typing;
          if(popupPassword == "Password") popupPassword = "";
          println(popupPassword);
          break;
        case 3:
          typing = !typing;
          if(confirmPassword == "Confirm Password") confirmPassword = "";
          println(confirmPassword);
          break;
        case 4:
          println("Confirm pressed!");
          if(popupUsername == "Username"){
            errorText = "\"Username\" is an invalid username";
            activeScreen = "ERROR_POPUP";
            println("Couldn't create account");
            loggedIn = false;
          }
          else{
            println("Socket lançado: " +"02 "+popupUsername + " " + popupPassword);
            socket.write("02 "+popupUsername + " " + popupPassword);
            delay(30);
            if (socket.available() > 0) {
              String data = socket.readString();
              if (data != null) {
                receivedData = data.trim();
                println("Received: " + receivedData);
                }
              else{
                errorText = "Unknown_error";
                activeScreen = "ERROR_POPUP";
                println("Null Socket");
              }
            }
            println(receivedData);
            if (receivedData.equals("created_Account")){
              curr_level = 1;
              loggedIn = true;
              println("DEI REGISTER");
              activeScreen = "LOBBY";
            }
            if(receivedData.equals("Error 01")){
              errorText = "This account already exists exist";
              activeScreen = "ERROR_POPUP";
              println("Couldn't create account");
              loggedIn = false;
            }
            break;
          }
        }
    }
  } else if (activeScreen == "LOBBY") {
    if (key == ENTER || key == ' ') {
      switch (menuButtonIndex) {
        case 1:
          println("Socket lançado: " +"10 " + popupUsername);
          socket.write("10 " + popupUsername);
          activeScreen = "LOADING";
          break;
        case 2:
          activeScreen = "TUTORIAL_POPUP";
          break;
        case 3:
          println("Socket lançado: " +"01 " + popupUsername);
          socket.write("01 "+ popupUsername);
          delay(30);
          if (socket.available() > 0) {
            String data = socket.readString();
            if (data != null) {
              receivedData = data.trim();
              println("Received: " + receivedData);
              }
            else{
              errorText = "Unknown Error";
              activeScreen = "ERROR_POPUP";
              println("Null Socket");
            }
          }
          println(receivedData);
          if (receivedData.equals("logged_out")){
            loggedIn = false;
            println("DEI LOGOUT");
            activeScreen = "MENU";
          }
          if(receivedData.equals("Error 01")){
            activeScreen = "ERROR_POPUP";
            println("Couldn't logout");
          }
          
          popupUsername = "Username";
          popupPassword = "Password";
          confirmPassword = "Confirm Password";
          activeScreen = "MENU";
          break;
      }
    }
  }
}

void typing() {
  if ((keyCode >= 32 && keyCode <= 126) || keyCode == BACKSPACE) {
    if (popupButtonIndex == 1) {
      if (keyCode == BACKSPACE) {
        if (popupUsername.length() > 0) {
          popupUsername = popupUsername.substring(0, popupUsername.length() - 1);
        }
      } else if (popupUsername.length() < 20) {
        popupUsername += key;
      }
    } else if (popupButtonIndex == 2) {
      if (keyCode == BACKSPACE) {
        if (popupPassword.length() > 0) {
          popupPassword = popupPassword.substring(0, popupPassword.length() - 1);
        }
      } else if (popupPassword.length() < 20) {
        popupPassword += key;
      }
    } else if (popupButtonIndex == 3) {
      if (keyCode == BACKSPACE) {
        if (confirmPassword.length() > 0) {
          confirmPassword = confirmPassword.substring(0, confirmPassword.length() - 1);
        }
      } else if (confirmPassword.length() < 20) {
        confirmPassword += key;
      }
    }
  }
}
