/**
* Costume method
* Copyleft (c) 2014-2019
* v 1.9.9
* processing 3.5.3.269
* Rope Library 0.8.4.29
* @author @stanlepunk
* @see https://github.com/StanLepunK/Rope_framework
*/

import rope.costume.R_Circle;
import rope.costume.R_Bezier;
import rope.costume.R_Star;
import rope.costume.R_Virus;
import rope.costume.R_Line2D;


/**
* line2D
* v 0.2.0
* 2019-2019
*/
void line2D(vec2 p1, vec2 p2, boolean aa_is, boolean update_pix_is, PGraphics pg) {
  line2D(p1.x(), p1.y(), p2.x(), p2.y(), aa_is, update_pix_is, pg);
}

void line2D(vec2 p1, vec2 p2, boolean aa_is , boolean update_pix_is) {
  line2D(p1.x(), p1.y(), p2.x(), p2.y(), aa_is, update_pix_is, g);
}

void line2D(float x1, float y1, float x2, float y2, boolean aa_is, boolean update_pix_is) {
  line2D(x1, y1, x2, y2, aa_is, update_pix_is, g);
}

void line2D(float x1, float y1, float x2, float y2, boolean aa_is, boolean update_pix_is, PGraphics pg) {
  if(!aa_is) {
    draw_line_no_aa(x1, y1, x2, y2, update_pix_is, pg);
  } else {
  	
  	vec2 src = vec2(x1,y1);
  	vec2 dst = vec2(x2,y2);
    float angle = src.angle(dst);
  	float range = 0.005;
    
    boolean x_is = false;
    if(x1 == x2) x_is = true;
    boolean y_is = false;
    if(y1 == y2) y_is = true;
    boolean align_is = false;
    if(x_is || y_is) align_is = true;

    boolean n_is = false;
    if(angle > r.NORTH - range && angle < r.NORTH + range) n_is = true;
    boolean ne_is = false;
    if(angle > r.NORTH_EAST - range && angle < r.NORTH_EAST + range) ne_is = true;
    boolean e_is = false;
    if(angle > r.EAST - range && angle < r.EAST + range) e_is = true;
    boolean se_is = false;
    if(angle > r.SOUTH_EAST - range && angle < r.SOUTH_EAST + range) se_is = true;
    boolean s_is = false;
    if(angle > r.SOUTH - range && angle < r.SOUTH + range) s_is = true;
    boolean sw_is = false;
    if(angle > r.SOUTH_WEST - range && angle < r.SOUTH_WEST + range) sw_is = true;
    boolean w_is = false;
    if(angle > r.WEST - range && angle < r.WEST + range) w_is = true;
    boolean nw_is = false;
    if(angle > r.NORTH_WEST - range && angle < r.NORTH_WEST + range) nw_is = true;

    // resolve
    boolean exception_is = false;
    if(align_is || n_is || ne_is || e_is || se_is || s_is || sw_is || w_is || nw_is) {
      exception_is = true;
    }

  	if(exception_is) {
  		draw_line_no_aa(x1, y1, x2, y2, update_pix_is, pg);
  	} else {
  		draw_line_aa_wu(x1, y1, x2, y2, update_pix_is, pg);
  	}	
  } 
}







/**
* line2D echo loop
* 2019-2019
* v 0.0.2
* This method return the rest of line after this one meet an other line from a list of walls
*/
R_Line2D line2D_echo_loop(R_Line2D line, R_Line2D [] walls, ArrayList<R_Line2D> list, float offset, float angle_echo, boolean go_return_is) {
  R_Line2D rest = new R_Line2D(this);
  int count_limit = 0;
  if(go_return_is) offset = -1 *offset;

  for(R_Line2D wall : walls) {
    count_limit ++;
    // add line.a() like exception because this one touch previous border
    vec2 node = wall.intersection(line, line.a());
    if(node != null) {
      R_Line2D line2D = new R_Line2D(this,line.a(),node);
      rest = new R_Line2D(this,node,line.b());

      //offset
      float angle_offset = wall.angle();
      if(offset < 0 ) {
        if(list.size()%2 == 0 && go_return_is) {
          angle_offset += PI;
        } else {

        }
      } else {
        if(list.size()%2 == 0 && go_return_is) {
          angle_offset -= PI;
        } else {

        }
      }

      vec2 displacement = projection(angle_offset,offset);
      rest.offset(displacement);
      
      // classic go and return
      if(go_return_is) {
        rest.angle(rest.angle() +PI);
      // go on a same way
      } else {
        float angle = rest.angle() -PI;

        vec2 temp = projection(angle, width+height).add(rest.a());
        R_Line2D max_line = new R_Line2D(this,rest.b(),temp);
        for(R_Line2D limit_opp : walls) {
          vec2 opp_node = limit_opp.intersection(max_line,vec2(node).add(displacement));
          if(opp_node != null) {
            rest.angle(rest.angle());
            vec2 swap = opp_node.sub(node).sub(displacement);
            rest.offset(swap);
            break;
          }
        }
      }
      // add result
      list.add(line2D);
      break;
    } else {
      // to add the last segment of the main line, 
      // because this one cannot match with any borders or limits
      // before add the last element, it's necessary to check all segments borders
      if(count_limit == walls.length) {
        list.add(line);
      } 
    }
  }
  //angle echo effect
  if(angle_echo != 0) {
    rest.angle(rest.angle()+angle_echo);
  }
  return rest;
}































