/************************************************************************/
/* CPN Tools                                                            */
/* Copyright 2010-2011 AIS Group, Eindhoven University of Technology    */
/*                                                                      */
/* CPN Tools is originally developed by the CPN Group at Aarhus         */
/* University from 2000 to 2010. The main architects behind the tool    */
/* are Kurt Jensen, Soren Christensen, Lars M. Kristensen, and Michael  */
/* Westergaard.  From the autumn of 2010, CPN Tools is transferred to   */
/* the AIS group, Eindhoven University of Technology, The Netherlands.  */
/*                                                                      */
/* This file is part of CPN Tools.                                      */
/*                                                                      */
/* CPN Tools is free software: you can redistribute it and/or modify    */
/* it under the terms of the GNU General Public License as published by */
/* the Free Software Foundation, either version 2 of the License, or    */
/* (at your option) any later version.                                  */
/*                                                                      */
/* CPN Tools is distributed in the hope that it will be useful,         */
/* but WITHOUT ANY WARRANTY; without even the implied warranty of       */
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        */
/* GNU General Public License for more details.                         */
/*                                                                      */
/* You should have received a copy of the GNU General Public License    */
/* along with CPN Tools.  If not, see <http://www.gnu.org/licenses/>.   */
/************************************************************************/
import java.awt.*;

class PhilCanvas extends Canvas {

    DiningPhilosopher controller;
    int deadlocked = 0;

    Image[] imgs = new Image[4];

    private Philosopher[] philosophers;
    
    public PhilCanvas(DiningPhilosopher controller,  Philosopher[] philosophers){

	super();
	
	this.controller=controller;

	this.philosophers=philosophers;

	MediaTracker mt;
	mt=new MediaTracker(this);

        imgs[0]= controller.getImage(controller.getDocumentBase(), "bothspoonsduke.gif");
	mt.addImage(imgs[0],0);

	imgs[1]= controller.getImage(controller.getDocumentBase(), "hungryduke.gif");
	mt.addImage(imgs[1],1);

	imgs[2]= controller.getImage(controller.getDocumentBase(), "rightspoonduke.gif");
	mt.addImage(imgs[2],2);

	imgs[3]= controller.getImage(controller.getDocumentBase(), "leftspoonduke.gif");
	mt.addImage(imgs[3],3);

	try {     
	    mt.waitForID(0);
	    mt.waitForID(1);
	    mt.waitForID(2);
	    mt.waitForID(3);

	} catch (InterruptedException e) {
	    System.out.println("Couldn't load one of the images");
	}

	initPlacing();

    }
    
    public void paint(Graphics g){

	g.setColor(Color.lightGray);
	g.fillRect(0,0,getSize().width,getSize().height);

	if(deadlocked==1){
	    g.setColor(Color.red);
	    g.fillOval(205,85,60,60);
	    g.setColor(Color.black);
	    // g.drawString("DEADLOCKED", 190, 80);
	}

	for (int i=0; i<5;i++){
	    philPaint(g,i);
	}

    }

    public void philPaint(Graphics g, int i){

	g.setColor(Color.lightGray);
	
	if(philosophers[i].state==0){
	    g.fillRect((int)philosophers[i].x,(int)philosophers[i].y,imgs[1].getWidth(this),imgs[1].getHeight(this));
	    g.drawImage(imgs[1], (int)philosophers[i].x, (int)philosophers[i].y, this);
	} else {
	    if(philosophers[i].state==1){
	        g.fillRect((int)philosophers[i].x,(int)philosophers[i].y,imgs[0].getWidth(this),imgs[0].getHeight(this));
	        g.drawImage(imgs[0], (int)philosophers[i].x, (int)philosophers[i].y, this);
	        g.setColor(Color.black);
	        g.drawString("Mmm!", ((int)philosophers[i].x)+8, ((int)philosophers[i].y)+imgs[0].getHeight(this)+13);
	    } else {
	        if(philosophers[i].state==2){
	            g.fillRect((int)philosophers[i].x,(int)philosophers[i].y,imgs[3].getWidth(this),imgs[3].getHeight(this));
                    g.drawImage(imgs[3], (int)philosophers[i].x, (int)philosophers[i].y, this);
                } else {
	            g.fillRect((int)philosophers[i].x,(int)philosophers[i].y,imgs[2].getWidth(this),imgs[2].getHeight(this));
	            g.drawImage(imgs[2], (int)philosophers[i].x,(int)philosophers[i].y, this);   
                }
	    }
   
	}

    }

    public void initPlacing(){

	double x,y;
	double radius = 80.0;
	double radians;

	for (int i=0; i<5;i++){

	    radians = i*(2.0 * Math.PI /(double)5);
            x = Math.sin(radians) * radius + 210.0; 
            y = Math.cos(radians) * radius + 80.0; 
            philosophers[i].x = x;
	    philosophers[i].y = y;

	}

    }

}
