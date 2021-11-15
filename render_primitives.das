require lights
require daslib/media
require math_utils

var screen     : Image

let rad_arr = [[float[] +0.000000; +0.500000; +0.866025; +1.000000; +0.866025; +0.500000; +0.000000]]
let hgt_arr = [[float[] +1.000000; +0.866025; +0.500000; +0.000000; -0.500000; -0.866025; -1.000000]]

let cos_arr = [[float[] +1.000000; +0.866025; +0.500000; +0.000000; -0.500000; -0.866025; -1.000000;
                        -0.866025; -0.500000; +0.000000; +0.500000; +0.866025; +1.000000]]
 
let sin_arr = [[float[] +0.000000; +0.500000; +0.866025; +1.000000; +0.866025; +0.500000; +0.000000;
                        -0.500000; -0.866025; -1.000000; -0.866025; -0.500000; +0.000000]]
 
let nxt_arr = [[uint[] 1u; 2u; 3u; 4u ; 5u ; 6u;
                       7u; 8u; 9u; 10u; 11u; 0u ]]
 
let prv_arr = [[uint[] 11u; 0u; 1u; 2u; 3u; 4u ;
                       5u ; 6u; 7u; 8u; 9u; 10u ]]

let rvx_arr = [[float3[] float3(+1., +0., +0.); float3(+0., +0., +1.);
                         float3(-1., +0., +0.); float3(+0., +0., -1.)]]

let rnu_arr = [[float3[] float3(+0.57735, +0.57735, +0.57735); float3(-0.57735, +0.57735, +0.57735);
                         float3(-0.57735, +0.57735, -0.57735); float3(+0.57735, +0.57735, -0.57735)]]

let rnd_arr = [[float3[] float3(+0.57735, -0.57735, +0.57735); float3(-0.57735, -0.57735, +0.57735);
                         float3(-0.57735, -0.57735, -0.57735); float3(+0.57735, -0.57735, -0.57735)]]

let nxt4_arr = [[uint[] 1u; 2u; 3u; 0u]]
 
let prv4_arr = [[uint[] 3u; 0u; 1u; 2u]]

