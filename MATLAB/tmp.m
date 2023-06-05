%% Just a file used to run some tests when needed

for id=1:16
    load("svm_models\svm" + string(id) + ".mat")
    disp("Patient " + string(id) + ", costs = ")
    disp(trainedModel.ClassificationSVM.Cost)
end