/**
* line AA Xiaolin Wu based on alogrithm of Bresenham
* v 0.2.3
* 2019-2019
* @see https://github.com/jdarc/wulines/blob/master/src/Painter.java
* @see https://rosettacode.org/wiki/Xiaolin_Wu%27s_line_algorithm#Java
* @see https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
* @see https://en.wikipedia.org/wiki/Xiaolin_Wu%27s_line_algorithm
*/

// integer part of x
int ipart(double x) {
  return (int)x;
}

// fractional part of x
double fpart(double x) {
  return x - Math.floor(x);
}

// fractional part of x
double rfpart(double x) {
  return 1.0 - fpart(x);
}
 
void draw_line_aa_wu(double x_0, double y_0, double x_1, double y_1, boolean update_pixel, PGraphics pg) {
  if(update_pixel) pg.loadPixels();
  // check angle before the steeping
  vec2 src = vec2((float)x_0,(float)y_0);
  vec2 dst = vec2((float)x_1,(float)y_1);
  float angle = src.angle(dst);

  boolean steep = Math.abs(y_1 - y_0) > Math.abs(x_1 - x_0);
  double buffer;
  if (steep) {
    buffer = y_0;
    y_0 = x_0; 
    x_0 = buffer;
    buffer = y_1; 
    y_1 = x_1; 
    x_1 = buffer;
  }
  
  if (x_0 > x_1) {
    buffer = x_0; 
    x_0 = x_1; 
    x_1 = buffer;
    buffer = y_0; 
    y_0 = y_1; 
    y_1 = buffer;
  }

  double dx = x_1 - x_0;
  double dy = y_1 - y_0;
  double gradient = dy / dx;
  

  // MISC
  // here method use to set the design who the Xaolin Wu line, is not the algorithm himself
  // colour part
  float radius = dist(vec2((float)x_0,(float)y_0),vec2((float)x_1,(float)y_1));
  float step_palette = radius;
  int [] col = {pg.strokeColor};
  int colour = col[0];
  float alpha_ratio = 1.0;
  if(get_palette() != null) {
    col = get_palette();
    step_palette = radius / col.length;  
  }

  // BACK to ALGORITHM
  // handle first endpoint
  int x_end_0 = (int)Math.round(x_0);
  double y_end_0 = y_0 + gradient * (x_end_0 - x_0);
  double x_gap_0 = rfpart(x_0 + 0.5);
  double stop_intery = y_end_0;  

  // handle second endpoint
  int x_end_1 = (int)Math.round(x_1);
  double start_intery = y_1 + gradient * (x_end_1 - x_1);
  double x_gap_1 = fpart(x_1 + 0.5);


  colour = colour_wu_line_pixel(stop_intery, start_intery, stop_intery, radius, step_palette, col, angle);
  alpha_ratio = alpha_ratio_wu_line_pixel(stop_intery, start_intery, stop_intery, radius, step_palette, angle);
  pixel_wu(steep, x_end_0, stop_intery, x_gap_0, colour, alpha_ratio, pg);

  colour = colour_wu_line_pixel(start_intery, start_intery, stop_intery, radius, step_palette, col, angle);
  alpha_ratio = alpha_ratio_wu_line_pixel(start_intery, start_intery, stop_intery, radius, step_palette, angle);
  pixel_wu(steep, x_end_1, start_intery, x_gap_1, colour, alpha_ratio, pg);

  // main loop
  // first y-intersection for the main loop
  yes_steep = 0;
  no_steep = 0;
  double intery = y_end_0 + gradient;
  for (int x = x_end_0 ; x <= x_end_1 ; x++) {
    double gap = 1.0;
    colour = colour_wu_line_pixel(intery, start_intery, stop_intery, radius, step_palette, col, angle);
    alpha_ratio = alpha_ratio_wu_line_pixel(intery, start_intery, stop_intery, radius, step_palette, angle);
    pixel_wu(steep, x, intery, gap, colour, alpha_ratio, pg);
    intery += gradient;
  }
  if(update_pixel) pg.updatePixels();
}