def draw_romb_l(radius             : float;
                color              : float3;
                segment            : uint ;
                lights             : array<light_t>;
                romb_transform     : float3x4;
                camera_transform   : float3x4;
                camera_perspective : float3x4)

    var current = segment

    invoke() <| $()
        var vx_array: array<float2>
        var tc_array: array<float2>
        var cl_array: array<uint>

        let i_1 = current
        let i_2 = nxt4_arr[current]

        let v_1 = rotate(romb_transform, rvx_arr[i_1] * radius)
        let v_2 = rotate(romb_transform, rvx_arr[i_2] * radius)

        let v_3 = float3(0., 0., 0.)
        let v_4 = float3(0., 0., 32.)

        let i_d = seg_seg_intersection(v_1.xz, v_2.xz, v_3.xz, v_4.xz)

        var trans_vx_c_1 = romb_transform * (rvx_arr[i_1] * radius)

        let trans_nm     = rotate(romb_transform, rnu_arr[i_1])

        tc_array |> push(float2(0., 0.))
        tc_array |> push(float2(0., 0.))
        tc_array |> push(float2(0., 0.))

        var trans_vx_1 = romb_transform * (float3(0., 1., 0.)         * radius)
        var trans_vx_2 = float3(i_d.vx.x, 0.    , i_d.vx.y) + romb_transform[3]
        var trans_vx_3 = romb_transform * (rvx_arr[i_2] * radius)

        var color_1 = color
        var color_2 = color
        var color_3 = color

        for light in lights
            color_1 += calc_color(trans_vx_1  , trans_nm, light)
            color_2 += calc_color(trans_vx_c_1, trans_nm, light)
            color_3 += calc_color(trans_vx_3  , trans_nm, light)

        cl_array |> push(make_color(color_1))
        cl_array |> push(make_color(color_2 + (color_3 - color_2) * i_d.t))
        cl_array |> push(make_color(color_3))

        trans_vx_1 = camera_transform * trans_vx_1
        trans_vx_2 = camera_transform * trans_vx_2
        trans_vx_3 = camera_transform * trans_vx_3

        vx_array |> push(((camera_perspective * trans_vx_1).xy) / trans_vx_1.z + float2(620., 320.))
        vx_array |> push(((camera_perspective * trans_vx_2).xy) / trans_vx_2.z + float2(620., 320.))
        vx_array |> push(((camera_perspective * trans_vx_3).xy) / trans_vx_3.z + float2(620., 320.))

        screen |> draw_triangle_strip(vx_array, tc_array, cl_array)

        current = nxt4_arr[current]

    for i in range(1)
        var vx_array: array<float2>
        var tc_array: array<float2>
        var cl_array: array<uint>
        
        var trans_vx_1 = romb_transform * (float3(0., 1., 0.)         * radius)
        var trans_vx_2 = romb_transform * (rvx_arr[current]           * radius)
        var trans_vx_3 = romb_transform * (rvx_arr[nxt4_arr[current]] * radius)

        let trans_nm   = rotate(romb_transform, rnu_arr[current])

        tc_array |> push(float2(0., 0.))
        tc_array |> push(float2(0., 0.))
        tc_array |> push(float2(0., 0.))

        var color_1 = color
        var color_2 = color
        var color_3 = color

        for light in lights
            color_1 += calc_color(trans_vx_1, trans_nm, light)
            color_2 += calc_color(trans_vx_2, trans_nm, light)
            color_3 += calc_color(trans_vx_3, trans_nm, light)

        cl_array |> push(make_color(color_1))
        cl_array |> push(make_color(color_2))
        cl_array |> push(make_color(color_3))

        trans_vx_1 = camera_transform * trans_vx_1
        trans_vx_2 = camera_transform * trans_vx_2
        trans_vx_3 = camera_transform * trans_vx_3

        vx_array |> push(((camera_perspective * trans_vx_1).xy) / trans_vx_1.z + float2(620., 320.))
        vx_array |> push(((camera_perspective * trans_vx_2).xy) / trans_vx_2.z + float2(620., 320.))
        vx_array |> push(((camera_perspective * trans_vx_3).xy) / trans_vx_3.z + float2(620., 320.))

        screen |> draw_triangle_strip(vx_array, tc_array, cl_array)

        current = nxt4_arr[current]

    invoke() <| $()
        var vx_array: array<float2>
        var tc_array: array<float2>
        var cl_array: array<uint>

        let i_1 = current
        let i_2 = nxt4_arr[current]

        let v_1 = rotate(romb_transform, rvx_arr[i_1] * radius)
        let v_2 = rotate(romb_transform, rvx_arr[i_2] * radius)

        let v_3 = float3(0., 0., 0.)
        let v_4 = float3(0., 0., -32.)

        let i_d = seg_seg_intersection(v_1.xz, v_2.xz, v_3.xz, v_4.xz)

        var trans_vx_c_1 = romb_transform * (rvx_arr[i_2] * radius)

        let trans_nm     = rotate(romb_transform, rnu_arr[i_1])

        tc_array |> push(float2(0., 0.))
        tc_array |> push(float2(0., 0.))
        tc_array |> push(float2(0., 0.))

        var trans_vx_1 = romb_transform * (float3(0., +1., 0.)        * radius)
        var trans_vx_2 = float3(i_d.vx.x, 0.    , i_d.vx.y) + romb_transform[3]
        var trans_vx_3 = romb_transform * (rvx_arr[i_1] * radius)

        var color_1 = color
        var color_2 = color
        var color_3 = color

        for light in lights
            color_1 += calc_color(trans_vx_1  , trans_nm, light)
            color_2 += calc_color(trans_vx_c_1, trans_nm, light)
            color_3 += calc_color(trans_vx_3  , trans_nm, light)

        cl_array |> push(make_color(color_1))
        cl_array |> push(make_color(color_2 + (color_3 - color_2) * i_d.t))
        cl_array |> push(make_color(color_3))

        trans_vx_1 = camera_transform * trans_vx_1
        trans_vx_2 = camera_transform * trans_vx_2
        trans_vx_3 = camera_transform * trans_vx_3

        vx_array |> push(((camera_perspective * trans_vx_1).xy) / trans_vx_1.z + float2(620., 320.))
        vx_array |> push(((camera_perspective * trans_vx_2).xy) / trans_vx_2.z + float2(620., 320.))
        vx_array |> push(((camera_perspective * trans_vx_3).xy) / trans_vx_3.z + float2(620., 320.))

        screen |> draw_triangle_strip(vx_array, tc_array, cl_array)

        current = nxt4_arr[current]

    current = segment

    invoke() <| $()
        var vx_array: array<float2>
        var tc_array: array<float2>
        var cl_array: array<uint>

        let i_1 = current
        let i_2 = nxt4_arr[current]

        let v_1 = rotate(romb_transform, rvx_arr[i_1] * radius)
        let v_2 = rotate(romb_transform, rvx_arr[i_2] * radius)

        let v_3 = float3(0., 0.,   0.)
        let v_4 = float3(0., 0., -32.)

        let i_d = seg_seg_intersection(v_1.xz, v_2.xz, v_3.xz, v_4.xz)

        var trans_vx_c_1 = romb_transform * (rvx_arr[i_1] * radius)

        let trans_nm     = rotate(romb_transform, rnd_arr[i_1])

        tc_array |> push(float2(0., 0.))
        tc_array |> push(float2(0., 0.))
        tc_array |> push(float2(0., 0.))

        var trans_vx_1 = romb_transform * (float3(0., -1., 0.)        * radius)
        var trans_vx_2 = float3(i_d.vx.x, 0.    , i_d.vx.y) + romb_transform[3]
        var trans_vx_3 = romb_transform * (rvx_arr[i_2] * radius)

        var color_1 = color
        var color_2 = color
        var color_3 = color

        for light in lights
            color_1 += calc_color(trans_vx_1  , trans_nm, light)
            color_2 += calc_color(trans_vx_c_1, trans_nm, light)
            color_3 += calc_color(trans_vx_3  , trans_nm, light)

        cl_array |> push(make_color(color_1))
        cl_array |> push(make_color(color_2 + (color_3 - color_2) * i_d.t))
        cl_array |> push(make_color(color_3))

        trans_vx_1 = camera_transform * trans_vx_1
        trans_vx_2 = camera_transform * trans_vx_2
        trans_vx_3 = camera_transform * trans_vx_3

        vx_array |> push(((camera_perspective * trans_vx_1).xy) / trans_vx_1.z + float2(620., 320.))
        vx_array |> push(((camera_perspective * trans_vx_2).xy) / trans_vx_2.z + float2(620., 320.))
        vx_array |> push(((camera_perspective * trans_vx_3).xy) / trans_vx_3.z + float2(620., 320.))

        screen |> draw_triangle_strip(vx_array, tc_array, cl_array)

        current = nxt4_arr[current]

    for i in range(1)
        var vx_array: array<float2>
        var tc_array: array<float2>
        var cl_array: array<uint>

        var trans_vx_1 = romb_transform * (float3(0., -1., 0.)        * radius)
        var trans_vx_2 = romb_transform * (rvx_arr[current]           * radius)
        var trans_vx_3 = romb_transform * (rvx_arr[nxt4_arr[current]] * radius)

        let trans_nm   = rotate(romb_transform, rnd_arr[current])

        tc_array |> push(float2(0., 0.))
        tc_array |> push(float2(0., 0.))
        tc_array |> push(float2(0., 0.))

        var color_1 = color
        var color_2 = color
        var color_3 = color

        for light in lights
            color_1 += calc_color(trans_vx_1, trans_nm, light)
            color_2 += calc_color(trans_vx_2, trans_nm, light)
            color_3 += calc_color(trans_vx_3, trans_nm, light)

        cl_array |> push(make_color(color_1))
        cl_array |> push(make_color(color_2))
        cl_array |> push(make_color(color_3))

        trans_vx_1 = camera_transform * trans_vx_1
        trans_vx_2 = camera_transform * trans_vx_2
        trans_vx_3 = camera_transform * trans_vx_3

        vx_array |> push(((camera_perspective * trans_vx_1).xy) / trans_vx_1.z + float2(620., 320.))
        vx_array |> push(((camera_perspective * trans_vx_2).xy) / trans_vx_2.z + float2(620., 320.))
        vx_array |> push(((camera_perspective * trans_vx_3).xy) / trans_vx_3.z + float2(620., 320.))

        screen |> draw_triangle_strip(vx_array, tc_array, cl_array)

        current = nxt4_arr[current]

    invoke() <| $()
        var vx_array: array<float2>
        var tc_array: array<float2>
        var cl_array: array<uint>

        let i_1 = current
        let i_2 = nxt4_arr[current]

        let v_1 = rotate(romb_transform, rvx_arr[i_1] * radius)
        let v_2 = rotate(romb_transform, rvx_arr[i_2] * radius)

        let v_3 = float3(0., 0.,   0.)
        let v_4 = float3(0., 0., -32.)

        let i_d = seg_seg_intersection(v_1.xz, v_2.xz, v_3.xz, v_4.xz)

        var trans_vx_c_1 = romb_transform * (rvx_arr[i_2] * radius)

        let trans_nm     = rotate(romb_transform, rnd_arr[i_1])

        tc_array |> push(float2(0., 0.))
        tc_array |> push(float2(0., 0.))
        tc_array |> push(float2(0., 0.))

        var trans_vx_1 = romb_transform * (float3(0., -1., 0.)        * radius)
        var trans_vx_2 = float3(i_d.vx.x, 0.    , i_d.vx.y) + romb_transform[3]
        var trans_vx_3 = romb_transform * (rvx_arr[i_1] * radius)

        var color_1 = color
        var color_2 = color
        var color_3 = color

        for light in lights
            color_1 += calc_color(trans_vx_1  , trans_nm, light)
            color_2 += calc_color(trans_vx_c_1, trans_nm, light)
            color_3 += calc_color(trans_vx_3  , trans_nm, light)

        cl_array |> push(make_color(color_1))
        cl_array |> push(make_color(color_2 + (color_3 - color_2) * i_d.t))
        cl_array |> push(make_color(color_3))

        trans_vx_1 = camera_transform * trans_vx_1
        trans_vx_2 = camera_transform * trans_vx_2
        trans_vx_3 = camera_transform * trans_vx_3

        vx_array |> push(((camera_perspective * trans_vx_1).xy) / trans_vx_1.z + float2(620., 320.))
        vx_array |> push(((camera_perspective * trans_vx_2).xy) / trans_vx_2.z + float2(620., 320.))
        vx_array |> push(((camera_perspective * trans_vx_3).xy) / trans_vx_3.z + float2(620., 320.))

        screen |> draw_triangle_strip(vx_array, tc_array, cl_array)

        current = nxt4_arr[current]

