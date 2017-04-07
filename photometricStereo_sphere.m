% % Load sphere images
img1 = imread('/sphere-images/real1.bmp');
img1_scaled = double(img1) ./ 255.0;
img2 = imread('/sphere-images/real2.bmp');
img2_scaled = double(img2) ./ 255.0;
img3 = imread('/sphere-images/real3.bmp');
img3_scaled = double(img3) ./ 255.0;
img4 = imread('/sphere-images/real4.bmp');
img4_scaled = double(img4) ./ 255.0;

% View Matrix from sphere-images
v1 = [0.38359, 0.236647, 0.89266];
v2 = [0.372825, -0.303914, 0.87672];
v3 = [-0.250814, -0.34752, 0.903505];
v4 = [-0.203844, 0.096308, 0.974255];
V = [v1; v2; v3; v4];

w = 460;
h = 460;

albedo = zeros(h, w);
normal_x = zeros(h, w);
normal_y = zeros(h, w);
normal_z = zeros(h, w);

height_map = zeros(h, w);

for i = 1:1:w
    for j = 1:1:h
        i_matrix = [img1_scaled(i, j), img2_scaled(i, j), img3_scaled(i, j), img4_scaled(i, j)];
        Ti = transpose(i_matrix .^ 2);
        T = zeros(4, 4);
        for k = 1:1:4
            T(k, k) = i_matrix(k);
        end
        % Here might be a problem to calculate g(x, y)
        g = (T * V) \ Ti;
        albedo(i, j) = norm(g);
        % calculate the albedo and normal
        normal = g ./ albedo(i, j);
        % Store the normals, 3 components
        normal_x(i, j) = normal(1);
        normal_y(i, j) = normal(2);
        normal_z(i, j) = normal(3);
        % calculate p and q
        p = - normal(1) / normal(3);
        q = - normal(2) / normal(3);
        % integrate the height map
        if i - 1 >= 1
            height_map(i, j) = height_map(i - 1, j) + q;
        else
            height_map(i, j) = q;
        end
        if j - 1>= 1
            height_map(i, j) = height_map(i, j - 1) + p;
        else
            height_map(i, j) = p;
        end
    end
end

height_map_greyscaled = (height_map(:) - min(height_map(:)))/ (max(height_map(:)) - min(height_map(:)));
height_map_greyscaled = reshape(height_map_greyscaled, w, h);

% show the three components of surface normal vector
figure(1), title('surface normal vector');
subplot(1, 3, 1), title('normal X');
imshow(normal_x);
subplot(1, 3, 2), title('normal Y');
imshow(normal_y);
subplot(1, 3, 3), title('normal Z');
imshow(normal_z);

% Show the albedo map
figure(2), title('albedo map');
imshow(albedo);

% Show the needle map(2D vectors on the 100 * 100 grif)
figure(3), title('2D Vector Map');
[x1, y1] = meshgrid(1:1:w, 1:1:h);
quiver(x1, y1, normal_x, normal_y);
axis tight;
axis square;

% Show the mesh grid map
figure(4), title('Mesh Grid Map');
[x2, y2] = meshgrid(1:1:w, 1:1:h);
mesh(x2, y2, height_map);

% Show the height map
figure(5), title('Surf Height Map');
[x3, y3] = meshgrid(1:1:w, 1:1:h);
surf(x3, y3, height_map, 'EdgeColor', 'none');

% Show the greyscaled height map
figure(6), title('Greyscaled Height Map');
imshow(height_map_greyscaled);

% % Show the quiver3
% figure(7);
% [x4, y4] = meshgrid(1:1:w, 1:1:h);
% z4 = height_map(x4, y4);
% [u, v, w] = surfnorm(z4);
% quiver3(z4, u, v, w);