function [colvec colsize rowvec rowsize] = subplotinds(ncols,nitems)
border=0.03;

nrows=ceil(nitems/ncols);
colsize=(1-(border*(ncols+1)))/ncols;  
colind=[(border):(colsize+border):1-(colsize+border)];
colvec=reshape(repmat(colind,nrows,1),1,(nrows*ncols));
colvec=reshape(colvec,nrows,ncols);
rowsize=(1-(border*(nrows+1)))/nrows;
rowind=[(border):(rowsize+border):1-(rowsize+border)];
rowvec=repmat(rowind,1,ncols);
rowvec=flipud(reshape(rowvec,nrows,ncols));