def draw_romb_r(radius             : float;
                color              : float3;
                segment            : uint ;
                lights             : array<light_t>;
                romb_transform     : float3x4;
                camera_transform   : float3x4;
                camera_perspective : float3x4)

    var current = segment

    invoke() <| $()
        var vx_array: array<float2>
        var tc_array: array<float2>
        var cl_array: array<uint>

        let i_1 = current
        let i_2 = nxt4_arr[current]

        let v_1 = rotate(romb_transform, rvx_arr[i_1] * radius)
        let v_2 = rotate(romb_transform, rvx_arr[i_2] * radius)

        let v_3 = float3(0., 0., 0.)
        let v_4 = float3(0., 0., 32.)

        let i_d = seg_seg_intersection(v_1.xz, v_2.xz, v_3.xz, v_4.xz)

        var trans_vx_c_1 = romb_transform * (rvx_arr[i_2] * radius)

        let trans_nm     = rotate(romb_transform, rnu_arr[i_1])

        tc_array |> push(float2(0., 0.))
        tc_array |> push(float2(0., 0.))
        tc_array |> push(float2(0., 0.))

        var trans_vx_1 = romb_transform * (float3(0., 1., 0.)         * radius)
        var trans_vx_2 = float3(i_d.vx.x, 0.    , i_d.vx.y) + romb_transform[3]
        var trans_vx_3 = romb_transform * (rvx_arr[i_1] * radius)

        var color_1 = color
        var color_2 = color
        var color_3 = color

        for light in lights
            color_1 += calc_color(trans_vx_1  , trans_nm, light)
            color_2 += calc_color(trans_vx_c_1, trans_nm, light)
            color_3 += calc_color(trans_vx_3  , trans_nm, light)

        cl_array |> push(make_color(color_1))
        cl_array |> push(make_color(color_2 + (color_3 - color_2) * (1. - i_d.t)))
        cl_array |> push(make_color(color_3))

        trans_vx_1 = camera_transform * trans_vx_1
        trans_vx_2 = camera_transform * trans_vx_2
        trans_vx_3 = camera_transform * trans_vx_3

        vx_array |> push(((camera_perspective * trans_vx_1).xy) / trans_vx_1.z + float2(620., 320.))
        vx_array |> push(((camera_perspective * trans_vx_2).xy) / trans_vx_2.z + float2(620., 320.))
        vx_array |> push(((camera_perspective * trans_vx_3).xy) / trans_vx_3.z + float2(620., 320.))

        screen |> draw_triangle_strip(vx_array, tc_array, cl_array)

        current = prv4_arr[current]

    for i in range(1)
        var vx_array: array<float2>
        var tc_array: array<float2>
        var cl_array: array<uint>
        
        var trans_vx_1 = romb_transform * (float3(0., 1., 0.)         * radius)
        var trans_vx_2 = romb_transform * (rvx_arr[current]           * radius)
        var trans_vx_3 = romb_transform * (rvx_arr[nxt4_arr[current]] * radius)

        let trans_nm   = rotate(romb_transform, rnu_arr[current])

        tc_array |> push(float2(0., 0.))
        tc_array |> push(float2(0., 0.))
        tc_array |> push(float2(0., 0.))

        var color_1 = color
        var color_2 = color
        var color_3 = color

        for light in lights
            color_1 += calc_color(trans_vx_1, trans_nm, light)
            color_2 += calc_color(trans_vx_2, trans_nm, light)
            color_3 += calc_color(trans_vx_3, trans_nm, light)

        cl_array |> push(make_color(color_1))
        cl_array |> push(make_color(color_2))
        cl_array |> push(make_color(color_3))

        trans_vx_1 = camera_transform * trans_vx_1
        trans_vx_2 = camera_transform * trans_vx_2
        trans_vx_3 = camera_transform * trans_vx_3

        vx_array |> push(((camera_perspective * trans_vx_1).xy) / trans_vx_1.z + float2(620., 320.))
        vx_array |> push(((camera_perspective * trans_vx_2).xy) / trans_vx_2.z + float2(620., 320.))
        vx_array |> push(((camera_perspective * trans_vx_3).xy) / trans_vx_3.z + float2(620., 320.))

        screen |> draw_triangle_strip(vx_array, tc_array, cl_array)

        current = prv4_arr[current]

    invoke() <| $()
        var vx_array: array<float2>
        var tc_array: array<float2>
        var cl_array: array<uint>

        let i_1 = current
        let i_2 = nxt4_arr[current]

        let v_1 = rotate(romb_transform, rvx_arr[i_1] * radius)
        let v_2 = rotate(romb_transform, rvx_arr[i_2] * radius)

        let v_3 = float3(0., 0., 0.  )
        let v_4 = float3(0., 0., -32.)

        let i_d = seg_seg_intersection(v_1.xz, v_2.xz, v_3.xz, v_4.xz)

        var trans_vx_c_1 = romb_transform * (rvx_arr[i_1] * radius)

        let trans_nm     = rotate(romb_transform, rnu_arr[i_1])

        tc_array |> push(float2(0., 0.))
        tc_array |> push(float2(0., 0.))
        tc_array |> push(float2(0., 0.))

        var trans_vx_1 = romb_transform * (float3(0., +1., 0.)        * radius)
        var trans_vx_2 = float3(i_d.vx.x, 0.    , i_d.vx.y) + romb_transform[3]
        var trans_vx_3 = romb_transform * (rvx_arr[i_2] * radius)

        var color_1 = color
        var color_2 = color
        var color_3 = color

        for light in lights
            color_1 += calc_color(trans_vx_1  , trans_nm, light)
            color_2 += calc_color(trans_vx_c_1, trans_nm, light)
            color_3 += calc_color(trans_vx_3  , trans_nm, light)

        cl_array |> push(make_color(color_1))
        cl_array |> push(make_color(color_2 + (color_3 - color_2) * (1. - i_d.t)))
        cl_array |> push(make_color(color_3))

        trans_vx_1 = camera_transform * trans_vx_1
        trans_vx_2 = camera_transform * trans_vx_2
        trans_vx_3 = camera_transform * trans_vx_3

        vx_array |> push(((camera_perspective * trans_vx_1).xy) / trans_vx_1.z + float2(620., 320.))
        vx_array |> push(((camera_perspective * trans_vx_2).xy) / trans_vx_2.z + float2(620., 320.))
        vx_array |> push(((camera_perspective * trans_vx_3).xy) / trans_vx_3.z + float2(620., 320.))

        screen |> draw_triangle_strip(vx_array, tc_array, cl_array)

        current = nxt4_arr[current]

    current = segment

    invoke() <| $()
        var vx_array: array<float2>
        var tc_array: array<float2>
        var cl_array: array<uint>

        let i_1 = current
        let i_2 = nxt4_arr[current]

        let v_1 = rotate(romb_transform, rvx_arr[i_1] * radius)
        let v_2 = rotate(romb_transform, rvx_arr[i_2] * radius)

        let v_3 = float3(0., 0.,   0.)
        let v_4 = float3(0., 0., +32.)

        let i_d = seg_seg_intersection(v_1.xz, v_2.xz, v_3.xz, v_4.xz)

        var trans_vx_c_1 = romb_transform * (rvx_arr[i_2] * radius)

        let trans_nm     = rotate(romb_transform, rnd_arr[i_1])

        tc_array |> push(float2(0., 0.))
        tc_array |> push(float2(0., 0.))
        tc_array |> push(float2(0., 0.))

        var trans_vx_1 = romb_transform * (float3(0., -1., 0.)        * radius)
        var trans_vx_2 = float3(i_d.vx.x, 0.    , i_d.vx.y) + romb_transform[3]
        var trans_vx_3 = romb_transform * (rvx_arr[i_1] * radius)

        var color_1 = color
        var color_2 = color
        var color_3 = color

        for light in lights
            color_1 += calc_color(trans_vx_1  , trans_nm, light)
            color_2 += calc_color(trans_vx_c_1, trans_nm, light)
            color_3 += calc_color(trans_vx_3  , trans_nm, light)

        cl_array |> push(make_color(color_1))
        cl_array |> push(make_color(color_2 + (color_3 - color_2) * (1. - i_d.t)))
        cl_array |> push(make_color(color_3))

        trans_vx_1 = camera_transform * trans_vx_1
        trans_vx_2 = camera_transform * trans_vx_2
        trans_vx_3 = camera_transform * trans_vx_3

        vx_array |> push(((camera_perspective * trans_vx_1).xy) / trans_vx_1.z + float2(620., 320.))
        vx_array |> push(((camera_perspective * trans_vx_2).xy) / trans_vx_2.z + float2(620., 320.))
        vx_array |> push(((camera_perspective * trans_vx_3).xy) / trans_vx_3.z + float2(620., 320.))

        screen |> draw_triangle_strip(vx_array, tc_array, cl_array)

        current = prv4_arr[current]

    for i in range(1)
        var vx_array: array<float2>
        var tc_array: array<float2>
        var cl_array: array<uint>

        var trans_vx_1 = romb_transform * (float3(0., -1., 0.)        * radius)
        var trans_vx_2 = romb_transform * (rvx_arr[current]           * radius)
        var trans_vx_3 = romb_transform * (rvx_arr[nxt4_arr[current]] * radius)

        let trans_nm   = rotate(romb_transform, rnd_arr[current])

        tc_array |> push(float2(0., 0.))
        tc_array |> push(float2(0., 0.))
        tc_array |> push(float2(0., 0.))

        var color_1 = color
        var color_2 = color
        var color_3 = color

        for light in lights
            color_1 += calc_color(trans_vx_1, trans_nm, light)
            color_2 += calc_color(trans_vx_2, trans_nm, light)
            color_3 += calc_color(trans_vx_3, trans_nm, light)

        cl_array |> push(make_color(color_1))
        cl_array |> push(make_color(color_2))
        cl_array |> push(make_color(color_3))

        trans_vx_1 = camera_transform * trans_vx_1
        trans_vx_2 = camera_transform * trans_vx_2
        trans_vx_3 = camera_transform * trans_vx_3

        vx_array |> push(((camera_perspective * trans_vx_1).xy) / trans_vx_1.z + float2(620., 320.))
        vx_array |> push(((camera_perspective * trans_vx_2).xy) / trans_vx_2.z + float2(620., 320.))
        vx_array |> push(((camera_perspective * trans_vx_3).xy) / trans_vx_3.z + float2(620., 320.))

        screen |> draw_triangle_strip(vx_array, tc_array, cl_array)

        current = prv4_arr[current]

    invoke() <| $()
        var vx_array: array<float2>
        var tc_array: array<float2>
        var cl_array: array<uint>

        let i_1 = current
        let i_2 = nxt4_arr[current]

        let v_1 = rotate(romb_transform, rvx_arr[i_1] * radius)
        let v_2 = rotate(romb_transform, rvx_arr[i_2] * radius)

        let v_3 = float3(0., 0.,   0.)
        let v_4 = float3(0., 0., -32.)

        let i_d = seg_seg_intersection(v_1.xz, v_2.xz, v_3.xz, v_4.xz)

        var trans_vx_c_1 = romb_transform * (rvx_arr[i_1] * radius)

        let trans_nm     = rotate(romb_transform, rnd_arr[i_1])

        tc_array |> push(float2(0., 0.))
        tc_array |> push(float2(0., 0.))
        tc_array |> push(float2(0., 0.))

        var trans_vx_1 = romb_transform * (float3(0., -1., 0.)        * radius)
        var trans_vx_2 = float3(i_d.vx.x, 0.    , i_d.vx.y) + romb_transform[3]
        var trans_vx_3 = romb_transform * (rvx_arr[i_2] * radius)

        var color_1 = color
        var color_2 = color
        var color_3 = color

        for light in lights
            color_1 += calc_color(trans_vx_1  , trans_nm, light)
            color_2 += calc_color(trans_vx_c_1, trans_nm, light)
            color_3 += calc_color(trans_vx_3  , trans_nm, light)

        cl_array |> push(make_color(color_1))
        cl_array |> push(make_color(color_2 + (color_3 - color_2) * (1. - i_d.t)))
        cl_array |> push(make_color(color_3))

        trans_vx_1 = camera_transform * trans_vx_1
        trans_vx_2 = camera_transform * trans_vx_2
        trans_vx_3 = camera_transform * trans_vx_3

        vx_array |> push(((camera_perspective * trans_vx_1).xy) / trans_vx_1.z + float2(620., 320.))
        vx_array |> push(((camera_perspective * trans_vx_2).xy) / trans_vx_2.z + float2(620., 320.))
        vx_array |> push(((camera_perspective * trans_vx_3).xy) / trans_vx_3.z + float2(620., 320.))

        screen |> draw_triangle_strip(vx_array, tc_array, cl_array)

        current = nxt4_arr[current]

