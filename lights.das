require daslib/media

struct light_t
    pos : float3

    c_a : float
    c_d : float

    a_c : float3
    d_c : float3

def calc_color(trans_vx           : float3;
               trans_nm           : float3;
               light              : light_t) : float3
    var light_dir = normalize(light.pos - trans_vx)
 
    var l = max(dot(light_dir, trans_nm), 0.)
    
    return light.c_a * light.a_c + l * light.c_d * light.d_c