int yes_steep = 0;
int no_steep = 0;
void pixel_wu(boolean steep, int x, double intery, double gap, int colour, float alpha_ratio, PGraphics pg) {
  double alpha = 0;

  if (steep) {
    alpha = rfpart(intery) * gap;
    plot(int(ipart(intery) + 0), x, colour, (float)alpha *alpha_ratio, pg);
    alpha = fpart(intery) * gap;
    plot(int(ipart(intery) + 1), x, colour, (float)alpha *alpha_ratio, pg);
  } else {
    alpha = rfpart(intery) * gap;
    plot(x, int(ipart(intery) + 0), colour, (float)alpha *alpha_ratio, pg);
    alpha = fpart(intery) * gap;
    plot(x, int(ipart(intery) + 1), colour, (float)alpha *alpha_ratio, pg);
  }
}


float alpha_ratio_wu_line_pixel(double intery, double start, double stop, float radius, float step, float angle) {
	float index = index_wu(intery, start, stop, radius, angle);
  float alpha = 1.0;
  
  if(alpha_entry_line2D != 1.0 || alpha_exit_line2D != 1.0) {
  	if(alpha_entry_line2D < 0) alpha_entry_line2D = 0;
  	if(alpha_entry_line2D > 1) alpha_entry_line2D = 1;
  	if(alpha_exit_line2D < 0) alpha_exit_line2D = 0;
  	if(alpha_exit_line2D > 1) alpha_exit_line2D = 1;
  	alpha = map(index,0,radius,alpha_entry_line2D,alpha_exit_line2D);
  }
  return alpha;
}



int colour_wu_line_pixel(double intery, double start, double stop, float radius, float step, int [] colour_list, float angle) {
  float index = index_wu(intery, start, stop, radius, angle);
  return colour_line2D((int)index,step,colour_list);
}


float index_wu(double intery, double start, double stop, float radius, float angle) {
  if(start == stop) {
    start -= 1;
  }
  float index = 1;
  boolean inverse_is = false;
  
  if((angle > r.NORTH_EAST && angle < r.SOUTH_WEST)) {
    inverse_is = true;
  }


  if(inverse_is) {
    index = map((float)intery,(float)stop,(float)start,0,radius);
  } else {
    index = map((float)intery,(float)start,(float)stop,0,radius);
  }
  
  if(index < 0) index = 0;
  if(index > radius) index = radius;
  return index;
}




/**
* NO AA
*/
void draw_line_no_aa(float x0, float y0, float x1, float y1, boolean update_pixel, PGraphics pg) {
  vec2 src = vec2(x0,y0);
  vec2 dst = vec2(x1,y1);
  float dir = src.angle(dst);
  float radius = dist(src,dst);
  
  // manage colour list
  float step_palette = radius;
  int [] col = {pg.strokeColor};
  if(get_palette() != null) {
    col = get_palette();
    step_palette = radius / col.length;  
  }

  
  boolean alpha_is = false;
  float [] alpha = {1.};
  if(alpha_entry_line2D != 1.0 || alpha_exit_line2D != 1.0) {
  	alpha_is = true;
  	alpha = new float[ceil(radius)];
  	if(alpha_entry_line2D < 0) alpha_entry_line2D = 0;
  	if(alpha_entry_line2D > 1) alpha_entry_line2D = 1;
  	if(alpha_exit_line2D < 0) alpha_exit_line2D = 0;
  	if(alpha_exit_line2D > 1) alpha_exit_line2D = 1;

  	for(int i = 0 ; i < alpha.length; i++) {
  		alpha[i] = map(i,0,alpha.length,alpha_entry_line2D,alpha_exit_line2D);
  	}
  }


  if(update_pixel) pg.loadPixels();
  for(int i = 0 ; i < radius ; i++) {
    float x = cos(dir);
    float y = sin(dir);
    float from_center = i;
    vec2 path = vec2(x,y).mult(from_center).add(src);
    path.constrain(vec2(0),vec2(width,height));
    int px = (int)path.x();
    int py = (int)path.y();

    // update pixel
    int colour = colour_line2D(i,step_palette,col);
    if(alpha_is) {
    	plot(px, py, colour, alpha[i], pg);
    } else {
    	plot(px, py, colour, 1.0, pg);
    }
    
  }
   if(update_pixel) pg.updatePixels();
}






// util line2D
int colour_line2D(int index, float step, int [] colour_list) {
  int target = 0;
  if(tempo() == null) {
    target = floor((float)index/step);
  } else {
    target = get_tempo_pos(index);
  }
  target = target%colour_list.length;
  return colour_list[target];
}


float alpha_entry_line2D = 1.0;
float alpha_exit_line2D =1.0;
void alpha_line2D(float entry, float exit) {
	alpha_entry_line2D = entry;
	alpha_exit_line2D = exit;
}











































/**
Costume selection in shape catalogue
*/
void costume(float x, float y, float sx, float sy, Object data) {
	costume(vec2(x,y),vec2(sx,sy),data,null);
}