def draw_romb(radius             : float;
              color              : float3;
              segment            : uint ;
              lights             : array<light_t>;
              romb_transform     : float3x4;
              camera_transform   : float3x4;
              camera_perspective : float3x4)
    if romb_transform[3].x <= 0.
        draw_romb_l(radius, color, segment, 
                    lights, romb_transform,
                    camera_transform, camera_perspective)
        draw_romb_r(radius, color, segment, 
                    lights, romb_transform,
                    camera_transform, camera_perspective)
    else
        draw_romb_r(radius, color, segment,
                    lights, romb_transform,
                    camera_transform, camera_perspective)
        draw_romb_l(radius, color, segment, 
                    lights, romb_transform,
                    camera_transform, camera_perspective)

def draw_sphere(radius             : float;
                color              : float3;
                segment            : uint ;
                lights             : array<light_t>;
                sphere_transform   : float3x4;
                camera_transform   : float3x4;
                camera_perspective : float3x4)
    for s in range(6)
        var vx_array: array<float2>
        var tc_array: array<float2>
        var cl_array: array<uint>

        var current = segment

        for i in range(0, 13)
            var trans_vx_1 = sphere_transform * float3(cos_arr[current] * rad_arr[s + 0] * radius, hgt_arr[s + 0] * radius,
                sin_arr[current] * rad_arr[s + 0] * radius)
            var trans_vx_2 = sphere_transform * float3(cos_arr[current] * rad_arr[s + 1] * radius, hgt_arr[s + 1] * radius,
                sin_arr[current] * rad_arr[s + 1] * radius)
    
            let trans_nm_1 = rotate(sphere_transform, float3(cos_arr[current] * rad_arr[s + 0],
                hgt_arr[s + 0], sin_arr[current] * rad_arr[s + 0]))
            let trans_nm_2 = rotate(sphere_transform, float3(cos_arr[current] * rad_arr[s + 1],
                hgt_arr[s + 1], sin_arr[current] * rad_arr[s + 1]))
    
            tc_array |> push(float2(0., 0.))
            tc_array |> push(float2(0., 0.))
    
            var color_1 = color
            var color_2 = color

            for light in lights
                color_1 += calc_color(trans_vx_1, trans_nm_1, light)
                color_2 += calc_color(trans_vx_2, trans_nm_2, light)
        
            cl_array |> push(make_color(color_1))
            cl_array |> push(make_color(color_2))
    
            trans_vx_1 = camera_transform * trans_vx_1
            trans_vx_2 = camera_transform * trans_vx_2
    
            vx_array |> push(((camera_perspective * trans_vx_1).xy) / trans_vx_1.z + float2(620., 320.))
            vx_array |> push(((camera_perspective * trans_vx_2).xy) / trans_vx_2.z + float2(620., 320.))

            current = nxt_arr[current]

        screen |> draw_triangle_strip(vx_array, tc_array, cl_array)


