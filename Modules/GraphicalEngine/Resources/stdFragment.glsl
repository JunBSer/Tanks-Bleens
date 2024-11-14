#version 330 core
out vec4 FragColor;

in vec3 FragPos; 
in vec3 Normal;   
in vec2 TexCoords; 

uniform sampler2D texture1;  
uniform vec3 lightDir; 
uniform vec3 viewPos;  
uniform vec3 lightColor;  

void main() {
    
    vec4 texColor = texture(texture1, TexCoords);
    vec3 objectColor = texColor.rgb;  

 
    vec3 norm = (Normal);  


    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * lightColor;

   
    vec3 viewDir = normalize(viewPos - FragPos);
    vec3 reflectDir = reflect(-lightDir, norm);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32);      vec3 specular = spec * lightColor;

   
    vec3 ambient = 0.5 * lightColor;  
   
    vec3 finalColor = (ambient + diffuse + specular) * objectColor;
    FragColor = vec4(finalColor, 1.0);  
}