void costume(float x, float y, float sx, float sy, Object data, PGraphics pg) {
	costume(vec2(x,y),vec2(sx,sy),data,pg);
}

//
void costume(float x, float y, float z, float sx, float sy, Object data) {
	costume(vec3(x,y,z),vec2(sx,sy),data,null);
}

void costume(float x, float y, float z, float sx, float sy, Object data, PGraphics pg) {
	costume(vec3(x,y,z),vec2(sx,sy),data,pg);
}

// 
void costume(float x, float y, float z, float sx, float sy, float sz, Object data) {
	costume(vec3(x,y,z),vec3(sx,sy,sz),data,null);
}

void costume(float x, float y, float z, float sx, float sy, float sz, Object data, PGraphics pg) {
	costume(vec3(x,y,z),vec3(sx,sy,sz),data,pg);
}

//
void costume(vec pos, int size_int, Object data) {
	costume(pos,size_int,data,null);
}

void costume(vec pos, int size_int, Object data, PGraphics pg) {
	int which_costume = 0;
	String sentence = null;
	vec3 rotation = vec3();
	vec3 size = vec3(size_int);
	if(data instanceof Costume) {
		costume_impl(pos,size,rotation,(Costume)data,pg);
	} else if(data instanceof Integer) {
		which_costume = (int)data;
		costume_management(pos,size,rotation,which_costume,null,pg);
	} else if(data instanceof String) {
		sentence = (String)data;
		which_costume = MAX_INT;
		costume_management(pos,size,rotation,which_costume,sentence,pg);
	}
}

//
void costume(vec pos, vec size, Object data) {
	costume(pos,size,data,null);
}

void costume(vec pos, vec size, Object data, PGraphics pg) {
	int which_costume = 0;
	String sentence = null;
	vec3 rotation = vec3();
	if(data instanceof Costume) {
		costume_impl(pos,size,rotation,(Costume)data,pg);
	} else if(data instanceof Integer) {
		which_costume = (int)data;
		costume_management(pos,size,rotation,which_costume,null,pg);
	} else if(data instanceof String) {
		sentence = (String)data;
		which_costume = MAX_INT;
		costume_management(pos,size,rotation,which_costume,sentence,pg);
	}
}

//
// for this method we use class Float to be sure of method signature
void costume(vec pos, vec size, Float rot, Object data) {
	costume(pos,size,rot,data,null);
}

// for this method we use class Float to be sure of method signature
void costume(vec pos, vec size, Float rot, Object data, PGraphics pg) {
	int which_costume = 0;
	String sentence = null;
	vec3 rotation = vec3(0,0,rot);
	if(data instanceof Costume) {
		costume_impl(pos,size,rotation,(Costume)data,pg);
	} else if(data instanceof Integer) {
		which_costume = (int)data;
		costume_management(pos,size,rotation,which_costume,null,pg);
	} else if(data instanceof String) {
		sentence = (String)data;
		which_costume = MAX_INT;
		costume_management(pos,size,rotation,which_costume,sentence,pg);
	}
}

// 
void costume(vec pos, vec size, vec rotation, Object data) {
	costume(pos,size,rotation,data,null);
}


void costume(vec pos, vec size, vec rotation, Object data, PGraphics pg) {
	int which_costume = 0;
	String sentence = null;
	if(data instanceof Costume) {
		costume_impl(pos,size,rotation,(Costume)data,pg);
	} else if(data instanceof Integer) {
		which_costume = (int)data;
		costume_management(pos,size,rotation,which_costume,null,pg);
	} else if(data instanceof String) {
		sentence = (String)data;
		which_costume = MAX_INT;
		costume_management(pos,size,rotation,which_costume,sentence,pg);
	}
}









/**
managing costume rope method
*/
void costume_management(vec pos, vec size, vec rotation, int which_costume, String sentence, PGraphics pg) {
  vec3 pos_final = vec3(0) ;
  vec3 size_final = vec3(1) ;
	if((pos instanceof vec2 || pos instanceof vec3) 
			&& (size instanceof vec2 || size instanceof vec3)
			&& (rotation instanceof vec2 || rotation instanceof vec3)) {
		// pos
		if(pos instanceof vec2) {
			vec2 temp_pos = (vec2)pos;
			pos_final.set(temp_pos.x, temp_pos.y, 0);
		} else if(pos instanceof vec3) {
			vec3 temp_pos = (vec3)pos;
			pos_final.set(temp_pos);
		}
		//size
		if(size instanceof vec2) {
			vec2 temp_size = (vec2)size;
			size_final.set(temp_size.x, temp_size.y, 1);
		} else if(size instanceof vec3) {
			vec3 temp_size = (vec3)size;
			size_final.set(temp_size);
		}
		//send
		if(sentence == null ) {
			costume_impl(pos_final,size_final,rotation,which_costume,pg);
		} else {
			costume_impl(pos_final,size_final,rotation,sentence,pg);
		}		
	} else {
		printErrTempo(180,"vec pos or vec size if not an instanceof vec2 or vec3, it's not possible to process costume_rope()");
	}
}