def draw_cylinder(radius             : float;
                  height             : float;
                  color              : float3;
                  segment            : uint ;
                  lights             : array<light_t>;
                  cylinder_transform : float3x4;
                  camera_transform   : float3x4;
                  camera_perspective : float3x4)
    var vx_array: array<float2>
    var tc_array: array<float2>
    var cl_array: array<uint>

    var current = segment

    invoke() <| $()
        let i_1 = current
        let i_2 = nxt_arr[current]

        let v_1 = rotate(cylinder_transform, float3(cos_arr[i_1] * radius, 0., sin_arr[i_1] * radius))
        let v_2 = rotate(cylinder_transform, float3(cos_arr[i_2] * radius, 0., sin_arr[i_2] * radius))

        let v_3 = float3(0. , 0., 0.)
        let v_4 = float3(32., 0., 0.)

        let i_d = seg_seg_intersection(v_1.xz, v_2.xz, v_3.xz, v_4.xz)

        var trans_vx_c_1 = cylinder_transform * float3(cos_arr[i_1] * radius, 0.,
            sin_arr[i_1] * radius)
        var trans_vx_c_2 = cylinder_transform * float3(cos_arr[i_2] * radius, 0.,
            sin_arr[i_2] * radius)

        let trans_nm_1 = rotate(cylinder_transform, float3(cos_arr[i_1], 0., sin_arr[i_1]))
        let trans_nm_2 = rotate(cylinder_transform, float3(cos_arr[i_2], 0., sin_arr[i_2]))

        var color_1 = color
        var color_2 = color

        for light in lights
            color_1 += calc_color(trans_vx_c_1, trans_nm_1, light)
            color_2 += calc_color(trans_vx_c_2, trans_nm_2, light)

        var trans_vx_c_3 = cylinder_transform * float3(cos_arr[i_1] * radius, height,
            sin_arr[i_1] * radius)
        var trans_vx_c_4 = cylinder_transform * float3(cos_arr[i_2] * radius, height,
            sin_arr[i_2] * radius)

        var color_3 = color
        var color_4 = color

        for light in lights
            color_3 += calc_color(trans_vx_c_3, trans_nm_1, light)
            color_4 += calc_color(trans_vx_c_4, trans_nm_2, light)

        cl_array |> push(make_color(color_1 + (color_2 - color_1) * i_d.t))
        cl_array |> push(make_color(color_3 + (color_4 - color_3) * i_d.t))

        let trans_vx_1 = camera_transform * (float3(i_d.vx.x, 0.    , i_d.vx.y) + cylinder_transform[3])
        let trans_vx_2 = camera_transform * (float3(i_d.vx.x, height, i_d.vx.y) + cylinder_transform[3])

        tc_array |> push(float2(0., 0.))
        tc_array |> push(float2(0., 0.))

        vx_array |> push(((camera_perspective * trans_vx_1).xy) / trans_vx_1.z + float2(620., 320.))
        vx_array |> push(((camera_perspective * trans_vx_2).xy) / trans_vx_2.z + float2(620., 320.))

        current = nxt_arr[current]


    for i in range(0, 12)
        var trans_vx_1 = cylinder_transform * float3(cos_arr[current] * radius, 0.    ,
            sin_arr[current] * radius)
        var trans_vx_2 = cylinder_transform * float3(cos_arr[current] * radius, height,
            sin_arr[current] * radius)
 
        let trans_nm_1 = rotate(cylinder_transform, float3(cos_arr[current], 0., sin_arr[current]))
        let trans_nm_2 = rotate(cylinder_transform, float3(cos_arr[current], 0., sin_arr[current]))
 
        tc_array |> push(float2(0., 0.))
        tc_array |> push(float2(0., 0.))
 
        var color_1 = color
        var color_2 = color

        for light in lights
            color_1 += calc_color(trans_vx_1, trans_nm_1, light)
            color_2 += calc_color(trans_vx_2, trans_nm_2, light)
    
        cl_array |> push(make_color(color_1))
        cl_array |> push(make_color(color_2))
 
        trans_vx_1 = camera_transform * trans_vx_1
        trans_vx_2 = camera_transform * trans_vx_2
 
        vx_array |> push(((camera_perspective * trans_vx_1).xy) / trans_vx_1.z + float2(620., 320.))
        vx_array |> push(((camera_perspective * trans_vx_2).xy) / trans_vx_2.z + float2(620., 320.))

        current = nxt_arr[current]

    invoke() <| $()
        let i_1 = prv_arr[current]
        let i_2 = current

        let v_1 = rotate(cylinder_transform, float3(cos_arr[i_1] * radius, 0., sin_arr[i_1] * radius))
        let v_2 = rotate(cylinder_transform, float3(cos_arr[i_2] * radius, 0., sin_arr[i_2] * radius))

        let v_3 = float3(0. , 0., 0.)
        let v_4 = float3(32., 0., 0.)

        let i_d = seg_seg_intersection(v_1.xz, v_2.xz, v_3.xz, v_4.xz)

        var trans_vx_c_1 = cylinder_transform * float3(cos_arr[i_1] * radius, 0.,
            sin_arr[i_1] * radius)
        var trans_vx_c_2 = cylinder_transform * float3(cos_arr[i_2] * radius, 0.,
            sin_arr[i_2] * radius)

        let trans_nm_1 = rotate(cylinder_transform, float3(cos_arr[i_1], 0., sin_arr[i_1]))
        let trans_nm_2 = rotate(cylinder_transform, float3(cos_arr[i_2], 0., sin_arr[i_2]))

        var color_1 = color
        var color_2 = color

        for light in lights
            color_1 += calc_color(trans_vx_c_1, trans_nm_1, light)
            color_2 += calc_color(trans_vx_c_2, trans_nm_2, light)

        var trans_vx_c_3 = cylinder_transform * float3(cos_arr[i_1] * radius, height,
            sin_arr[i_1] * radius)
        var trans_vx_c_4 = cylinder_transform * float3(cos_arr[i_2] * radius, height,
            sin_arr[i_2] * radius)

        var color_3 = color
        var color_4 = color

        for light in lights
            color_3 += calc_color(trans_vx_c_3, trans_nm_1, light)
            color_4 += calc_color(trans_vx_c_4, trans_nm_2, light)

        cl_array |> push(make_color(color_1 + (color_2 - color_1) * i_d.t))
        cl_array |> push(make_color(color_3 + (color_4 - color_3) * i_d.t))  

        let trans_vx_1 = camera_transform * (float3(i_d.vx.x, 0.    , i_d.vx.y) + cylinder_transform[3])
        let trans_vx_2 = camera_transform * (float3(i_d.vx.x, height, i_d.vx.y) + cylinder_transform[3])

        tc_array |> push(float2(0., 0.))
        tc_array |> push(float2(0., 0.))

        vx_array |> push(((camera_perspective * trans_vx_1).xy) / trans_vx_1.z + float2(620., 320.))
        vx_array |> push(((camera_perspective * trans_vx_2).xy) / trans_vx_2.z + float2(620., 320.))

        current = nxt_arr[current]

    screen |> draw_triangle_strip(vx_array, tc_array, cl_array)

