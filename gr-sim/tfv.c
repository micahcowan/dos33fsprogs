#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "gr-sim.h"

#include "tfv_sprites.h"
#include "backgrounds.h"

#define COLOR1	0x00
#define COLOR2	0x01
#define MATCH	0x02
#define XX	0x03
#define YY	0x04
#define YADD	0x05
#define LOOP	0x06
#define MEMPTRL	0x07
#define MEMPTRH	0x08

/* stats */
static unsigned char hp=50,max_hp=100;
static unsigned char limit=2;
static unsigned char money=0;
static unsigned char time_hours=0,time_minutes=0;

/* stats */
static int map_x=1,map_y=1;
static int tfv_x=15,tfv_y=15;


static void draw_segment(void) {

	for(ram[LOOP]=0;ram[LOOP]<4;ram[LOOP]++) {
		ram[YY]=ram[YY]+ram[YADD];
		if (ram[XX]==ram[MATCH]) color_equals(ram[COLOR1]*3);
		else color_equals(ram[COLOR1]);
		basic_vlin(10,ram[YY],9+ram[XX]);
		if (ram[XX]==ram[MATCH]) color_equals(ram[COLOR2]*3);
		else color_equals(ram[COLOR2]);
		if (ram[YY]!=34) basic_vlin(ram[YY],34,9+ram[XX]);
		ram[XX]++;
	}
	ram[YADD]=-ram[YADD];
}

static void draw_logo(void) {

	ram[XX]=0;
	ram[YY]=10;
	ram[YADD]=6;
	ram[COLOR1]=1;
	ram[COLOR2]=0;
	draw_segment();
	ram[COLOR2]=4;
	draw_segment();
	ram[COLOR1]=2;
	draw_segment();
	draw_segment();
	draw_segment();
	ram[COLOR2]=0;
	draw_segment();

	grsim_update();
}

static int repeat_until_keypressed(void) {

	int ch;

	while(1) {
		ch=grsim_input();
		if (ch!=0) break;

		usleep(10000);
	}

	return ch;
}

static int select_menu(int x, int y, int num, char **items) {

	int result=0;
	int ch,i;

	while(1) {
		for(i=0;i<num;i++) {
			basic_htab(x);
			basic_vtab(y+i);

			if (i==result) {
				basic_inverse();
				basic_print("--> ");
			}
			else {
				basic_print("    ");
			}

			basic_print(items[i]);
			basic_normal();
			grsim_update();
		}


		ch=repeat_until_keypressed();
		if (ch=='\r') break;
		if (ch==' ') break;
		if (ch==APPLE_RIGHT) result++;
		if (ch==APPLE_DOWN) result++;
		if (ch==APPLE_LEFT) result--;
		if (ch==APPLE_UP) result--;
		if (result>=num) result=num-1;
		if (result<0) result=0;
	}

	return result;
}



static void apple_memset(char *ptr, int value, int length) {

	a=value;
	x=length;
	y=0;

	while(x>0) {
		ptr[y]=a;
		y++;
		x--;
	}
}


static int opening(void) {

	/* VMW splash */

	ram[MATCH]=100;
	draw_logo();

	usleep(200000);

	for(ram[MATCH]=0;ram[MATCH]<30;ram[MATCH]++) {
		draw_logo();
		grsim_update();

		usleep(20000);
	}

	basic_vtab(21);
	basic_htab(9);
	basic_print("A VMW SOFTWARE PRODUCTION");
	grsim_update();

	repeat_until_keypressed();

	return 0;
}

static char *title_menu[]={
	"NEW GAME",
	"LOAD GAME",
	"CREDITS",
};

static int title(void) {

	int result;

	home();

	grsim_unrle(title_rle,0x800);
	gr_copy(0x800,0x400);

	grsim_update();

	result=select_menu(12, 21, 3, title_menu);

	return result;
}

static char nameo[9];