/**
MAIN METHOD 
String COSTUME
v 0.4.0
Change the method for method with 
case and which_costume
and 
break
*/
void costume_impl(vec3 pos, vec3 size, vec rot, String sentence, PGraphics pg) {
	if(rot.x != 0) costume_rotate_x();
	if(rot.y != 0) costume_rotate_y();
	if(rot.z != 0) costume_rotate_z();
	push(pg);
	translate(pos,pg);
	costume_rotate(rot,pg);
	textSize(size.x());
  text(sentence,0,0,pg);
	pop(pg);
}

/**
method to pass costume to class costume
*/
Costume costume_rope_buffer;
void costume_impl(vec3 pos, vec3 size, vec rot, int which_costume, PGraphics pg) {
	if(costume_rope_buffer == null) {
		costume_rope_buffer = new Costume(this,which_costume);
	} else {
		costume_rope_buffer.set_type(which_costume);
	}
	costume_rope_buffer.pass_graphic(pg);
	costume_rope_buffer.show(pos,size,rot);
}


void costume_impl(vec pos, vec size, vec rot, Costume costume, PGraphics pg) {
	costume.pass_graphic(pg);
	costume.show(vec3(pos),vec3(size),rot);
}





















































/**
ASPECT ROPE 2016-2019
v 0.1.4
*/
Costume aspect_rope;
void aspect_is(boolean fill_is, boolean stroke_is, boolean alpha_is) {
	if(aspect_rope == null) aspect_rope = new Costume(this);
	aspect_rope.aspect_is(fill_is,stroke_is,alpha_is);
	fill_rope_is = aspect_rope.fill_is();
	stroke_rope_is = aspect_rope.stroke_is();
	alpha_rope_is = aspect_rope.alpha_is();
}


void init_bool_aspect() {
	if(aspect_rope == null) {
		aspect_rope = new Costume(this);
	}
	aspect_rope.aspect_is(true,true,true);
}

void aspect(int fill, int stroke, float thickness) {
	PGraphics other = null;
	aspect(fill,stroke,thickness,other);
}
void aspect(int fill, int stroke, float thickness, PGraphics other) {
	if(aspect_rope == null) aspect_rope = new Costume(this);
	aspect_is(aspect_rope.fill_is(),aspect_rope.stroke_is(),aspect_rope.alpha_is());
	aspect_rope.pass_graphic(other);
	aspect_rope.aspect(fill,stroke,thickness);
}

void aspect(vec fill, vec stroke, float thickness) {
	PGraphics other = null;
	aspect(fill,stroke,thickness,other);
}

void aspect(vec fill, vec stroke, float thickness, PGraphics other) {
	if(aspect_rope == null) aspect_rope = new Costume(this);
	aspect_is(aspect_rope.fill_is(),aspect_rope.stroke_is(),aspect_rope.alpha_is());
	aspect_rope.pass_graphic(other);
	aspect_rope.aspect(fill,stroke,thickness);
}


/**
* Deprecated part
*/
@Deprecated
void aspect(int fill, int stroke, float thickness, Costume costume) {
	PGraphics other = null;
	aspect(fill,stroke,thickness,costume,other);
}

@Deprecated
void aspect(int fill, int stroke, float thickness, Costume costume, PGraphics other) {
	if(aspect_rope == null) aspect_rope = new Costume(this);
	aspect_is(aspect_rope.fill_is(),aspect_rope.stroke_is(),aspect_rope.alpha_is());
	aspect_rope.pass_graphic(other);
	aspect_rope.aspect(fill,stroke,thickness,costume.get_type());
}

@Deprecated
void aspect(int fill, int stroke, float thickness, int costume) {
	PGraphics other = null;
	aspect(fill,stroke,thickness,costume,other);
}

@Deprecated
void aspect(int fill, int stroke, float thickness, int costume, PGraphics other) {
	if(aspect_rope == null) aspect_rope = new Costume(this);
	aspect_is(aspect_rope.fill_is(),aspect_rope.stroke_is(),aspect_rope.alpha_is());
	aspect_rope.pass_graphic(other);
	aspect_rope.aspect(fill,stroke,thickness,costume);
}

@Deprecated
void aspect(vec fill, vec stroke, float thickness, Costume costume) {
	PGraphics other = null;
	aspect(fill,stroke,thickness,costume,other);
}

@Deprecated
void aspect(vec fill, vec stroke, float thickness, Costume costume, PGraphics other) {
	if(aspect_rope == null) aspect_rope = new Costume(this);
	aspect_is(aspect_rope.fill_is(),aspect_rope.stroke_is(),aspect_rope.alpha_is());
	aspect_rope.pass_graphic(other);
	aspect_rope.aspect(fill,stroke,thickness,costume.get_type());
}

