addpoly <- function(x, y,y0=NULL, border = 'black',col = grey(0.5, 0.5)){
	y0 <- rev(y0)
	if (is.null(y0)){y0 <- rep(0, length(y)) }
	
	polygon(c(x, rev(x)), c(y, y0), col = col, border = border)
	}