def draw_platform_walls_l(b_radius           : float;
                          s_radius           : float;
                          height             : float;
                          used_arr           : uint[12];
                          walls              : uint[12];
                          color              : float3;
                          segment            : uint ;
                          lights             : array<light_t>;
                          cylinder_transform : float3x4;
                          camera_transform   : float3x4;
                          camera_perspective : float3x4)
    var vx_array: array<float2>
    var tc_array: array<float2>
    var cl_array: array<uint>

    var current = segment

    invoke() <| $()
        let i_1 = current
        let i_2 = nxt_arr[current]

        let v_1 = rotate(cylinder_transform, float3(cos_arr[i_1] * b_radius, 0., sin_arr[i_1] * b_radius))
        let v_2 = rotate(cylinder_transform, float3(cos_arr[i_2] * b_radius, 0., sin_arr[i_2] * b_radius))

        let v_3 = float3(0., 0., 0.)
        let v_4 = float3(0., 0., 32.)

        let i_d = seg_seg_intersection(v_1.xz, v_2.xz, v_3.xz, v_4.xz)

        var trans_vx_c_1 = cylinder_transform * float3(cos_arr[i_1] * b_radius, 0.,
            sin_arr[i_1] * b_radius)
        var trans_vx_c_2 = cylinder_transform * float3(cos_arr[i_2] * b_radius, 0.,
            sin_arr[i_2] * b_radius)

        let trans_nm_1 = rotate(cylinder_transform, float3(cos_arr[i_1], 0., sin_arr[i_1]))
        let trans_nm_2 = rotate(cylinder_transform, float3(cos_arr[i_2], 0., sin_arr[i_2]))

        var color_1 = color
        var color_2 = color

        for light in lights
            color_1 += calc_color(trans_vx_c_1, trans_nm_1, light)
            color_2 += calc_color(trans_vx_c_2, trans_nm_2, light)

        var trans_vx_c_3 = cylinder_transform * float3(cos_arr[i_1] * b_radius, height,
            sin_arr[i_1] * b_radius)
        var trans_vx_c_4 = cylinder_transform * float3(cos_arr[i_2] * b_radius, height,
            sin_arr[i_2] * b_radius)

        var color_3 = color
        var color_4 = color

        for light in lights
            color_3 += calc_color(trans_vx_c_3, trans_nm_1, light)
            color_4 += calc_color(trans_vx_c_4, trans_nm_2, light)

        cl_array |> push(make_color(color_1 + (color_2 - color_1) * i_d.t))
        cl_array |> push(make_color(color_3 + (color_4 - color_3) * i_d.t))

        let trans_vx_1 = camera_transform * (float3(i_d.vx.x, 0.    , i_d.vx.y) + cylinder_transform[3])
        let trans_vx_2 = camera_transform * (float3(i_d.vx.x, height, i_d.vx.y) + cylinder_transform[3])

        tc_array |> push(float2(0., 0.))
        tc_array |> push(float2(0., 0.))

        vx_array |> push(((camera_perspective * trans_vx_1).xy) / trans_vx_1.z + float2(620., 320.))
        vx_array |> push(((camera_perspective * trans_vx_2).xy) / trans_vx_2.z + float2(620., 320.))

        if used_arr[current] == 0u
            screen |> draw_triangle_strip(vx_array, tc_array, cl_array)

            vx_array |> clear()
            tc_array |> clear()
            cl_array |> clear()

        current = nxt_arr[current]


    for i in range(0, 6)
        if walls[current] == 1u && walls[prv_arr[current]] == 0u
            var trans_vx_1 = cylinder_transform * float3(cos_arr[current] * s_radius,     0., sin_arr[current] * s_radius)
            var trans_vx_2 = cylinder_transform * float3(cos_arr[current] * s_radius, height, sin_arr[current] * s_radius)

            let trans_nm = rotate(cylinder_transform, float3(sin_arr[current], 0., -cos_arr[current]))
    
            tc_array |> push(float2(0., 0.))
            tc_array |> push(float2(0., 0.))

            var color_1 = color
            var color_2 = color

            for light in lights
                color_1 += calc_color(trans_vx_1, trans_nm, light)
                color_2 += calc_color(trans_vx_1, trans_nm, light)

            cl_array |> push(make_color(color_1))
            cl_array |> push(make_color(color_2))
    
            trans_vx_1 = camera_transform * trans_vx_1
            trans_vx_2 = camera_transform * trans_vx_2
    
            vx_array |> push(((camera_perspective * trans_vx_1).xy) / trans_vx_1.z + float2(620., 320.))
            vx_array |> push(((camera_perspective * trans_vx_2).xy) / trans_vx_2.z + float2(620., 320.))

            var trans_vx_3 = cylinder_transform * float3(cos_arr[current] * b_radius,     0., sin_arr[current] * b_radius)
            var trans_vx_4 = cylinder_transform * float3(cos_arr[current] * b_radius, height, sin_arr[current] * b_radius)

            tc_array |> push(float2(0., 0.))
            tc_array |> push(float2(0., 0.))

            var color_3 = color
            var color_4 = color

            for light in lights
                color_3 += calc_color(trans_vx_3, trans_nm, light)
                color_4 += calc_color(trans_vx_4, trans_nm, light)

            cl_array |> push(make_color(color_3))
            cl_array |> push(make_color(color_4))
    
            trans_vx_3 = camera_transform * trans_vx_3
            trans_vx_4 = camera_transform * trans_vx_4
    
            vx_array |> push(((camera_perspective * trans_vx_3).xy) / trans_vx_3.z + float2(620., 320.))
            vx_array |> push(((camera_perspective * trans_vx_4).xy) / trans_vx_4.z + float2(620., 320.))

            screen |> draw_triangle_strip(vx_array, tc_array, cl_array)

            vx_array |> clear()
            tc_array |> clear()
            cl_array |> clear()

        invoke() <| $()
            var trans_vx_1 = cylinder_transform * float3(cos_arr[current] * b_radius, 0.    ,
                sin_arr[current] * b_radius)
            var trans_vx_2 = cylinder_transform * float3(cos_arr[current] * b_radius, height,
                sin_arr[current] * b_radius)
    
            let trans_nm_1 = rotate(cylinder_transform, float3(cos_arr[current], 0., sin_arr[current]))
            let trans_nm_2 = rotate(cylinder_transform, float3(cos_arr[current], 0., sin_arr[current]))
    
            tc_array |> push(float2(0., 0.))
            tc_array |> push(float2(0., 0.))
    
            var color_1 = color
            var color_2 = color

            for light in lights
                color_1 += calc_color(trans_vx_1, trans_nm_1, light)
                color_2 += calc_color(trans_vx_2, trans_nm_2, light)
        
            cl_array |> push(make_color(color_1))
            cl_array |> push(make_color(color_2))
    
            trans_vx_1 = camera_transform * trans_vx_1
            trans_vx_2 = camera_transform * trans_vx_2
    
            vx_array |> push(((camera_perspective * trans_vx_1).xy) / trans_vx_1.z + float2(620., 320.))
            vx_array |> push(((camera_perspective * trans_vx_2).xy) / trans_vx_2.z + float2(620., 320.))

        if used_arr[current] == 0u
            screen |> draw_triangle_strip(vx_array, tc_array, cl_array)
 
            vx_array |> clear()
            tc_array |> clear()
            cl_array |> clear()

        if walls[current] == 0u && walls[prv_arr[current]] == 1u
            var trans_vx_1 = cylinder_transform * float3(cos_arr[current] * s_radius,     0., sin_arr[current] * s_radius)
            var trans_vx_2 = cylinder_transform * float3(cos_arr[current] * s_radius, height, sin_arr[current] * s_radius)

            let trans_nm = rotate(cylinder_transform, float3(-sin_arr[current], 0., cos_arr[current]))
    
            tc_array |> push(float2(0., 0.))
            tc_array |> push(float2(0., 0.))

            var color_1 = color
            var color_2 = color

            for light in lights
                color_1 += calc_color(trans_vx_1, trans_nm, light)
                color_2 += calc_color(trans_vx_1, trans_nm, light)

            cl_array |> push(make_color(color_1))
            cl_array |> push(make_color(color_2))
    
            trans_vx_1 = camera_transform * trans_vx_1
            trans_vx_2 = camera_transform * trans_vx_2
    
            vx_array |> push(((camera_perspective * trans_vx_1).xy) / trans_vx_1.z + float2(620., 320.))
            vx_array |> push(((camera_perspective * trans_vx_2).xy) / trans_vx_2.z + float2(620., 320.))

            var trans_vx_3 = cylinder_transform * float3(cos_arr[current] * b_radius,     0., sin_arr[current] * b_radius)
            var trans_vx_4 = cylinder_transform * float3(cos_arr[current] * b_radius, height, sin_arr[current] * b_radius)

            tc_array |> push(float2(0., 0.))
            tc_array |> push(float2(0., 0.))

            var color_3 = color
            var color_4 = color

            for light in lights
                color_3 += calc_color(trans_vx_3, trans_nm, light)
                color_4 += calc_color(trans_vx_4, trans_nm, light)

            cl_array |> push(make_color(color_3))
            cl_array |> push(make_color(color_4))
    
            trans_vx_3 = camera_transform * trans_vx_3
            trans_vx_4 = camera_transform * trans_vx_4
    
            vx_array |> push(((camera_perspective * trans_vx_3).xy) / trans_vx_3.z + float2(620., 320.))
            vx_array |> push(((camera_perspective * trans_vx_4).xy) / trans_vx_4.z + float2(620., 320.))

            screen |> draw_triangle_strip(vx_array, tc_array, cl_array)

            vx_array |> clear()
            tc_array |> clear()
            cl_array |> clear()

        current = nxt_arr[current]

    invoke() <| $()
        let i_1 = prv_arr[current]
        let i_2 = current

        let v_1 = rotate(cylinder_transform, float3(cos_arr[i_1] * b_radius, 0., sin_arr[i_1] * b_radius))
        let v_2 = rotate(cylinder_transform, float3(cos_arr[i_2] * b_radius, 0., sin_arr[i_2] * b_radius))

        let v_3 = float3(0., 0.,   0.)
        let v_4 = float3(0., 0., -32.)

        let i_d = seg_seg_intersection(v_1.xz, v_2.xz, v_3.xz, v_4.xz)

        var trans_vx_c_1 = cylinder_transform * float3(cos_arr[i_1] * b_radius, 0.,
            sin_arr[i_1] * b_radius)
        var trans_vx_c_2 = cylinder_transform * float3(cos_arr[i_2] * b_radius, 0.,
            sin_arr[i_2] * b_radius)

        let trans_nm_1 = rotate(cylinder_transform, float3(cos_arr[i_1], 0., sin_arr[i_1]))
        let trans_nm_2 = rotate(cylinder_transform, float3(cos_arr[i_2], 0., sin_arr[i_2]))

        var color_1 = color
        var color_2 = color

        for light in lights
            color_1 += calc_color(trans_vx_c_1, trans_nm_1, light)
            color_2 += calc_color(trans_vx_c_2, trans_nm_2, light)

        var trans_vx_c_3 = cylinder_transform * float3(cos_arr[i_1] * b_radius, height,
            sin_arr[i_1] * b_radius)
        var trans_vx_c_4 = cylinder_transform * float3(cos_arr[i_2] * b_radius, height,
            sin_arr[i_2] * b_radius)

        var color_3 = color
        var color_4 = color

        for light in lights
            color_3 += calc_color(trans_vx_c_3, trans_nm_1, light)
            color_4 += calc_color(trans_vx_c_4, trans_nm_2, light)

        cl_array |> push(make_color(color_1 + (color_2 - color_1) * i_d.t))
        cl_array |> push(make_color(color_3 + (color_4 - color_3) * i_d.t))  

        let trans_vx_1 = camera_transform * (float3(i_d.vx.x, 0.    , i_d.vx.y) + cylinder_transform[3])
        let trans_vx_2 = camera_transform * (float3(i_d.vx.x, height, i_d.vx.y) + cylinder_transform[3])

        tc_array |> push(float2(0., 0.))
        tc_array |> push(float2(0., 0.))

        vx_array |> push(((camera_perspective * trans_vx_1).xy) / trans_vx_1.z + float2(620., 320.))
        vx_array |> push(((camera_perspective * trans_vx_2).xy) / trans_vx_2.z + float2(620., 320.))

        if used_arr[current] == 0u
            screen |> draw_triangle_strip(vx_array, tc_array, cl_array)
 
            vx_array |> clear()
            tc_array |> clear()
            cl_array |> clear()

        current = nxt_arr[current]

    screen |> draw_triangle_strip(vx_array, tc_array, cl_array)

