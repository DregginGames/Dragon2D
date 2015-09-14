/**
	d2d.core.render.util provides utulity functions for 2D and 3D rendering
*/
module d2d.core.render.util;

import gl3n.linalg;

/** 
	Creates a Ortographic projection matrix 
	Defaults near plane to be 0 units away and far plane to be 100 units away 
*/
mat4 genOrtographicProjection(float width, float height, float near = 0.0, float far = 100.0)
{
	return mat4(
		[ 1.0f/width, 0.0f, 0.0f],
		[ 0.0f, 1.0f/height, 0.0f, 0.0f],
		[ 0.0f, 0.0f, -(2.0f/(far-near)), -((far+near)/(far-near))],
		[ 0.0f, 0.0f, 0.0f, 1.0f]);
}

/**
	Creates a worldToView (or just view) matrix based on a given positin in 2D space
*/
mat4 gen2DWorldToView(vec2 viewPosition, float viewBackoffset = 1.0f)
{
	return mat4.identity
		.translate(-viewPosition.x,-viewPosition.y, 0);
}

/**
	Creates a modelToWorld (or just model) matrix based on a given position in 2D space and rotation (around z) and scale (same for x- and y, for more complex compose matrix yourself).
*/
mat4 gen2DModelToWorld(vec2 modelPos, float alpha = 0.0f, float scale = 1.0f)
{
	return mat4.identity
		.translate(modelPos.x, modelPos.y, 0.0)
		.rotatez(alpha)
		.scale(scale,scale, 1.0f);
}
