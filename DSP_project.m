deepnet = googlenet;
img = imread("C:\Users\USER\Desktop\images_original\blues\blues00000.png");
%pred = classify(deepnet,img);
sz = size(img);
inlayer = deepnet.Layers(1);
insz = inlayer.InputSize;
img = imresize(img ,[224,224]);
imshow(img);
%Resizing imgages and and displaying them
%%
location = 'C:\Users\USER\Desktop\images_original\blues\*.png';
ds = imageDatastore(location);
for i = 1 : 5                     % specify number of images to display
    img = read(ds) ;             % read image from datastore
    figure, imshow(img);    % creates a new window for each image
end
%Test 
%%
net =  googlenet;
location = 'C:\Users\Filip\Desktop\images_original\blues\*.png';
imds = imageDatastore(location);
auds = augmentedImageDatastore([224 224],imds);
preds = classify(net,auds)
%images classified with respect googlenet deep learning network

%%
location = 'C:\Users\Filip\Desktop\images_original';
imds = imageDatastore(location,"IncludeSubfolders",true,"FileExtensions",".png","LabelSource","foldernames");
perm = randperm(10000,20);
% for i = 1:5
%     img = read(imds);             
%     figure, imshow(img);
% end
labelCount = countEachLabel(imds)
img = readimage(imds,1);
size(img)
numTrainFiles = 75;
[imdsTrain,imdsValidation] = splitEachLabel(imds,numTrainFiles,'randomize');

layers = [
    imageInputLayer([288 432 3])
    
    convolution2dLayer(3,8,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,16,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(10)
    softmaxLayer
    classificationLayer];
options = trainingOptions('sgdm', ...
    'InitialLearnRate',0.01, ...
    'MaxEpochs',8, ...
    'Shuffle','every-epoch', ...
    'ValidationData',imdsValidation, ...
    'ValidationFrequency',30, ...
    'Verbose',false, ...
    'Plots','training-progress');
net = trainNetwork(imdsTrain,layers,options);
YPred = classify(net,imdsValidation);
YValidation = imdsValidation.Labels;

accuracy = sum(YPred == YValidation)/numel(YValidation)
