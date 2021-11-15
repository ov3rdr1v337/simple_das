require daslib/media

options debugger
require daslib/debug

require lights
require render_primitives

struct camera_t
    transform    : float3x4
    perspective  : float3x4
 
    angle        : float
    pos          : float3

struct cylinder_t
    cur_seg      : uint = 0u
    seg_angle    : uint = 30u
    transform    : float3x4
    angle        : float
    pos          : float3
    radius       : float
    height       : float

struct romb_t
    cur_seg      : uint = 0u
    seg_angle    : uint = 90u
    transform    : float3x4
    angle        : float
    pos          : float3
    radius       : float

struct sphere_t
    cur_seg      : uint = 0u
    seg_angle    : uint = 30u
    transform    : float3x4
    angle        : float
    pos          : float3
    radius       : float

struct platform_t
    cur_seg      : uint = 3u
    seg_angle    : uint = 30u
    transform    : float3x4
    angle        : float
    pos          : float3
    b_radius     : float
    s_radius     : float

var lights_arr : array<light_t>
var camera     : camera_t

var cylinder   : cylinder_t
var sphere     : sphere_t
var romb       : romb_t
var platform   : platform_t

var game_time = 0.
var game_acts = 0u

def create_perspective(var m : float3x4&)
    m[0][0] = 400.
    m[1][1] = 400.

[export]
def initialize()
    set_antialiasing(16)

    identity(camera.perspective)
    identity(camera.transform)
 
    create_perspective(camera.perspective)

    identity(cylinder.transform)
    identity(romb.transform)
    identity(sphere.transform)
    identity(platform.transform)

    sphere.radius = 6.
    sphere.pos = float3(0., +6.5, 40.5)
    sphere.seg_angle = 30u
    sphere.cur_seg = 0u

    apply_transform(sphere)

    cylinder.height = 8.
    cylinder.radius = 8.
    cylinder.pos = float3(0., +14.5, 40.5)
    cylinder.seg_angle = 30u

    apply_transform(cylinder)

    romb.radius = 2.
    romb.pos = float3(0., 5.5, 28.5)
    romb.seg_angle = 90u
    romb.cur_seg = 1u
    apply_transform(romb)

    platform.b_radius = 16.
    platform.s_radius = 8.
    platform.seg_angle = 30u
    platform.cur_seg = 3u
    platform.pos = float3(0., +10.5, 40.5)
    apply_transform(platform)

    var light : light_t

    light.pos = float3(0., -40., 0.)
    light.c_a = 0.2
    light.c_d = 0.8

    light.a_c = float3(0.  , 0.05, 0.1 )
    light.d_c = float3(1., 0.  , 0.)

    lights_arr |> push(light)

    screen <- create_image(2, 2)
    screen |> set_pixel(0, 0, 0x00FFFFFF)

def apply_transform(var camera : camera_t&)
    var rot_mx : float3x4
 
    identity(rot_mx)
 
    rot_mx[0][0] = +1.
    rot_mx[1][1] = +cos(camera.angle * 0.01745329252f)
    rot_mx[1][2] = +sin(camera.angle * 0.01745329252f)
    rot_mx[2][1] = -sin(camera.angle * 0.01745329252f)
    rot_mx[2][2] = +cos(camera.angle * 0.01745329252f)
 
    var trs_mx : float3x4
 
    identity(trs_mx)
 
    trs_mx[3][0] = camera.pos.x
    trs_mx[3][1] = camera.pos.y
    trs_mx[3][2] = camera.pos.z
 
    camera.transform = rot_mx * trs_mx

def apply_transform(var cylinder : cylinder_t&)
    var rot_mx : float3x4
 
    identity(rot_mx)
 
    rot_mx[0][0] = +cos(cylinder.angle * 0.01745329252f)
    rot_mx[0][2] = +sin(cylinder.angle * 0.01745329252f)
    rot_mx[1][1] = +1.
    rot_mx[2][0] = -sin(cylinder.angle * 0.01745329252f)
    rot_mx[2][2] = +cos(cylinder.angle * 0.01745329252f)
 
    var trs_mx : float3x4
 
    identity(trs_mx)
 
    trs_mx[3][0] = cylinder.pos.x
    trs_mx[3][1] = cylinder.pos.y
    trs_mx[3][2] = cylinder.pos.z
 
    cylinder.transform = trs_mx * rot_mx

