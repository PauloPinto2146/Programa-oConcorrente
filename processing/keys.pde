void reset(){
  popupUsername = "Username";
  popupPassword = "Password";
  confirmPassword = "Confirm Password";
}

void keyPressed() {
  if (activeScreen.equals("LOADING")){
    if (key == BACKSPACE && !matchfound) {
      println("Socket lançado: 11 " + curr_level + " " + popupUsername);
      socket.write("11 " + curr_level + " " + popupUsername);
      delay(30);
      if (socket.available() > 0) {
        String data = socket.readString();
        if (data != null) {
          receivedData = data.trim();
          println("Received: " + receivedData);
        } else {
          errorText = "Unknown Error";
          activeScreen = "ERROR_POPUP";
          println("Null Socket");
        }
      }
      if (receivedData.equals("Cancelled_find")) {
        println("Cancelei procura de partida");
        activeScreen = "LOBBY";
      }
      if (receivedData.equals("Error 11")) {
        errorText = "Player Not Found";
        activeScreen = "ERROR_POPUP";
        println("Couldn't Cancel");
      }
    } else {
      println("Outra tecla pressionada: " + key);
    }
  } else if (activeScreen =="MENU") {
    if (keyCode == UP || key == 'w' || key == 'W') {
      menuButtonIndex = max(1, menuButtonIndex - 1);
    } else if (keyCode == DOWN || key == 's' || key == 'S') {
      menuButtonIndex = min(4, menuButtonIndex + 1);
    }
    println(menuButtonIndex);
  } else if (activeScreen.equals("LOGIN_POPUP")) {
    if (typing) {
      typing();
    } else {
      if (key == BACKSPACE) {
        reset();
        activeScreen = "MENU";
      }
      if (keyCode == UP || key == 'w' || key == 'W') {
        popupButtonIndex = max(1, popupButtonIndex - 1);
      } else if (keyCode == DOWN || key == 's' || key == 'S') {
        popupButtonIndex = min(3, popupButtonIndex + 1);
      }
    }
  } else if (activeScreen.equals("REGISTER_POPUP")) {
    if (typing) {
      typing();
    } else {
      if (key == BACKSPACE) {
        reset();
        activeScreen = "MENU";
      }
      if (keyCode == UP || key == 'w' || key == 'W') {
        popupButtonIndex = max(1, popupButtonIndex - 1);
      } else if (keyCode == DOWN || key == 's' || key == 'S') {
        popupButtonIndex = min(4, popupButtonIndex + 1);
      }
    }
  } else if (activeScreen.equals("LOBBY")) {
    if (keyCode == UP || key == 'w' || key == 'W') {
      menuButtonIndex = max(1, menuButtonIndex - 1);
    } else if (keyCode == DOWN || key == 's' || key == 'S') {
      menuButtonIndex = min(4, menuButtonIndex + 1);
    }
  } else if (activeScreen.equals("TUTORIAL_POPUP")) {
    if (key == BACKSPACE) {
      activeScreen = "LOBBY";
    }
  } else if (activeScreen.equals("ERROR_POPUP")) {
    if (key == BACKSPACE) {
      activeScreen = prevMenu;
    }
  } else if (activeScreen.equals("GAME")) {
      if (keyCode == UP || key == 'w' || key == 'W') {
        main_boost = true;
        socket.write("32");
      }
      if (keyCode == LEFT || key == 'a' || key == 'A') {
        left_boost = true;
        socket.write("30");
      }
      if (keyCode == RIGHT || key == 'd' || key == 'D') {
        right_boost = true;
        socket.write("31");
      }
  } else if (activeScreen.equals("WIN")) {
    if (key == BACKSPACE)
      activeScreen ="LOBBY";
  }else if (activeScreen.equals("LOSE")) {
    if (key == BACKSPACE)
      activeScreen ="LOBBY";
  }else if (activeScreen.equals("TOP10")) {
    if (key == BACKSPACE)
      activeScreen = prevMenu;
  }
}

