//C++ angular complex network core code. Takes an image (2d matrix) where
//  values 0 indicates background and values 255 boundary pixels. The
//  second parameter is a vector, i.e. the thresholdset |[li,...,lf]|=n.

//Returns: an n-by-181 matrix which contains the angular histogram for each
//  one of the n thresholds in thresholdset. The histograms ranges from
//  [0, ..., 180].

#include "mex.h"
#include <math.h>
#include <vector>
#include<queue>
#include<iostream>

#define borda 240
#define limite 15000
using std::vector;
using namespace std;
//int **kin = NULL;

class Point{
public:
	int x, y;
	double weigth;
	int degree;
	//Point(int x, int y, double weigth, int degree);
};

//Point::Point(int x, int y, double weigth, int degree) : x(x), y(x), weigth(weigth), degree(degree) {}

bool operator<(Point a, Point b){ return a.weigth < b.weigth ? true : false; }

double adjMat[limite][limite];

vector<priority_queue<Point> > adj(limite);

Point bordas[limite];

double maior = 0;
//int index = 0;
int getGraph(double** im, int w, int h, double maxRadius);
double angleBetween(const Point pf, const Point p1, const Point p2);

void mexFunction(
	int nlhs,
	mxArray *plhs[],
	int nrhs,
	const mxArray *prhs[]
	)
{
	int w, h, n;
	double *pr = NULL, **im = NULL;
	double *radiuset;
	/* check number of parameters */
	if (nrhs != 2) {
		mexErrMsgTxt("Input arguments: Edge-Image and radiuset");
	}
	else if (nlhs != 1) {
		mexErrMsgTxt("Returns an angle-histogram for each threshold in the input thresholdset");
	}
	h = mxGetM(prhs[0]);    /* nro linhas da imagem */
	w = mxGetN(prhs[0]);    /* nro colunas da imagem */
	//printf("%d x %d\n", w, h);
	pr = mxGetPr(prhs[0]);
	n = mxGetN(prhs[1]);
	radiuset = mxGetPr(prhs[1]);

	im = (double **)malloc(w * sizeof(double *));
	for (int i = 0; i < w; i++){
		im[i] = pr + i*h;
	}
    int index;
    
	index = getGraph(im, w, h, radiuset[n - 1]);


	plhs[0] = mxCreateDoubleMatrix(n, 181, mxREAL);

	double *angulo = mxGetPr(plhs[0]);

	for (int row = 0; row < n; row++) {
		for (int col = 0; col < 181; col++) {
			angulo[n * col + row] = 0;
		}
	}

		
	for (int i = 0; i < index; i++){
		Point base = bordas[i];
		priority_queue<Point> original = adj[i];
		if (adj[i].size()>1){
			Point primeira= adj[i].top();
            
            int co=adj[i].size();
            int dois=co;
			while(!adj[i].empty()){
					Point ponto1 = adj[i].top();
					adj[i].pop();
                    co--;
                    Point ponto2;
                    
                    if(co==0){
                        if(dois!= 2){
                            ponto2 = primeira;
                        }else{
                            break;
                            }
                    }else{
                        ponto2 = adj[i].top();
                     }						
					//printf("%d\n", ponto1.degree);					
					for (int r = 0; r < n; r++){
						if (ponto1.weigth <= radiuset[r] && ponto2.weigth <= radiuset[r]){
                            int ang = min((int)angleBetween(base, ponto1, ponto2), 360 - (int)angleBetween(base, ponto1, ponto2));
							//if (ang == 0){
							//	angulo[n * 180 + r]++;
							//}
							//else{
								angulo[n*(ang) + r]++;
							//}
						}
					}
						
			}
		}
		
	}

	free(im);
	//*angulo = NULL;
	//free(angulo);
}

int getGraph(double** im, int w, int h, double maxRadius) {
	int index = 0;
	maior = 0;
	int degree[9999];

	//adicionando somente os pixels de borda em uma fila
	for (int x = 0; x < w; x++) {
		for (int y = 0; y < h; y++) {
			if (im[x][y] >= borda){
				//printf("%.0f ", im[x][y]);
				Point pixel;
				pixel.x = x;
				pixel.y = y;
				bordas[index] = pixel;
				degree[index] = 0;
				index++;
			}
			else{
				//printf(" %.0f  ", im[x][y]);
			}
		}
		//printf("\n");
	}
	for (int i = 0; i < index; i++){
		for (int j = 0; j < index; j++){

			priority_queue<Point> a;
			adj[i] = a;
			//printf("edge created\n");
			double d = sqrt(((bordas[i].x - bordas[j].x)*(bordas[i].x - bordas[j].x)) + ((bordas[i].y - bordas[j].y)*(bordas[i].y - bordas[j].y)));
			
			adjMat[i][j] = d;
			adjMat[j][i] = d;
			if (d > maior){
				maior = d;
			}
		}
	}

	for (int i = 0; i < index; i++){
		for (int j = 0; j < index; j++){
			adjMat[i][j] = adjMat[i][j] / maior;
			if (adjMat[i][j] <= maxRadius && adjMat[i][j] != 0 && i != j){			
				
				Point edge;
				edge.x = bordas[i].x;
				edge.y = bordas[i].y;
				edge.weigth = adjMat[i][j];
				edge.degree = degree[i];
				//fprintf(arq, "%d %d\n", i, j);
				//printf("%d %d\n", i, j);
				adj[j].push(edge);
			}
		}
	}
    return index;
}

double angleBetween(const Point pf, const Point p1, const Point p2){

	double angle1 = atan2(pf.y - p1.y, pf.x - p1.x);
	double angle2 = atan2(pf.y - p2.y, pf.x - p2.x);
	double angle = (angle2 - angle1) * 180 / 3.14159;
	if (angle<0) {
		angle += 360;
	}
	
	return round(angle);
}