def apply_transform(var romb : romb_t&)
    var rot_mx : float3x4
 
    identity(rot_mx)
 
    rot_mx[0][0] = +cos(romb.angle * 0.01745329252f)
    rot_mx[0][2] = +sin(romb.angle * 0.01745329252f)
    rot_mx[1][1] = +1.
    rot_mx[2][0] = -sin(romb.angle * 0.01745329252f)
    rot_mx[2][2] = +cos(romb.angle * 0.01745329252f)
 
    var trs_mx : float3x4
 
    identity(trs_mx)
 
    trs_mx[3][0] = romb.pos.x
    trs_mx[3][1] = romb.pos.y
    trs_mx[3][2] = romb.pos.z
 
    romb.transform = trs_mx * rot_mx

def apply_transform(var sphere : sphere_t&)
    var rot_mx : float3x4
 
    identity(rot_mx)
 
    rot_mx[0][0] = +cos(sphere.angle * 0.01745329252f)
    rot_mx[0][2] = +sin(sphere.angle * 0.01745329252f)
    rot_mx[1][1] = +1.
    rot_mx[2][0] = -sin(sphere.angle * 0.01745329252f)
    rot_mx[2][2] = +cos(sphere.angle * 0.01745329252f)
 
    var trs_mx : float3x4
 
    identity(trs_mx)
 
    trs_mx[3][0] = sphere.pos.x
    trs_mx[3][1] = sphere.pos.y
    trs_mx[3][2] = sphere.pos.z
 
    sphere.transform = trs_mx * rot_mx

def apply_transform(var platform : platform_t&)
    var rot_mx : float3x4
 
    identity(rot_mx)
 
    rot_mx[0][0] = +cos(platform.angle * 0.01745329252f)
    rot_mx[0][2] = +sin(platform.angle * 0.01745329252f)
    rot_mx[1][1] = +1.
    rot_mx[2][0] = -sin(platform.angle * 0.01745329252f)
    rot_mx[2][2] = +cos(platform.angle * 0.01745329252f)
 
    var trs_mx : float3x4
 
    identity(trs_mx)
 
    trs_mx[3][0] = platform.pos.x
    trs_mx[3][1] = platform.pos.y
    trs_mx[3][2] = platform.pos.z
 
    platform.transform = trs_mx * rot_mx


def set_started_segment30(var angle : uint&; var cur_seg : uint&)
    if angle == 60u
        cur_seg = prv_arr[cur_seg]
        angle = 30u
        return
 
    if angle == 0u
        cur_seg = nxt_arr[cur_seg]
        angle = 30u
        return

def set_started_segment90(var angle : uint&; var cur_seg : uint&)
    if angle == 180u
        cur_seg = prv4_arr[cur_seg]
        angle = 90u
        return
 
    if angle == 0u
        cur_seg = nxt4_arr[cur_seg]
        angle = 90u
        return
 
def get_started_segment30(angle : uint; cur_seg : uint) : uint
    return angle > 30u ? prv_arr[cur_seg] : cur_seg

def get_started_segment90(angle : uint; cur_seg : uint) : uint
    return angle > 90u ? prv4_arr[cur_seg] : cur_seg