static int name_screen(void) {

	int xx,yy,cursor_x,cursor_y,ch,name_x;
	char tempst[BUFSIZ];

	text();
	home();

	cursor_x=0; cursor_y=0; name_x=0;

	/* Enter your name */
//            1         2         3
//  0123456789012345678901234567890123456789
//00PLEASE ENTER A NAME:
// 1
// 2
// 3            _ _ _ _ _ _ _ _
// 4
// 5            @ A B C D E F G
// 6
// 7            H I J K L M N O
// 8
// 9            P Q R S T U V W
//10
//11            X Y Z [ \ ] ^ _
//12
//13              ! " # $ % & '
//14
//15            ( ) * + , - . /
//16
//17            0 1 2 3 4 5 6 7
//18
//19            8 9 : ' < = > ?
//20
//21               FINISHED
//22
//23
//24
	basic_print("PLEASE ENTER A NAME:");

	apple_memset(nameo,0,9);

	grsim_update();

	while(1) {

		basic_normal();
		basic_htab(12);
		basic_vtab(3);

		for(yy=0;yy<8;yy++) {
			if (yy==name_x) {
				basic_inverse();
				basic_print("+");
				basic_normal();
				basic_print(" ");
			}
			else if (nameo[yy]==0) {
				basic_print("_ ");
			}
			else {
				sprintf(tempst,"%c ",nameo[yy]);
				basic_print(tempst);
			}
		}

		for(yy=0;yy<8;yy++) {
			basic_htab(12);
			basic_vtab(yy*2+6);
			for(xx=0;xx<8;xx++) {
				if (yy<4) sprintf(tempst,"%c ",(yy*8)+xx+64);
				else  sprintf(tempst,"%c ",(yy*8)+xx);

				if ((xx==cursor_x) && (yy==cursor_y)) basic_inverse();
				else basic_normal();

				basic_print(tempst);
			}
		}

		basic_htab(12);
		basic_vtab(22);
		basic_normal();

		if ((cursor_y==8) && (cursor_x<4)) basic_inverse();
		basic_print(" DONE ");
		basic_normal();
		basic_print("   ");
		if ((cursor_y==8) && (cursor_x>=4)) basic_inverse();
		basic_print(" BACK ");

		while(1) {
			ch=grsim_input();

			if (ch==APPLE_UP) { // up
				cursor_y--;
			}

			else if (ch==APPLE_DOWN) { // down
				cursor_y++;
			}

			else if (ch==APPLE_LEFT) { // left
				if (cursor_y==8) cursor_x-=4;
				else cursor_x--;
			}

			else if (ch==APPLE_RIGHT) { // right
				if (cursor_y==8) cursor_x+=4;
				cursor_x++;
			}

			else if (ch=='\r') {
				if (cursor_y==8) {
					if (cursor_x<4) {
						ch=27;
						break;
					}
					else {
						nameo[name_x]=0;
						name_x--;
						if (name_x<0) name_x=0;
						break;
					}
				}

				if (cursor_y<4) nameo[name_x]=(cursor_y*8)+
							cursor_x+64;
				else nameo[name_x]=(cursor_y*8)+cursor_x;
//				printf("Set to %d\n",nameo[name_x]);
				name_x++;
			}

			else if ((ch>32) && (ch<128)) {
				nameo[name_x]=ch;
				name_x++;

			}

			if (name_x>7) name_x=7;

			if (cursor_x<0) {
				cursor_x=7;
				cursor_y--;
			}
			if (cursor_x>7) {
				cursor_x=0;
				cursor_y++;
			}

			if (cursor_y<0) cursor_y=8;
			if (cursor_y>8) cursor_y=0;

			if ((cursor_y==8) && (cursor_x<4)) cursor_x=0;
			else if ((cursor_y==8) && (cursor_x>=4)) cursor_x=4;

			if (ch!=0) break;

			grsim_update();

			usleep(10000);
		}

		if (ch==27) break;
	}
	return 0;
}

static int flying(void) {

	int i;
	unsigned char ch;
	int xx,yy;
	int direction;

	/************************************************/
	/* Flying					*/
	/************************************************/

	gr();
	xx=17;	yy=30;
	color_equals(COLOR_BLACK);

	direction=0;

	color_equals(COLOR_MEDIUMBLUE);

	for(i=0;i<20;i++) {
		hlin(1, 0, 40, i);
	}

	color_equals(COLOR_DARKBLUE);
	for(i=20;i<48;i++) {
		hlin(1, 0, 40, i);
	}

	while(1) {
		ch=grsim_input();

		if ((ch=='q') || (ch==27))  break;
		if ((ch=='i') || (ch==APPLE_UP)) if (yy>20) yy-=2;
		if ((ch=='m') || (ch==APPLE_DOWN)) if (yy<39) yy+=2;
		if ((ch=='j') || (ch==APPLE_LEFT)) {
			direction--;
			if (direction<-1) direction=-1;
		}
		if ((ch=='k') || (ch==APPLE_RIGHT)) {
			direction++;
			if (direction>1) direction=1;
		}

		gr_copy(0x800,0x400);

		if (direction==0) grsim_put_sprite(ship_forward,xx,yy);
		if (direction==-1) grsim_put_sprite(ship_left,xx,yy);
		if (direction==1) grsim_put_sprite(ship_right,xx,yy);

		grsim_update();

		usleep(10000);
	}
	return 0;
}


