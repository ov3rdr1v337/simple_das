struct intersection_data_t
    vx : float2
    t  : float

def seg_seg_intersection(p_0 : float2; p_1 : float2;
                         p_2 : float2; p_3 : float2) : intersection_data_t
    var s_1 = float2()
    var s_2 = float2()

    s_1.x = p_1.x - p_0.x
    s_2.x = p_3.x - p_2.x

    s_1.y = p_1.y - p_0.y
    s_2.y = p_3.y - p_2.y

    var intersection_data : intersection_data_t

    intersection_data.t  = (s_2.x * (p_0.y - p_2.y) - s_2.y * (p_0.x - p_2.x)) / (-s_2.x * s_1.y + s_1.x * s_2.y)
    intersection_data.vx = float2(p_0.x + intersection_data.t * s_1.x, 
                                  p_0.y + intersection_data.t * s_1.y)

    return intersection_data