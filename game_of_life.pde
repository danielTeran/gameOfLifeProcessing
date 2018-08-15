
/**
* Settings del programa
*/
//Tamaño de las celdas en pixeles
int celulaSize = 8;

//Intervalo de actualización
int intervalo = 100;
int auxTiempo = 0;

//Bandera de pausa
boolean pausa = false;

//Tipo de reglas
int regla = 0;
/*****************************/


/**
* Settings del automata celular
*/
//Los arreglos que almacenaran las celulas y buffers para checar estructuras
int[][] celulas; 
int[][] celBuffer;
int[][] celBuffer2;

//Colores de las celulas
color viva = color(0, 200, 0);
color muerta = color(0);
color estatica = color(0, 0, 250); //color azul para las estructuras estaticas
color oscilador = color(200, 0, 0); //color rojo para las estructuras periodicas

//Probabilidad de inicialización de la celula de iniciar viva al inicio del programa
float probDeVida = 22;//muy pesimista
/*****************************/


/**
* Funciones
*/

void randomCells(){
  //Se inicializan el estado de las celulas
  for (int x=0; x<width/celulaSize; x++) {
    for (int y=0; y<height/celulaSize; y++) {
      float rand = random (100);
      if (rand > probDeVida) rand = 0;
      else rand = 1;
      celulas[x][y] = int(rand);
    }
  }
}

/**
* Inicializa los valores del automata
* y fija los atributos de la ventana
*/
void setup() {
  size (900, 600); //Tamaño de la reticula
  //Se inicializa los estados del automata y los buffers
  celulas = new int[width/celulaSize][height/celulaSize];
  celBuffer = new int[width/celulaSize][height/celulaSize];
  celBuffer2 = new int[width/celulaSize][height/celulaSize];
  //Inicializamos el valor al azar del automata
  randomCells();
  
  stroke(80); //Marcamos el contorno de las celdas
  background(0); //El fondo va de negro
}

/**
* @override
* Metodo que pinta el automata celular en la ventana
*/
void draw() {
  for (int x=0; x<width/celulaSize; x++) {
    for (int y=0; y<height/celulaSize; y++) {
      if (celulas[x][y]==1) fill(viva); //Se colorea verde si está viva
      else fill(muerta); // Se colorea negro si esta muerta la celula
      rect (x*celulaSize, y*celulaSize, celulaSize, celulaSize);
    }
  }
  //El intervalo en que se actualiza la imagen 
  if (millis()-auxTiempo>intervalo) {
    if (!pausa) {
      iteration();
      auxTiempo = millis();
    }
  }
  updateMouseCells();
}

/**
* Actualiza el estado del automata celular por cada iteracion del programa
*/
void iteration() {
  for (int x=0; x<width/celulaSize; x++) {
    for (int y=0; y<height/celulaSize; y++) {
      //guardamos dos estados anteriores para detectar
      //estructuras estaticas u osciladores 
      celBuffer2[x][y] = celBuffer[x][y]; 
      celBuffer[x][y] = celulas[x][y];
    }
  }
  updateWithRules(); 
}

/**
* Actualiza el estado del automata de acuerdo al tamaño de la vecindad y reglas dadas
**/
void updateWithRules(){
  for (int x=0; x<width/celulaSize; x++) {
    for (int y=0; y<height/celulaSize; y++) {
      int neighbours = 0;
      for (int xx=x-1; xx<=x+1; xx++) {
        for (int yy=y-1; yy<=y+1; yy++) {  
          if (((xx>=0)&&(xx<width/celulaSize))&&((yy>=0)&&(yy<height/celulaSize))) { // Make sure you are not out of bounds
            if (!((xx==x)&&(yy==y))) { 
              if (celBuffer[xx][yy]==1) neighbours ++;
            }
          }
        }
      }
      rules(x,y,neighbours);
    }
  }
}

/**
* Define las reglas con las que se comportara nuestro automata
*/
void rules(int x, int y, int neighbours) {
  switch(regla){
    case 0:
      if (celBuffer[x][y]==1) { //matamos a la celula
        if (neighbours<2 || neighbours>3) celulas[x][y] = 0; 
      } 
      else { //creamos una celula    
        if (neighbours==3) celulas[x][y] = 1;
      }
    break;
  }
}

/*****************************/


/**
* Acciones
*/

/**
* Crea nuevas celulas con el cursor si esta en pausa el automata
*/
void updateMouseCells() {
  if (pausa && mousePressed) {
    int xCellOver = int(map(mouseX, 0, width, 0, width/celulaSize));
    xCellOver = constrain(xCellOver, 0, width/celulaSize-1);
    int yCellOver = int(map(mouseY, 0, height, 0, height/celulaSize));
    yCellOver = constrain(yCellOver, 0, height/celulaSize-1);

    //Se invierte el estado de una celula
    if (celBuffer[xCellOver][yCellOver]==1) { 
      celulas[xCellOver][yCellOver]=0; 
      fill(muerta);
    } 
    else { 
      celulas[xCellOver][yCellOver]=1;
      fill(viva);
    }
  } 
}

/**
* @override
* Ejecuta las acciones de presionar los siguientes botones:
* - R o r: reinicia aleatoreamente el valor del automata
* - ' '(space tab): pausa la ejecución del automata
* - B o b: borra los valores de la reticula
*/
void keyPressed() {
  if (key=='r' || key == 'R') randomCells();
  if (key==' ') pausa = !pausa;
  if (key=='b' || key == 'B') {
    for (int x=0; x<width/celulaSize; x++) {
      for (int y=0; y<height/celulaSize; y++) {
        celulas[x][y] = 0;
      }
    }
  }
  if (key == 'p' || key == 'P') {
    celulaSize ++; //corregir la cota superior
  }
  if (key == 'm' || key == 'M') {
    celulaSize --; //corregir la cota inferior, checar antes de ejecutar
  }
}
