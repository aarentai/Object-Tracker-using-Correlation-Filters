%data_path should include 'img'(including all the frames in a certain sequence) and roundtruth_rect.txt
data_path = '.\Tiger2';

%sequence_path, namely 'img', should include all the frames of a certain sequence
[gt,sequence_path,img_files]=Load_image(data_path);

%read the first frame
img = imread([sequence_path img_files{1}]);

%assign the first frame's ground truth
ground_truth = [32 60 68 78];
endFrame=length(img_files);

%turn rgb to gray
if (size(img,3) == 1)
	frame = img;
else
	frame = rgb2gray(img);
end

%target_sz = [w h], which denote the width and height, respectively.
target_sz = [ground_truth(1,4), ground_truth(1,3)];

%target_pos = [y x], which denote the position of target's central point, respectively.
target_pos = [ground_truth(1,2), ground_truth(1,1)] + floor(target_sz/2);

%ideal gaussian template
gauss_response = gaussian_template(target_sz, frame);

for n = 1 : endFrame%length(sequence_path)
	%read the n th frame into 'frame'
	img = imread([sequence_path img_files{n}]);
    %turn rgb to gray
    if (size(img,3) == 1)
		frame = img;
	else
		frame = rgb2gray(img);
    end
    
	%get the subwindow at the target position of last frame
	target_last_frame = get_subwindow(target_pos, target_sz, frame);
    
	if n > 1
		%calculate response of the classifier at all locations
		response = real(ifft2(H .* fft2(target_last_frame)));   
		
		%target location is at the maximum response
		[row, col] = find(response == max(response(:)), 1);
		target_pos = target_pos - target_sz/2 + [row, col];
	end
	
	F = fft2(get_subwindow(target_pos, target_sz, frame));
	H = conj(F.*conj(gauss_response)./(F.*conj(F)+eps));
	
    %visualization
	box = [target_pos([2,1]) - target_sz([2,1])/2, target_sz([2,1])];

	% visiualization   
    if n == 1  %first frame, create GUI
            figure
            im_handle = imagesc(uint8(img));%img
            rect_handle = rectangle('Position',box,'LineWidth',2,'EdgeColor','r');
            tex_handle = text(5, 18, strcat('#',num2str(n)), 'Color','y', 'FontWeight','bold', 'FontSize',20);
            drawnow;
    else
        try  %subsequent frames, update GUI
			set(im_handle, 'CData', img)%img
			set(rect_handle, 'Position', box)
            set(tex_handle, 'string', strcat('#',num2str(n)))
            pause(0.04);
            drawnow;
		catch  % #ok, user has closed the window
			return
        end
    end
end
