from PIL import Image, ImageDraw
import math

img = Image.new("RGBA", (11000, 8500))
draw = ImageDraw.Draw(img)

#gray circle

def drawCircle(draw, x, y, r, fill):
    draw.ellipse((x-r, y-r, x+r, y+r), fill=fill)

def findIntersection(p0, p1):
    x0, y0, dx0, dy0 = p0
    x1, y1, dx1, dy1 = p1

    """
    x0+dx0*t0 = x1+dx1*t1
    y0+dy0*t0 = y1+dy1*t1

    (x0-x1+dx0*t0)/dx1 = t1
    y0+dy0*t0 = y1+dy1*(x0-x1+dx0*t0)/dx1
    t0 = (y1-y0+dy1*(x0-x1+dx0*t0)/dx1)/dy0
    
    t0 = (y1-y0)/dy0 +dy1*(x0-x1+dx0*t0)/(dx1*dy0)
    t0 = (y1-y0)/dy0 + dy1/(dx1*dy0) * (x0-x1+dx0*t0)
    t0 = (y1-y0)/dy0 + dy1/(dx1*dy0) * (x0-x1) + t0*(dy1*dx0)/(dx1*dy0)
    t0 - t0*(dy1*dx0)/(dx1*dy0) = (y1-y0)/dy0 + dy1/(dx1*dy0) * (x0-x1)
    t0 * (1 - (dy1*dx0)/(dx1*dy0)) = (y1-y0)/dy0 + dy1/(dx1*dy0) * (x0-x1)
    """
    t0 = ((y1-y0)/dy0 + dy1/(dx1*dy0) * (x0-x1)) / (1.0 - (dy1*dx0)/(dx1*dy0)) 

    return x0+dx0*t0, y0+dy0*t0
    
    
    
    
def drawPoly(draw, lines, fill):
    pointOffsets = []
    for line in lines:
        theta0, rad0 = line
        x0 = rad0 * math.cos(theta0)
        y0 = rad0 * math.sin(theta0)

        dx0 = math.cos(theta0 + math.pi / 2.0)
        dy0 = math.sin(theta0 + math.pi / 2.0)
        pointOffsets.append((x0, y0, dx0, dy0))
        
        delta = 4000

        x0_ex_neg = x0 - delta * dx0
        y0_ex_neg = y0 - delta * dy0
        x0_ex_pos = x0 + delta * dx0
        y0_ex_pos = y0 + delta * dy0

        #draw.line((x0_ex_neg, y0_ex_neg, x0_ex_pos, y0_ex_pos), fill=fill, width=10)

    intersections = []
    for i in range(len(pointOffsets)):
        po0 = pointOffsets[i]
        po1 = pointOffsets[(i+1) % len(pointOffsets)]
        intersections.append(findIntersection(po0, po1))

    draw.polygon(intersections, fill=fill)

    
#gray bg    
drawCircle(draw, 4650, 4410, 3847.5, (140, 140, 140))
#green bg
drawCircle(draw, 4455, 4245, 3837.5, (140, 200, 40))

#cloak
cloakLines = [
    (-1.57079632679, -7923.951273),
    (-0.412443728265, 3438.129694),
    (1.37773756037, 4773.374244),
    (0.289588149633, 4303.288148)
    ]
drawPoly(draw, cloakLines, (50, 60, 100))

#head

drawCircle(draw, 4135, 2955, 847, (255, 255, 255))
#hat
hatLines = [
    (-0.833662855003, 1457.76699),
    (-0.289588149633, 2282.918117),
    (1.02672162142, 4088.248764)]
drawPoly(draw, hatLines, (50, 60, 100))

#staff
staffLines = [
    (1.2022295909, 5728.549185),
    (-0.833662855003, 3002.76699),
    (1.25488198174, 6318.657263),
    (-0.289588149633, -1500),
    ]
drawPoly(draw, staffLines, (100, 55, 35))    

#hands
drawCircle(draw, 6410, 4060, 529.5, (255, 255, 255))
drawCircle(draw, 2905, 5350, 520, (255, 255, 255))

#fireball
drawCircle(draw, 8975, 2990, 1521, (240, 40, 40))

del draw
img.save("reconstruct_5x.png")
