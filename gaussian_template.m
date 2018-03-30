function G = gaussian_template(target_sz, first_frame)
    [rs, cs] = ndgrid((1:target_sz(1)) - floor(target_sz(1)/2), (1:target_sz(2)) - floor(target_sz(2)/2));
    dist = rs.^2 + cs.^2;
    conf = exp(-0.5 / (2.25) * sqrt(dist));%���ɶ�ά��˹�ֲ�
    conf = conf/sum(sum(conf));% normalization
    if(size(first_frame,3)==1)%�Ҷ�ͼ��
        response=conf;
    else
        response(:,:,1)=conf;response(:,:,2)=conf;response(:,:,3)=conf;    
    end       
%         figure
%         imshow(256.*response);
%         mesh(response);
        G = fft2(response);%����Ҷ�任
end