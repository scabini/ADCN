function runADCN(path)
	javaaddpath('weka.jar');
	n=10;
	[li, lf] = automaticThresholds(path, '', 1.4, '');

	arq1 = dir([path, '*.jpg']); 
	arq2 = dir([path, '*.png']);
	arq3 = dir([path, '*.bmp']); 
	arq = [arq1; arq2; arq3];
	featureMatrix =[];
	classes = {};
	for i=1 : length(arq) 
		path2= strcat(path, arq(i).name);
                img=imread(path2);               
                img = im2uint8(img);

		[classe, ~] = strtok(arq(i).name, '_');                
                classes{i} = classe;

		[ featureVector ] = getFeatures( img, li, lf, n)
		featureMatrix = [featureMatrix;featureVector];

		 
	end

	caminho = 'ADCN.arff';
        createArff(caminho, featureMatrix, classes);

end

