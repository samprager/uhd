function varargout = udar_mimo_phase_offset(phase_err_mtx)
nsensors = size(phase_err_mtx,1);
phase_err_mat = phase_err_mtx;
nrows = nsensors*(nsensors-1);
ncols = nsensors*2;
A = zeros(nrows,ncols);
% b = zeros(nrows,1);

b = [];
for i=1:nsensors
    for j=1:nsensors
        if (i~=j)
          b = [b;(phase_err_mat(i,j))];
        end
    end
end

for i=1:nsensors
  for j=1:(nsensors-1)
      A(j+(i-1)*(nsensors-1),i)=1;
      if (j>=i)
          A(j+(i-1)*(nsensors-1),nsensors+j+1)=1;
      elseif (j<i)
        A(j+(i-1)*(nsensors-1),nsensors+j)=1;
      end
  end
end

have_local = false;

for i=1:nsensors
    if (phase_err_mat(i,i)~=0)
        have_local = true;
        break;
    end
end

if (have_local)
    A = [A;zeros(nsensors,size(A,2))];
    b = [b;diag(phase_err_mat)];
    for i=(nrows+1):size(A,1)
      A(i,i-nrows) = 1;
      A(i,i-nrows+nsensors) = 1.0;
    end
    nrows=nrows+nsensors;
end

A = [A;[1 zeros(1,size(A,2)-1)]];
b = [b;0];

x = inv(A'*A)*A'*b;

err_x = A*x-b;

if (nargout>0)
    varargout{1} = x;
end
if (nargout>1)
    varargout{2} = err_x;
end
if (nargout>2)
    varargout{3} = A;
end
if (nargout>3)
    varargout{4} = b;
end

% result_emb = [0,58.6018,12.3734,-151.999,130.344,-160.45]*(pi/180)