def draw_platform_walls_r(b_radius           : float;
                          s_radius           : float;
                          height             : float;
                          used_arr           : uint[12];
                          walls              : uint[12];
                          color              : float3;
                          segment            : uint ;
                          lights             : array<light_t>;
                          cylinder_transform : float3x4;
                          camera_transform   : float3x4;
                          camera_perspective : float3x4)
    var vx_array: array<float2>
    var tc_array: array<float2>
    var cl_array: array<uint>

    var current = segment

    invoke() <| $()
        let i_1 = current
        let i_2 = nxt_arr[current]

        let v_1 = rotate(cylinder_transform, float3(cos_arr[i_1] * b_radius, 0., sin_arr[i_1] * b_radius))
        let v_2 = rotate(cylinder_transform, float3(cos_arr[i_2] * b_radius, 0., sin_arr[i_2] * b_radius))

        let v_3 = float3(0., 0., 0.)
        let v_4 = float3(0., 0., 32.)

        let i_d = seg_seg_intersection(v_1.xz, v_2.xz, v_3.xz, v_4.xz)

        var trans_vx_c_1 = cylinder_transform * float3(cos_arr[i_1] * b_radius, 0.,
            sin_arr[i_1] * b_radius)
        var trans_vx_c_2 = cylinder_transform * float3(cos_arr[i_2] * b_radius, 0.,
            sin_arr[i_2] * b_radius)

        let trans_nm_1 = rotate(cylinder_transform, float3(cos_arr[i_1], 0., sin_arr[i_1]))
        let trans_nm_2 = rotate(cylinder_transform, float3(cos_arr[i_2], 0., sin_arr[i_2]))

        var color_1 = color
        var color_2 = color

        for light in lights
            color_1 += calc_color(trans_vx_c_1, trans_nm_1, light)
            color_2 += calc_color(trans_vx_c_2, trans_nm_2, light)

        var trans_vx_c_3 = cylinder_transform * float3(cos_arr[i_1] * b_radius, height,
            sin_arr[i_1] * b_radius)
        var trans_vx_c_4 = cylinder_transform * float3(cos_arr[i_2] * b_radius, height,
            sin_arr[i_2] * b_radius)

        var color_3 = color
        var color_4 = color

        for light in lights
            color_3 += calc_color(trans_vx_c_3, trans_nm_1, light)
            color_4 += calc_color(trans_vx_c_4, trans_nm_2, light)

        cl_array |> push(make_color(color_1 + (color_2 - color_1) * i_d.t))
        cl_array |> push(make_color(color_3 + (color_4 - color_3) * i_d.t))

        let trans_vx_1 = camera_transform * (float3(i_d.vx.x, 0.    , i_d.vx.y) + cylinder_transform[3])
        let trans_vx_2 = camera_transform * (float3(i_d.vx.x, height, i_d.vx.y) + cylinder_transform[3])

        tc_array |> push(float2(0., 0.))
        tc_array |> push(float2(0., 0.))

        vx_array |> push(((camera_perspective * trans_vx_1).xy) / trans_vx_1.z + float2(620., 320.))
        vx_array |> push(((camera_perspective * trans_vx_2).xy) / trans_vx_2.z + float2(620., 320.))

        if used_arr[current] == 0u
            screen |> draw_triangle_strip(vx_array, tc_array, cl_array)

            vx_array |> clear()
            tc_array |> clear()
            cl_array |> clear()

    for i in range(0, 6)
        if used_arr[current] == 0u
            screen |> draw_triangle_strip(vx_array, tc_array, cl_array)
 
            vx_array |> clear()
            tc_array |> clear()
            cl_array |> clear()

        if walls[current] == 0u && walls[nxt_arr[current]] == 1u
            var trans_vx_1 = cylinder_transform * float3(cos_arr[current] * s_radius,     0., sin_arr[current] * s_radius)
            var trans_vx_2 = cylinder_transform * float3(cos_arr[current] * s_radius, height, sin_arr[current] * s_radius)

            let trans_nm = rotate(cylinder_transform, float3(-sin_arr[current], 0., cos_arr[current]))
    
            tc_array |> push(float2(0., 0.))
            tc_array |> push(float2(0., 0.))

            var color_1 = color
            var color_2 = color

            for light in lights
                color_1 += calc_color(trans_vx_1, trans_nm, light)
                color_2 += calc_color(trans_vx_1, trans_nm, light)

            cl_array |> push(make_color(color_1))
            cl_array |> push(make_color(color_2))
    
            trans_vx_1 = camera_transform * trans_vx_1
            trans_vx_2 = camera_transform * trans_vx_2
    
            vx_array |> push(((camera_perspective * trans_vx_1).xy) / trans_vx_1.z + float2(620., 320.))
            vx_array |> push(((camera_perspective * trans_vx_2).xy) / trans_vx_2.z + float2(620., 320.))

            var trans_vx_3 = cylinder_transform * float3(cos_arr[current] * b_radius,     0., sin_arr[current] * b_radius)
            var trans_vx_4 = cylinder_transform * float3(cos_arr[current] * b_radius, height, sin_arr[current] * b_radius)

            tc_array |> push(float2(0., 0.))
            tc_array |> push(float2(0., 0.))

            var color_3 = color
            var color_4 = color

            for light in lights
                color_3 += calc_color(trans_vx_3, trans_nm, light)
                color_4 += calc_color(trans_vx_4, trans_nm, light)

            cl_array |> push(make_color(color_3))
            cl_array |> push(make_color(color_4))
    
            trans_vx_3 = camera_transform * trans_vx_3
            trans_vx_4 = camera_transform * trans_vx_4
    
            vx_array |> push(((camera_perspective * trans_vx_3).xy) / trans_vx_3.z + float2(620., 320.))
            vx_array |> push(((camera_perspective * trans_vx_4).xy) / trans_vx_4.z + float2(620., 320.))

            screen |> draw_triangle_strip(vx_array, tc_array, cl_array)

            vx_array |> clear()
            tc_array |> clear()
            cl_array |> clear()

        invoke() <| $()
            var trans_vx_1 = cylinder_transform * float3(cos_arr[current] * b_radius, 0.    ,
                sin_arr[current] * b_radius)
            var trans_vx_2 = cylinder_transform * float3(cos_arr[current] * b_radius, height,
                sin_arr[current] * b_radius)
    
            let trans_nm_1 = rotate(cylinder_transform, float3(cos_arr[current], 0., sin_arr[current]))
            let trans_nm_2 = rotate(cylinder_transform, float3(cos_arr[current], 0., sin_arr[current]))
    
            tc_array |> push(float2(0., 0.))
            tc_array |> push(float2(0., 0.))
    
            var color_1 = color
            var color_2 = color

            for light in lights
                color_1 += calc_color(trans_vx_1, trans_nm_1, light)
                color_2 += calc_color(trans_vx_2, trans_nm_2, light)
        
            cl_array |> push(make_color(color_1))
            cl_array |> push(make_color(color_2))
    
            trans_vx_1 = camera_transform * trans_vx_1
            trans_vx_2 = camera_transform * trans_vx_2
    
            vx_array |> push(((camera_perspective * trans_vx_1).xy) / trans_vx_1.z + float2(620., 320.))
            vx_array |> push(((camera_perspective * trans_vx_2).xy) / trans_vx_2.z + float2(620., 320.))

        if walls[current] == 1u && walls[nxt_arr[current]] == 0u
            var trans_vx_1 = cylinder_transform * float3(cos_arr[current] * s_radius,     0., sin_arr[current] * s_radius)
            var trans_vx_2 = cylinder_transform * float3(cos_arr[current] * s_radius, height, sin_arr[current] * s_radius)

            let trans_nm = rotate(cylinder_transform, float3(sin_arr[current], 0., -cos_arr[current]))
    
            tc_array |> push(float2(0., 0.))
            tc_array |> push(float2(0., 0.))

            var color_1 = color
            var color_2 = color

            for light in lights
                color_1 += calc_color(trans_vx_1, trans_nm, light)
                color_2 += calc_color(trans_vx_1, trans_nm, light)

            cl_array |> push(make_color(color_1))
            cl_array |> push(make_color(color_2))
    
            trans_vx_1 = camera_transform * trans_vx_1
            trans_vx_2 = camera_transform * trans_vx_2
    
            vx_array |> push(((camera_perspective * trans_vx_1).xy) / trans_vx_1.z + float2(620., 320.))
            vx_array |> push(((camera_perspective * trans_vx_2).xy) / trans_vx_2.z + float2(620., 320.))

            var trans_vx_3 = cylinder_transform * float3(cos_arr[current] * b_radius,     0., sin_arr[current] * b_radius)
            var trans_vx_4 = cylinder_transform * float3(cos_arr[current] * b_radius, height, sin_arr[current] * b_radius)

            tc_array |> push(float2(0., 0.))
            tc_array |> push(float2(0., 0.))

            var color_3 = color
            var color_4 = color

            for light in lights
                color_3 += calc_color(trans_vx_3, trans_nm, light)
                color_4 += calc_color(trans_vx_4, trans_nm, light)

            cl_array |> push(make_color(color_3))
            cl_array |> push(make_color(color_4))
    
            trans_vx_3 = camera_transform * trans_vx_3
            trans_vx_4 = camera_transform * trans_vx_4
    
            vx_array |> push(((camera_perspective * trans_vx_3).xy) / trans_vx_3.z + float2(620., 320.))
            vx_array |> push(((camera_perspective * trans_vx_4).xy) / trans_vx_4.z + float2(620., 320.))

            screen |> draw_triangle_strip(vx_array, tc_array, cl_array)

            vx_array |> clear()
            tc_array |> clear()
            cl_array |> clear()

        current = prv_arr[current]

        if used_arr[current] == 0u
            screen |> draw_triangle_strip(vx_array, tc_array, cl_array)
 
            vx_array |> clear()
            tc_array |> clear()
            cl_array |> clear()


    invoke() <| $()
        let i_1 = current
        let i_2 = nxt_arr[current]

        let v_1 = rotate(cylinder_transform, float3(cos_arr[i_1] * b_radius, 0., sin_arr[i_1] * b_radius))
        let v_2 = rotate(cylinder_transform, float3(cos_arr[i_2] * b_radius, 0., sin_arr[i_2] * b_radius))

        let v_3 = float3(0., 0.,   0.)
        let v_4 = float3(0., 0., -32.)

        let i_d = seg_seg_intersection(v_1.xz, v_2.xz, v_3.xz, v_4.xz)

        var trans_vx_c_1 = cylinder_transform * float3(cos_arr[i_1] * b_radius, 0.,
            sin_arr[i_1] * b_radius)
        var trans_vx_c_2 = cylinder_transform * float3(cos_arr[i_2] * b_radius, 0.,
            sin_arr[i_2] * b_radius)

        let trans_nm_1 = rotate(cylinder_transform, float3(cos_arr[i_1], 0., sin_arr[i_1]))
        let trans_nm_2 = rotate(cylinder_transform, float3(cos_arr[i_2], 0., sin_arr[i_2]))

        var color_1 = color
        var color_2 = color

        for light in lights
            color_1 += calc_color(trans_vx_c_1, trans_nm_1, light)
            color_2 += calc_color(trans_vx_c_2, trans_nm_2, light)

        var trans_vx_c_3 = cylinder_transform * float3(cos_arr[i_1] * b_radius, height,
            sin_arr[i_1] * b_radius)
        var trans_vx_c_4 = cylinder_transform * float3(cos_arr[i_2] * b_radius, height,
            sin_arr[i_2] * b_radius)

        var color_3 = color
        var color_4 = color

        for light in lights
            color_3 += calc_color(trans_vx_c_3, trans_nm_1, light)
            color_4 += calc_color(trans_vx_c_4, trans_nm_2, light)

        cl_array |> push(make_color(color_1 + (color_2 - color_1) * i_d.t))
        cl_array |> push(make_color(color_3 + (color_4 - color_3) * i_d.t))  

        let trans_vx_1 = camera_transform * (float3(i_d.vx.x, 0.    , i_d.vx.y) + cylinder_transform[3])
        let trans_vx_2 = camera_transform * (float3(i_d.vx.x, height, i_d.vx.y) + cylinder_transform[3])

        tc_array |> push(float2(0., 0.))
        tc_array |> push(float2(0., 0.))

        vx_array |> push(((camera_perspective * trans_vx_1).xy) / trans_vx_1.z + float2(620., 320.))
        vx_array |> push(((camera_perspective * trans_vx_2).xy) / trans_vx_2.z + float2(620., 320.))

        if used_arr[current] == 0u
            screen |> draw_triangle_strip(vx_array, tc_array, cl_array)
 
            vx_array |> clear()
            tc_array |> clear()
            cl_array |> clear()

        current = nxt_arr[current]

    screen |> draw_triangle_strip(vx_array, tc_array, cl_array)