@Deprecated
void aspect(vec fill, vec stroke, float thickness, int costume) {
	PGraphics other = null;
	aspect(fill,stroke,thickness,costume,other);
}

@Deprecated
void aspect(vec fill, vec stroke, float thickness, int costume, PGraphics other) {
	if(aspect_rope == null) aspect_rope = new Costume(this);
	aspect_is(aspect_rope.fill_is(),aspect_rope.stroke_is(),aspect_rope.alpha_is());
	aspect_rope.pass_graphic(other);
	aspect_rope.aspect(fill,stroke,thickness,costume);
}







int get_fill_rope() {
	if(aspect_rope != null) {
		return aspect_rope.get_fill();
	} else {
		return color(g.colorModeX);
	}
}

int get_stroke_rope() {
	if(aspect_rope != null) {
		return aspect_rope.get_stroke();
	} else {
		return color(0);
	}
}

float get_thickness_rope() {
	if(aspect_rope != null) {
		return aspect_rope.get_thickness();
	} else {
		return 1.;
	}
}













































/**
COSTUME
v 0.0.4
*/
/**
simple text 
v 0.0.2
*/

void costume_text(String arg) {
	costume_rope_buffer.set_text(arg);
}



/**
* rotate behavior
* v 0.3.0
*/
boolean costume_rot_x;
boolean costume_rot_y;
boolean costume_rot_z;

void costume_rotate_x() {
	costume_rot_x = true;
}

void costume_rotate_y() {
	costume_rot_y = true;
}

void costume_rotate_z() {
	costume_rot_z = true;
}

void costume_rotate(vec rotate) {
	costume_rotate(rotate,null);
}

void costume_rotate(vec rotate, PGraphics other) {
  if(get_renderer() == P3D) {
  	if(costume_rot_x && rotate.x() != 0) {
			rotateX(rotate.x(),other);
			costume_rot_x = false;
		}
		if(costume_rot_y && rotate.y() != 0) {
			rotateY(rotate.y(),other);
			costume_rot_y = false;
		}
		if(costume_rot_z && rotate.z() != 0) {
			rotateZ(rotate.z(),other);
			costume_rot_z = false;
		}
  } else {
  	if(rotate.x() == 0 && rotate.y() == 0 && rotate.z() != 0 && costume_rot_x) {
  		rotate(rotate.z(),other);
  		costume_rot_x = false;
  	} 
  	if(costume_rot_x && rotate.x() != 0) {
  		rotateX(rotate.x(),other);
  		costume_rot_x = false;
  	}
  	if(costume_rot_y && rotate.y() != 0) {
  		rotateY(rotate.y(),other);
  		costume_rot_y = false;
  	}
  }
}


/**
ratio size costume
*/
float ratio_costume_size = 1;
void set_ratio_costume_size(float ratio) {
	ratio_costume_size = ratio;
}




























/**
add pic 
v 0.0.1
*/
ArrayList <Costume_pic> costume_pic_list = new ArrayList<Costume_pic>() ;

void load_costume_pic(String path) {
	if(path.endsWith("png") || path.endsWith("PNG") || path.endsWith("svg") || path.endsWith("SVG")) {
		int new_ID = costume_pic_list.size() * (-1) ;
		new_ID -= 1 ;
		Costume_pic c = new Costume_pic(this, path, new_ID) ;
		costume_pic_list.add(c) ; ;
		println("ID pic:", new_ID) ;
	}
}














































/**
house method
*/
House house_costume_rope;
void house(vec3 size) {
	house(size,null);
}
void house(vec3 size, PGraphics other) {
	if(house_costume_rope != null) {
		house_costume_rope.size(size);
		house_costume_rope.pass_graphic(other);
		// house_costume_rope.show(g);
		house_costume_rope.show();
	} else {
		//house_costume_rope = new House();
		house_costume_rope = new House(this);
	}
}





/**
* flower method
* 2019-2019
* v 0.0.3
*/
R_Circle flower_costume_rope;
void flower(vec pos, int diam, int petals_num) {
	flower(pos,diam,petals_num,null);
}
void flower(vec pos, int diam, int petals_num, PGraphics other) {
	if(flower_costume_rope == null || flower_costume_rope.get_summits() != petals_num) {
		flower_costume_rope = new R_Circle(this,petals_num);
	} else {
		flower_costume_rope.pos(pos);
		flower_costume_rope.size(diam);
		flower_costume_rope.pass_graphic(other);
		flower_costume_rope.show();
		// if(petals_num < 3) petals_num = 3;
	}
}