// Check if Enter or Space keys are pressed
void keyReleased() {
  if (activeScreen.equals("MENU")) {
    if (key == ENTER || key == ' ') {
      switch (menuButtonIndex) {
        case 1:
          activeScreen = "LOGIN_POPUP";
          break;
        case 2:
          activeScreen = "REGISTER_POPUP";
          break;
        case 3:
          prevMenu = "MENU";
          socket.write("50");
          println("Socket lancado: 50");
          delay(50);
          if (socket.available() > 0) {
            String data = socket.readString();
            if (data != null) {
              receivedData = data.trim();
              println("Received: " + receivedData);
            } else {
              errorText = "Unknown Error";
              activeScreen = "ERROR_POPUP";
              println("Null Socket");
            }
          }
          if (receivedData.startsWith("top10list")){
             String[] jog = receivedData.split(",");
             for (int i = 1; i < jog.length; i++) {
                jogadores[i - 1] = jog[i];
            }
          }
          activeScreen = "TOP10";
          break;
        case 4:
          exit();
          break;
      }
    }
  }else if (activeScreen.equals("LOGIN_POPUP")) {
    if (key == ENTER || key == ' ') {
      switch (popupButtonIndex) {
        case 1:
          typing = !typing;
          if (popupUsername.equals("Username")) popupUsername = "";
          println(popupUsername);
          break;
        case 2:
          typing = !typing;
          if (popupPassword.equals("Password")) popupPassword = "";
          println(popupPassword);
          break;
        case 3:
          println("Confirm pressed!");
          println("Socket lançado: 00 " + popupUsername + " " + popupPassword);
          socket.write("00 " + popupUsername + " " + popupPassword);
          delay(30);
          if (socket.available() > 0) {
            String data = socket.readString();
            if (data != null) {
              receivedData = data.trim();
              println("Received: " + receivedData);
              println("ESTOU NO LOGIN KEYSPRESSED");
            } else {
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
          if (receivedData.equals("Error 00")) {
            errorText = "This account doesn't exist";
            reset();
            activeScreen = "ERROR_POPUP";
          }
          break;
      }
    }
  } else if (activeScreen.equals("REGISTER_POPUP")) {
    if (key == ENTER || key == ' ') {
      switch (popupButtonIndex) {
        case 1:
          typing = !typing;
          if (popupUsername.equals("Username")) popupUsername = "";
          println(popupUsername);
          break;
        case 2:
          typing = !typing;
          if (popupPassword.equals("Password")) popupPassword = "";
          println(popupPassword);
          break;
        case 3:
          typing = !typing;
          if (confirmPassword.equals("Confirm Password")) confirmPassword = "";
          println(confirmPassword);
          break;
        case 4:
          println("Confirm pressed!");
          if (popupUsername.equals("Username")) {
            errorText = "\"Username\" is an invalid username";
            activeScreen = "ERROR_POPUP";
            println("Couldn't create account");
            loggedIn = false;
            reset();
          } else if(!popupPassword.equals(confirmPassword)){
            errorText = "\"Password\" and \"Confirm Password\" are different."; 
            activeScreen = "ERROR_POPUP";
            println("Couldn´t create account, different passwords");
            loggedIn = false;
            reset();
          } else{
            println("Socket lançado: 02 " + popupUsername + " " + popupPassword);
            socket.write("02 " + popupUsername + " " + popupPassword);
            delay(30);
            if (socket.available() > 0) {
              String data = socket.readString();
              if (data != null) {
                receivedData = data.trim();
                println("Received: " + receivedData);
                println("ESTOU NO REGISTERPOPUP KEYS");
              } else {
                errorText = "Unknown_error";
                activeScreen = "ERROR_POPUP";
                println("Null Socket");
              }
            }
            println(receivedData);
            if (receivedData.equals("created_Account")) {
              curr_level = 1;
              loggedIn = true;
              println("DEI REGISTER");
              activeScreen = "LOBBY";
            }
            if (receivedData.equals("Error 01")) {
              errorText = "This account already exists";
              reset();
              activeScreen = "ERROR_POPUP";
              println("Couldn't create account");
              loggedIn = false;
            }
            break;
          }
      }
    }
  }else if (activeScreen.equals("LOBBY")) {
    if (key == ENTER || key == ' ') {
      switch (menuButtonIndex) {
        case 1:
          println("Socket lançado: 10 " + popupUsername);
          socket.write("10 " + popupUsername);
          activeScreen = "LOADING";
          break;
        case 2:
          activeScreen = "TUTORIAL_POPUP";
          break;
        case 3:
          prevMenu = "LOBBY";
          socket.write("50");
          println("Socket lancado: 50");
          if (socket.available() > 0) {
            String data = socket.readString();
            if (data != null) {
              receivedData = data.trim();
              println("Received: " + receivedData);
            } else {
              errorText = "Unknown Error";
              activeScreen = "ERROR_POPUP";
              println("Null Socket");
            }
          }
          if (receivedData.startsWith("top10list")){
             String[] jog = receivedData.split(",");
             for (int i = 1; i < jog.length; i++) {
                jogadores[i - 1] = jog[i];
            }
          }
          activeScreen = "TOP10";
          break;
        case 4:
          println("Socket lançado: 01 " + popupUsername);
          socket.write("01 " + popupUsername);
          delay(30);
          if (socket.available() > 0) {
            String data = socket.readString();
            if (data != null) {
              receivedData = data.trim();
              println("Received: " + receivedData);
            } else {
              errorText = "Unknown Error";
              activeScreen = "ERROR_POPUP";
              println("Null Socket");
            }
          }
          println(receivedData);
          if (receivedData.equals("logged_out")) {
            loggedIn = false;
            println("DEI LOGOUT");
            activeScreen = "MENU";
          }
          if (receivedData.equals("Error 01")) {
            activeScreen = "ERROR_POPUP";
            println("Couldn't logout");
          }

          reset();
          activeScreen = "MENU";
          break;
      }
    }
  } else if (activeScreen.equals("GAME")) {
    if (keyCode == UP || key == 'w' || key == 'W') {
      main_boost = false;
      socket.write("42");
    }
    if (keyCode == LEFT || key == 'a' || key == 'A') {
      left_boost = false;
      socket.write("40");
    }
    if (keyCode == RIGHT || key == 'd' || key == 'D') {
      right_boost = false;
      socket.write("41");
    }
  }
}