static void game_over(void) {

	text();
	home();

	/* Make a box around it? */

	basic_htab(15);
	basic_vtab(12);
	basic_print("GAME OVER");

	/* play the GROAN sound? */

	grsim_update();

	repeat_until_keypressed();
}

static void print_help(void) {
	text();
	home();

	basic_htab(1);
	basic_vtab(1);

	basic_print("ARROW KEYS AND WASD MOVE\n");
	basic_print("SPACE BAR ACTION\n");
	basic_print("I INVENTORY\n");
	basic_print("M MAP\n");
	basic_print("Q QUITS\n");
	grsim_update();

	repeat_until_keypressed();

	gr();
}

static void show_map(void) {
	gr();
	home();

	grsim_unrle(worldmap_rle,0x800);
	gr_copy(0x800,0x400);

	color_equals(COLOR_RED);
	basic_plot(8+(map_x*6)+(tfv_x/6),8+(map_y*6)+(tfv_y/6));

	grsim_update();
	repeat_until_keypressed();
}

/*

******************************************
*  DEATER	   *	LEVEL 1          *
******************************************
* INVENTORY        *    STATS            *
******************************************
*		   *	HP:      50      *
*		   *	MAX HP: 100      *
*                  *                     *
*		   *	EXPERIENCE:  0   *
*		   *	NEXT LEVEL: 16   *
*                  *                     *
*		   *    MONEY: $1	 *
*		   *	TIME: 0:00       *
******************************************
Inc level at 4, so 64 levels

*/

static void print_info(void) {
	text();
	home();
	basic_print("INFO");

	grsim_update();

	repeat_until_keypressed();
	gr();
}

/* Do Battle */

/* Battle.
Forest? Grassland? Artic? Ocean?



          1         2         3
0123456789012345678901234567890123456789|
----------------------------------------|
            |            HP      LIMIT  |  -> FIGHT/LIMIT       21
KILLER CRAB | DEATER   128/255    128   |     ZAP               22
            |                           |     REST              23
            |                           |     RUN AWAY          24

Sound effects?

List hits

******    **    ****    ****    **  **  ******    ****  ******  ******  ******
**  **  ****        **      **  **  **  **      **          **  **  **  **  **
**  **    **      ****  ****    ******  ****    ******    **    ******  ******
**  **    **    **          **      **      **  **  **    **    **  **      **
******  ******  ******  ****        **  ****    ******    **    ******      **

*/

static void print_byte(unsigned char value) {
	char temp[4];
	sprintf(temp,"%3d",value);
	temp[3]=0;
	basic_print(temp);
}

/* Enemies: */
/*   Killer Crab, Big Fish, Procrastinon */

static int do_battle(void) {

	int i,ch;

	int enemy_x=2;
	int enemy_hp=20;

	int tfv_x=34;

	home();
	gr();

	basic_htab(1);
	basic_vtab(22);
	basic_normal();
	basic_print("KILLER CRAB");

	basic_htab(27);
	basic_vtab(21);
	basic_print("HP");

	basic_htab(34);
	basic_vtab(21);
	basic_print("LIMIT");

	basic_htab(15);
	basic_vtab(22);
	basic_print("DEATER");

	basic_htab(24);
	basic_vtab(22);
	print_byte(hp);
	basic_print("/");
	print_byte(max_hp);

	basic_htab(34);
	basic_vtab(22);
	basic_inverse();
	for(i=0;i<limit;i++) {
		basic_print(" ");
	}
	basic_normal();
	for(i=limit;i<5;i++) {
		basic_print(" ");
	}

	basic_inverse();
	for(i=21;i<25;i++) {
		basic_vtab(i);
		basic_htab(13);
		basic_print(" ");
	}
	basic_normal();


	while(1) {
		color_equals(COLOR_MEDIUMBLUE);
		for(i=0;i<10;i++) {
			basic_hlin(0,39,i);
		}
		color_equals(COLOR_LIGHTGREEN);
		for(i=10;i<40;i++) {
			basic_hlin(0,39,i);
		}

		grsim_put_sprite(tfv_stand_left,tfv_x,20);
		grsim_put_sprite(tfv_led_sword,tfv_x-5,20);

		grsim_put_sprite(killer_crab,enemy_x,20);

		grsim_update();

		ch=grsim_input();
		if (ch=='q') break;

		usleep(100000);
	}

	return 0;
}

/* In Town */


/* Puzzle Room */
/* Get through office */
/* Have to run away?  What happens if die?  No save game?  Code? */