def draw_platform_walls(b_radius           : float;
                        s_radius           : float;
                        height             : float;
                        used_arr           : uint[12];
                        walls              : uint[12];
                        color              : float3;
                        segment            : uint ;
                        lights             : array<light_t>;
                        cylinder_transform : float3x4;
                        camera_transform   : float3x4;
                        camera_perspective : float3x4)
    draw_platform_walls_l(b_radius, s_radius, height, used_arr, walls, color, segment, 
                          lights, cylinder_transform,
                          camera_transform, camera_perspective)

    draw_platform_walls_r(b_radius, s_radius, height, used_arr, walls, color, segment, 
                          lights, cylinder_transform,
                          camera_transform, camera_perspective)

def draw_platform_gap(b_radius           : float;
                      s_radius           : float;
                      used_arr           : uint[12];
                      color              : float3;
                      segment            : uint ;
                      lights             : array<light_t>;
                      cylinder_transform : float3x4;
                      camera_transform   : float3x4;
                      camera_perspective : float3x4)
    var vx_array: array<float2>
    var tc_array: array<float2>
    var cl_array: array<uint>

    var current = segment

    for i in range(0, 13)
        var trans_vx_1 = cylinder_transform * float3(cos_arr[current] * b_radius, 0.,
            sin_arr[current] * b_radius)
        var trans_vx_2 = cylinder_transform * float3(cos_arr[current] * s_radius, 0.,
            sin_arr[current] * s_radius)
 
        let trans_nm_1 = rotate(cylinder_transform, float3(0., -1., 0.))
        let trans_nm_2 = rotate(cylinder_transform, float3(0., -1., 0.))
 
        tc_array |> push(float2(0., 0.))
        tc_array |> push(float2(0., 0.))
 
        var color_1 = color
        var color_2 = color

        for light in lights
            color_1 += calc_color(trans_vx_1, trans_nm_1, light)
            color_2 += calc_color(trans_vx_2, trans_nm_2, light)
    
        cl_array |> push(make_color(color_1))
        cl_array |> push(make_color(color_2))
 
        trans_vx_1 = camera_transform * trans_vx_1
        trans_vx_2 = camera_transform * trans_vx_2
 
        vx_array |> push(((camera_perspective * trans_vx_1).xy) / trans_vx_1.z + float2(620., 320.))
        vx_array |> push(((camera_perspective * trans_vx_2).xy) / trans_vx_2.z + float2(620., 320.))

        if used_arr[current] == 0u
            screen |> draw_triangle_strip(vx_array, tc_array, cl_array)

            vx_array |> clear()
            tc_array |> clear()
            cl_array |> clear()

        current = nxt_arr[current]

    screen |> draw_triangle_strip(vx_array, tc_array, cl_array)