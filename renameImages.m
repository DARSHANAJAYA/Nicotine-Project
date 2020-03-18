f_renameImages('D:\rtfMRI\Code_rtfMRI\pretest images', 'D:\rtfMRI\Code_rtfMRI\pretest_images', 174); 

function f_renameImages(sourceImageDirectory, destinationImageDirectory, images2copy)

cd(sourceImageDirectory); 

files = dir('*.jpg'); fnames = {files.name};

for n=1:images2copy
    copyfile(fnames{n}, [destinationImageDirectory, filesep, num2str(n) '.jpg']); 
end 
end