/* Construct the LED circuit */
/* Zaps through cloud */
/* Susie joins your party */

/* Final Battle */
/* Play music, lightning effects? */
/* TFV only hit for one damage, susie for 100 */




/*
	Map

	0         1          2        3

0     BEACH     ARTIC   AR/\TIC    BELAIR

1     BEACH     LANDING   GR/\ASS   FORREST

2     BEACH     GRASS     COLLEGE   FORREST

3     BEACH     BEACH     BEACH    BEACH

*/

/* Walk through bushes, beach water */
/* Make landing a sprite?  Stand behind things? */

static int load_map_bg(void) {

	int i,temp;

	if ((map_x==1) && (map_y==1)) {
		grsim_unrle(landing_rle,0x800);
		return 0;
	}

	/* Should we make a thick-hlin? twice as fast? */

	/* Sky */
	color_equals(COLOR_MEDIUMBLUE);
	for(i=0;i<10;i++) {
		hlin(1,0,40,i);
	}

	/* beach */
	/*  / */
	/* /  */
	if (map_x==0) {
		for(i=10;i<40;i++) {
			temp=4+(40-i)/8;
			color_equals(COLOR_DARKBLUE);
			hlin(1,0,temp,i);
			color_equals(COLOR_LIGHTBLUE);
			hlin_continue(2);
			color_equals(COLOR_YELLOW);
			hlin_continue(2);
			color_equals(COLOR_DARKGREEN);
			hlin_continue(36-temp);
		}
	}
	else {
		/* Grassland */
		for(i=10;i<40;i+=2) {
			color_equals(COLOR_DARKGREEN);
			hlin_double(1,0,40,i);
		}
	}

//		grsim_put_sprite(tfv_stand_left,tfv_x,20);

	return 0;
}

static int world_map(void) {

	int ch;
	int direction=1;

	/************************************************/
	/* Landed					*/
	/************************************************/

	// TODO:
	//  4x4 grid of island?
	//  proceduraly generated?
	//  can only walk if feet on green/yellow
	//  should features be sprites?

	// rotate when attacked

	gr();

	color_equals(COLOR_BLACK);

	direction=1;
	int odd=0;
	int refresh=1;

	while(1) {

		ch=grsim_input();

		if ((ch=='q') || (ch==27))  break;

		if ((ch=='w') || (ch==APPLE_UP)) {
			tfv_y-=2;
			odd=!odd;
		}
		if ((ch=='s') || (ch==APPLE_DOWN)) {
			tfv_y+=2;
			odd=!odd;
		}
		if ((ch=='a') || (ch==APPLE_LEFT)) {
			if (direction>0) {
				direction=-1;
				odd=0;
			}
			else {
				odd=!odd;
				tfv_x--;
			}
		}
		if ((ch=='d') || (ch==APPLE_RIGHT)) {
			if (direction<0) {
				direction=1;
				odd=0;
			}
			else {
				odd=!odd;
				tfv_x++;
			}
		}

		if (tfv_x>36) {
			map_x++;
			tfv_x=0;
			refresh=1;
		}
		if (tfv_x<0) {
			map_x--;
			tfv_x=35;
			refresh=1;
		}

		if (tfv_y<4) {
			map_y--;
			tfv_y=28;
			refresh=1;
		}

		if (tfv_y>28) {
			map_y++;
			tfv_y=4;
			refresh=1;
		}

		if (ch=='h') print_help();
		if (ch=='b') do_battle();
		if (ch=='i') print_info();
		if (ch=='m') {
			show_map();
			refresh=1;
		}

		if (refresh) {
			load_map_bg();
			refresh=0;
		}

		gr_copy(0x800,0x400);

		if (direction==-1) {
			if (odd) grsim_put_sprite(tfv_walk_left,tfv_x,tfv_y);
			else grsim_put_sprite(tfv_stand_left,tfv_x,tfv_y);
		}
		if (direction==1) {
			if (odd) grsim_put_sprite(tfv_walk_right,tfv_x,tfv_y);
			else grsim_put_sprite(tfv_stand_right,tfv_x,tfv_y);
		}
		grsim_update();

		usleep(10000);
	}

	return 0;
}


int main(int argc, char **argv) {

	int result;

	grsim_init();

	home();
	gr();

	/* Do Opening */
	opening();

	/* Title Screen */
title_loop:
	result=title();
	if (result!=0) goto title_loop;

	/* Get Name */
	name_screen();

	/* Flying */
	flying();

	/* World Map */
	world_map();

	/* Game Over, Man */
	game_over();

	return 0;
}