void flower_wind(vec2 petal_left, float strength_left, vec2 petal_right, float strength_right) {
	if(flower_costume_rope != null) {
		for(R_Bezier b : flower_costume_rope.get_bezier()) {
	    vec2 trouble = vec2().sin_wave(frameCount,petal_left.x(),petal_left.y()).mult(strength_left);
	    b.set_a(trouble);
	    trouble = vec2().cos_wave(frameCount,petal_right.x(),petal_right.y()).mult(strength_right);
	    b.set_b(trouble);
	  }
	}
}


void flower_static(vec2 petal_left, float strength_left, vec2 petal_right, float strength_right) {
	if(flower_costume_rope != null) {
		for(R_Bezier b : flower_costume_rope.get_bezier()) {
	    vec2 petal_show = vec2(petal_left.x(),petal_left.y()).mult(strength_left);
	    b.set_a(petal_show);
	    petal_show = vec2(petal_right.x(),petal_right.y()).mult(strength_right);
	    b.set_b(petal_show);
	  }
	}
}










































/**
ANNEXE COSTUME
SHAPE CATALOGUE
*/
/**
STAR
*/

R_Star star_costume_rope;
void star(vec position, vec size) {
	star(position,size,null);
}

void star(vec position, vec size, PGraphics other) {
	if(star_costume_rope != null) {
		star_costume_rope.pos(position);
		star_costume_rope.size(size);
		star_costume_rope.pass_graphic(other);
		star_costume_rope.show();
	} else {
		star_costume_rope = new R_Star(this);
	}
}


void star_3D_is(boolean is_3D) {
	if(star_costume_rope != null) {
		star_costume_rope.is_3D(is_3D);
	} else {
		star_costume_rope = new R_Star(this);
	}
}


void star_summits(int summits) {
	if(star_costume_rope != null) {
		star_costume_rope.set_summits(summits);
	} else {
		star_costume_rope = new R_Star(this);
	}
}

void star_angle(float angle) {
	if(star_costume_rope != null) {
		star_costume_rope.angle_x(angle);
	} else {
		star_costume_rope = new R_Star(this);
	}
}

void star_ratio(float... ratio) {
	if(star_costume_rope != null) {
		star_costume_rope.set_ratio(ratio);
	} else {
		star_costume_rope = new R_Star(this);
	}
}








 






















/**
* CROSS
* v 0.2.0
*/
void cross_rect(ivec2 pos, int thickness, int radius) { 
	cross_rect(pos,thickness,radius,null);
}

void cross_rect(ivec2 pos, int thickness, int radius, PGraphics other) {
	float h = radius;
	float w = thickness/3;

  // verticale one
	vec2 size = vec2(w,h);
	vec2 pos_temp = vec2(pos.x, pos.y -floor(size.y/2) +(w/2));
	pos_temp.sub(w/2);
	rect(pos_temp,size,other);
	
	// horizontal one
	size.set(h,w);
	pos_temp.set(pos.x-floor(size.x/2) +(w/2),pos.y);
	pos_temp.sub(w/2);
	rect(pos_temp,size,other);
}

void cross_box_2(vec2 size) {
	cross_box_2(size,null);
}

void cross_box_2(vec2 size, PGraphics other) {
	float scale_cross = size.sum() *.5;
	float small_part = scale_cross *ratio_costume_size *.3;

	box(size.x,small_part,small_part,other);
	box(small_part,size.y,small_part,other);
}

void cross_box_3(vec3 size) {
	cross_box_3(size,null);
}

void cross_box_3(vec3 size, PGraphics other) {
	float scale_cross = size.sum() *.3;
	float small_part = scale_cross *ratio_costume_size *.3;
   
	box(size.x,small_part,small_part,other);
	box(small_part,size.y,small_part,other);
	box(small_part,small_part,size.z,other);
}
















/**
VIRUS
2015-2018
v 0.2.2
*/
void virus(vec pos, vec size) {
	int close = -1 ;
	float angle = 0 ;
	virus(pos,size,angle,close) ;
}

void virus(vec pos, vec size, float angle) {
	int close = -1;
	virus(pos,size,angle,close);
}


// main method
R_Virus virus_costume_rope;
boolean make_virus = true ;
void virus(vec pos, vec size, float angle, int close) {
	if(make_virus) {
		virus_costume_rope = new R_Virus(this);
		make_virus = false ;
	}

	if(virus_costume_rope.get_mutation() > 0 && frameCount%virus_costume_rope.get_mutation() == 0) {
		virus_costume_rope.reset() ;
	}
  virus_costume_rope.angle_x(angle) ;
	virus_costume_rope.pos(pos) ;
	virus_costume_rope.size(size) ;
	virus_costume_rope.show() ;	
}

void virus_mutation(int mutation) {
	if(virus_costume_rope != null && mutation != 0 && mutation != virus_costume_rope.get_mutation()) {
		virus_costume_rope.set_mutation(abs(mutation));
	}
}

void virus_num(int num) {
	if(virus_costume_rope != null && num != 0 && num != virus_costume_rope.get_summits()) {
		virus_costume_rope.set_summits(abs(num));
	}
}

