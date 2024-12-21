#version 330 core

in vec2 TexCoordStatic; 
out vec4 FragColorStatic; 

uniform sampler2D textureStatic; 

void main()
{
    FragColorStatic = texture(textureStatic, TexCoordStatic); 
}