def update(dt : float)
    if get_key(VK_LEFT)
        cylinder.seg_angle += 1u
        cylinder.angle     += 1.
        apply_transform(cylinder)
        set_started_segment30(cylinder.seg_angle, cylinder.cur_seg)

        romb.seg_angle += 1u
        romb.angle     += 1.
        apply_transform(romb)
        set_started_segment90(romb.seg_angle, romb.cur_seg)

        platform.seg_angle += 1u
        platform.angle     += 1.
        apply_transform(platform)
        set_started_segment30(platform.seg_angle, platform.cur_seg)

        sphere.seg_angle += 1u
        sphere.angle     += 1.
        apply_transform(sphere)
        set_started_segment30(sphere.seg_angle, sphere.cur_seg)
    if get_key(VK_RIGHT)
        cylinder.seg_angle -= 1u
        cylinder.angle     -= 1.
        apply_transform(cylinder)
        set_started_segment30(cylinder.seg_angle, cylinder.cur_seg)

        romb.seg_angle -= 1u
        romb.angle     -= 1.
        apply_transform(romb)
        set_started_segment90(romb.seg_angle, romb.cur_seg)

        platform.seg_angle -= 1u
        platform.angle     -= 1.
        apply_transform(platform)
        set_started_segment30(platform.seg_angle, platform.cur_seg)

        sphere.seg_angle -= 1u
        sphere.angle     -= 1.
        apply_transform(sphere)
        set_started_segment30(sphere.seg_angle, sphere.cur_seg)
    if get_key(VK_UP)
        camera.pos.z -= 1.
        apply_transform(camera)
    if get_key(VK_DOWN)
        camera.pos.z  += 1.
        apply_transform(camera)
    if get_key(VK_Q)
        camera.angle += 1.
        apply_transform(camera)
    if get_key(VK_E)
        camera.angle -= 1.
        apply_transform(camera)

[export]
def act(dt : float)
    game_time += dt
    var cnt = uint(game_time * 64.) + 1u
    for i in range(game_acts, cnt)
        update(0.015625)
        game_acts++


[export]
def draw()

    // text_out(100, 80, "PD {int(get_started_segment90(romb.seg_angle, romb.cur_seg))}", 0xFFFFFFFF)
    draw_cylinder(cylinder.radius, cylinder.height, float3(0.1, 0.6, 0.2) * 0.6,
                  get_started_segment30(cylinder.seg_angle, cylinder.cur_seg), 
                  lights_arr, cylinder.transform,
                  camera.transform, camera.perspective)

    var used_arr = [[uint[] 1u; 1u; 1u; 1u; 1u; 1u;
                            1u; 1u; 1u; 1u; 1u; 1u ]]

    draw_platform_walls(platform.b_radius, platform.s_radius, 2., used_arr, used_arr, float3(0.1, 0.2, 0.6),
                        get_started_segment30(platform.seg_angle, platform.cur_seg), lights_arr, platform.transform,
                        camera.transform, camera.perspective)

    var walls = [[uint[] 1u; 0u; 1u; 0u; 1u; 0u;
                         1u; 0u; 1u; 0u; 1u; 0u ]]

    draw_platform_walls(platform.b_radius, platform.s_radius, 2., walls, used_arr, float3(0.1, 0.6, 0.2),
                        get_started_segment30(platform.seg_angle, platform.cur_seg), lights_arr, platform.transform,
                        camera.transform, camera.perspective)


    draw_platform_gap(platform.b_radius, platform.s_radius, used_arr, float3(0.1, 0.2, 0.6), 
                      get_started_segment30(platform.seg_angle, platform.cur_seg),
                      lights_arr, platform.transform,
                      camera.transform, camera.perspective)

    draw_platform_gap(platform.b_radius, platform.s_radius, walls, float3(0.1, 0.6, 0.2), 
                      get_started_segment30(platform.seg_angle, platform.cur_seg),
                      lights_arr, platform.transform,
                      camera.transform, camera.perspective)

    draw_sphere(sphere.radius, float3(0.1, 0.2, 0.6), get_started_segment30(sphere.seg_angle, sphere.cur_seg), 
                lights_arr, sphere.transform,
                camera.transform, camera.perspective)

    draw_romb(romb.radius, float3(0.1, 0.6, 0.2) * 0.6, get_started_segment90(romb.seg_angle, romb.cur_seg), 
              lights_arr, romb.transform,
              camera.transform, camera.perspective)

    return