void virus_node(int node) {
	if(virus_costume_rope != null && node != 0 && node != virus_costume_rope.get_node()) {
		virus_costume_rope.set_node(abs(node));
	}
}




























/**
* COSTUME INFO
* 2016-2019
* v 0.2.1
*/
// get costume
int get_costume(int target) {
	costume_list() ;
	if(target >= 0 && target < costume_dict.size()) {
		return costume_dict.get(target).get(0) ;
	} else {
		System.err.println("Your target is out from the list") ;
		return 0 ;
	}
}

// return size of the arrayList costume
int costumes_size() {
	costume_list() ;
	return costume_dict.size() ;
}




Info_int_dict costume_dict = new Info_int_dict();
boolean list_costume_is_built = false;
int ref_size_pic = -1;
// String costume_text_rope = null;
boolean fill_rope_is = true;
boolean stroke_rope_is = true;
boolean alpha_rope_is = true;
void costume_list() {
	if(!list_costume_is_built) {
		/* 
		* add(name, code, renderer, type)
		* code: int constante to access directly
		* render: 2 = 2D ; 3 = 3D ;
		* type : 0 = shape ; 1 = bitmap ; 2 = svg  ; 3 = shape with just stroke component ; 4 = text
		*/
		costume_dict.add("NULL",r.NULL,0,0);

		costume_dict.add("PIXEL",PIXEL,2,1);

		costume_dict.add("POINT",POINT,2,0);
		costume_dict.add("ELLIPSE",ELLIPSE,2,0);
		costume_dict.add("RECT",RECT,2,0);
		costume_dict.add("LINE",LINE,2,0);

		costume_dict.add("TRIANGLE",TRIANGLE,2,0);
		costume_dict.add("SQUARE",SQUARE,2,0);
		costume_dict.add("PENTAGON",PENTAGON,2,0);
		costume_dict.add("HEXAGON",HEXAGON,2,0);
		costume_dict.add("HEPTAGON",HEPTAGON,2,0);
		costume_dict.add("OCTOGON",OCTOGON,2,0);
		costume_dict.add("NONAGON",NONAGON,2,0);
		costume_dict.add("DECAGON",DECAGON,2,0);
		costume_dict.add("HENDECAGON",HENDECAGON,2,0);
		costume_dict.add("DODECAGON",DODECAGON,2,0);

		//costume_dict.add("TEXT_ROPE",TEXT_ROPE,2,4);
    
    costume_dict.add("CROSS_RECT",CROSS_RECT,2,0);
		costume_dict.add("CROSS_BOX_2",CROSS_BOX_2,3,0);
		costume_dict.add("CROSS_BOX_3",CROSS_BOX_3,3,0);

		costume_dict.add("SPHERE_LOW",SPHERE_LOW,3,0);
		costume_dict.add("SPHERE_MEDIUM",SPHERE_MEDIUM,3,0);
		costume_dict.add("SPHERE_HIGH",SPHERE_HIGH,3,0);
		costume_dict.add("SPHERE",SPHERE,3,0);
		costume_dict.add("TETRAHEDRON",TETRAHEDRON,3,0);
		costume_dict.add("BOX",BOX,3,0);

		costume_dict.add("STAR",STAR,2,3);
		costume_dict.add("STAR_3D",STAR_3D,2,3);

		costume_dict.add("FLOWER",FLOWER,2,3);

		costume_dict.add("HOUSE",HOUSE,3,0);

		costume_dict.add("VIRUS",VIRUS,3,0);

		list_costume_is_built = true;
	}

  // add costume from your SVG or PNG
	if(ref_size_pic != costume_pic_list.size()) {
		for(Costume_pic c : costume_pic_list) {
			costume_dict.add(c.name, c.get_id(), 3, c.type) ;
		}
		ref_size_pic = costume_pic_list.size() ;
	}
}


// print list costume
void print_list_costume() {
	if(!list_costume_is_built) {
		costume_list() ;
	}
  println("Costume have " + costume_dict.size() + " costumes.") ;
	if(list_costume_is_built) {
		for(int i = 0 ; i < costume_dict.size() ; i++) {
			String type = "" ;
			if(costume_dict.get(i).get(2) == 0 ) type = "shape" ;
			else if(costume_dict.get(i).get(2) == 1 ) type = "bitmap" ;
			else if(costume_dict.get(i).get(2) == 2 ) type = "scalable vector graphics" ;
			else if(costume_dict.get(i).get(2) == 3 ) type = "shape with no fill component" ;
			println("[ Rank:", i, "][ ID:",costume_dict.get(i).get(0), "][ Name:", costume_dict.get(i).get_name(), "][ Renderer:", costume_dict.get(i).get(1)+"D ][ Picture:", type, "]") ;
		}
	}
}
