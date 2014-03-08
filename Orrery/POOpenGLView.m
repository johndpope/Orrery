//
//  POOpenGLView.m
//  Orrery
//
//  Created by Jesse Wolfe on 3/6/14.
//  Copyright (c) 2014 Jesse Wolfe. All rights reserved.
//

#import "POOpenGLView.h"
#import "POPlanet.h"
#import "POMars.h"
#import "POVenus.h"
#import "POMercury.h"


#import <OpenGL/glu.h>


static void drawAnObject ()
{
    glColor3f(1.0f, 0.85f, 0.35f);
    glBegin(GL_TRIANGLES);
    {
        glVertex3f(  0.0,  0.6, 0.0);
        glVertex3f( -0.2, -0.3, 0.0);
        glVertex3f(  0.2, -0.3 ,0.0);
    }
    glEnd();
}

static void yellow ()
{
    glColor3f(1.0f, 0.85f, 0.35f);
}

static void sun ()
{
    GLfloat color[] = { 1.0, 0.85, 0.35, 1.0 };
    glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, color);
    yellow();

    GLUquadric *quad = gluNewQuadric();
    gluSphere(quad, 0.2, 100, 100);
    
    GLfloat black[] = { 0.0, 0.0, 0.0, 1.0 };
    glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, black);
}

@implementation POOpenGLView

// J2000.0 is January 1, 2000, 11:58:55.816 UTC

- (void) drawSolarSystem
{
    static int tilt = 0;
    double epoch = [[NSDate dateWithString:@"2000-01-01 11:58:56 +0000"] timeIntervalSince1970];
    double nowish = [[datePicker dateValue] timeIntervalSince1970];
    
    double elapsed_seconds = (nowish - epoch);
    double elapsed_days = elapsed_seconds / 86400;
    double elapsed_years = elapsed_days / 365.25;
    
    POPlanet *mercury = [POMercury new];
    POPlanet *venus = [POVenus new];
    POPlanet *earth = [POPlanet new];
    POPlanet *mars = [POMars new];
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glShadeModel (GL_FLAT);

    gluLookAt (0.0, 0.0, 0.0, 0.0, 0.0, -100.0, 0.0, 1.0, 0.0);
    glScalef (1, 1, 1);

    glPushMatrix();
    
    glTranslated(0,0,-80);

    int target_tilt = 0;
    if( [[[popup selectedItem] title] isEqualToString:@"Side"] ){
        target_tilt = 90;
    }
    if(target_tilt > tilt){
        tilt += 5;
    }
    if(target_tilt < tilt){
        tilt -= 5;
    }
    glRotated(tilt,1,0,0);
    


    glBegin(GL_QUAD_STRIP);
    {
        glDisable(GL_LIGHTING);
        sun();
        glEnable(GL_LIGHTING);
        GLfloat light_position[] = { 0.0, 0.0, 0.0, 1.0 };
        glLightfv(GL_LIGHT0, GL_POSITION, light_position);
        

        [mercury drawForTime:elapsed_years];
        [venus drawForTime:elapsed_years];
        [earth drawForTime:elapsed_years];
        [mars drawForTime:elapsed_years];
    }
    

    glEnd();
    glPopMatrix();
    

}



- (void)reshape
{
    int w = [self bounds].size.width;
    int h = [self bounds].size.height;
    int max = w; if(h > max){max = h;}
    int min = w; if(h < min){min = h;}
    
    double zoom = 1.5;
    
    glViewport (0, 0, (GLsizei) w, (GLsizei) h);
    
    glEnable(GL_AUTO_NORMAL);
    glEnable(GL_NORMALIZE);
    glEnable(GL_COLOR_MATERIAL);

    glShadeModel (GL_SMOOTH);
    

    glEnable(GL_DEPTH_TEST);
    glDepthFunc (GL_LESS);

    
    // this is the interesting part: center the drawing in the window, expand to fit shorter edge
    glMatrixMode (GL_PROJECTION);
    glLoadIdentity ();

    glOrtho((GLdouble) -zoom*w/min, (GLdouble) zoom*w/min, (GLdouble)-zoom*h/min, (GLdouble) zoom*h/min, 1, 100);
    glMatrixMode (GL_MODELVIEW);
    glLoadIdentity ();


    //glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    

}

- (void)drawRect:(NSRect)dirtyRect
{
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self drawSolarSystem];
    glFlush();
}

@end
