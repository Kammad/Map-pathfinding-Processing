import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.providers.Microsoft;
import de.fhpotsdam.unfolding.marker.*;
import de.fhpotsdam.unfolding.marker.AbstractMarker;
import de.fhpotsdam.unfolding.data.*;
import java.util.List;
import java.util.Queue;
import java.util.LinkedList;
import processing.serial.*;
import processing.opengl.*;

UnfoldingMap map;
Location paphosLocation = new Location(53.6f, -113.3f);
float maxPanningDistance = 30;

Button Pointer_button;      // Buttons
Button Cancel_button;
Button Remove_button;
Button Combine_button;
Button Destination_button;
Button Location_button;
Button Pathfinder_button;

String Mouse_state = "Free movement"; 
int window_width = 1600;
int window_height = 900;
float root_2 = 1.41421356237;
Serial serial;
String received;

ArrayList<Marker> Sel_markers;        //Global Marker arrays
ArrayList<Grid_marker> Grid_markers;
ArrayList<Grid_marker> Path_markers;
ArrayList<SimplePolygonMarker> Obstacle_markers;
ArrayList<SimplePolygonMarker> Obst_found;
ArrayList<Location> Obst_points;
ArrayList<SimpleLinesMarker> Line_markers;
Boolean Current_present;
Boolean Destination_present;
Redzone_marker mouse_marker;

Grid_marker start;
Grid_marker finish;
Grid_marker check_m;

public static float round2(float number, int scale) { //rounding function, used widely
  int pow = 10;
  for (int i = 1; i < scale; i++)
    pow *= 10;
  float tmp = number * pow;
  return ( (float) ( (int) ((tmp - (int) tmp) >= 0.5f ? tmp + 1 : tmp) ) ) / pow;
}

/*
public void getYourLocation(){
  
  if (serial.available() > 0) {
    received = serial.readStringUntil('\n');
    
    if (received != null) {    
      println(received);
      fill(255);
      text(received, 100, 400);
    }
  }
}
*/

void setup() {
  printArray(Serial.list());
  //String port = Serial.list()[1];
  //serial = new Serial(this, port, 9600);
  
  size(window_width, window_height);
  smooth();

  map = new UnfoldingMap(this, new Microsoft.AerialProvider());
  MapUtils.createDefaultEventDispatcher(this, map);

  map.zoomAndPanTo(paphosLocation, 14);
  map.setTweening(true);

  map.setPanningRestriction(paphosLocation, maxPanningDistance);
  map.setZoomRange(10, 19);

  Sel_markers = new ArrayList<Marker>();
  Grid_markers = new ArrayList<Grid_marker>();
  Path_markers = new ArrayList<Grid_marker>();
  Obstacle_markers = new ArrayList<SimplePolygonMarker>();
  Obst_found = new ArrayList<SimplePolygonMarker>();
  Obst_points = new ArrayList<Location>();
  Line_markers = new ArrayList<SimpleLinesMarker>();

  Pointer_button = new Button("New pointer", 800, window_height - 80, 175, 50, 200, 200, 200);  //Button options
  Cancel_button = new Button("Cancel", 600, window_height - 80, 175, 50, 190, 40, 50);
  Remove_button = new Button("Remove", 40, window_height - 80, 175, 50, 190, 40, 50);
  Combine_button = new Button("Combine", 240, window_height - 80, 175, 50, 50, 40, 218);
  Destination_button = new Button("Set destination", 600, window_height - 80, 175, 50, 30, 200, 50);
  Location_button = new Button("Set current location", 600, window_height - 150, 175, 50, 50, 40, 218);
  Pathfinder_button = new Button("Build path", window_width - 215, window_height - 80, 175, 50, 50, 218, 40);
}

void draw() {
  //getYourLocation();
  
  map.draw();
  
  Location location = map.getLocation(mouseX, mouseY);
  fill(255);
  text(location.getLat() + ", " + location.getLon(), mouseX, mouseY);



  Pointer_button.Draw();  // draw the button in the window

    if (Mouse_state == "Marker location") {
    Mouse_state = "Free movement";
    print("Marker placed at ");
    println(location);

    mouse_marker = new Redzone_marker(location);
    map.addMarkers(mouse_marker);
    mouse_marker.setColor(color(40, 218, 40, 250));
    mouse_marker.setStrokeColor(color(0, 178, 0, 100));
    mouse_marker.setStrokeWeight(4);
  }
  if (Mouse_state != "Free movement") {
    Cancel_button.Draw();
  }
  if (Sel_markers.size() > 0) {
    Remove_button.Draw();
  }
  if (Sel_markers.size() == 1) {
    Destination_button.Draw();
    Location_button.Draw();
  }
  if (Sel_markers.size() > 2) {
    Combine_button.Draw();
  }
  Pathfinder_button.Draw();
}


void mouseMoved() {                    //Button highlighting
  if (Pointer_button.MouseIsOver()) {
    Pointer_button.r = 230;
    Pointer_button.g = 230;
    Pointer_button.b = 230;
  } else {
    Pointer_button.r = 200;
    Pointer_button.g = 200;
    Pointer_button.b = 200;
  }
  if (Cancel_button.MouseIsOver()) {
    Cancel_button.r = 230;
    Cancel_button.g = 70;
    Cancel_button.b = 80;
  } else {
    Cancel_button.r = 190;
    Cancel_button.g = 40;
    Cancel_button.b = 50;
  }
  if (Remove_button.MouseIsOver()) {
    Remove_button.r = 230;
    Remove_button.g = 70;
    Remove_button.b = 80;
  } else {
    Remove_button.r = 190;
    Remove_button.g = 40;
    Remove_button.b = 50;
  }
  if (Combine_button.MouseIsOver()) {
    Combine_button.r = 80;
    Combine_button.g = 70;
    Combine_button.b = 248;
  } else {
    Combine_button.r = 50;
    Combine_button.g = 40;
    Combine_button.b = 218;
  }
  if (Destination_button.MouseIsOver()) {
    Destination_button.r = 60;
    Destination_button.g = 230;
    Destination_button.b = 80;
  } else {
    Destination_button.r = 30;
    Destination_button.g = 200;
    Destination_button.b = 50;
  }
  if (Location_button.MouseIsOver()) {
    Location_button.r = 80;
    Location_button.g = 70;
    Location_button.b = 248;
  } else {
    Location_button.r = 50;
    Location_button.g = 40;
    Location_button.b = 218;
  }
  if (Pathfinder_button.MouseIsOver()) {
    Pathfinder_button.r = 80;
    Pathfinder_button.g = 70;
    Pathfinder_button.b = 248;
  } else {
    Pathfinder_button.r = 50;
    Pathfinder_button.g = 40;
    Pathfinder_button.b = 218;
  }
}


void mousePressed()                   // mouse button clicked
{
  if (Pointer_button.MouseIsOver()) {
    println("Add new marker: ");
    Mouse_state = "Marker placement";
    println(Mouse_state);
    Pointer_button.r = 130;
    Pointer_button.g = 130;
    Pointer_button.b = 130;
  }
  if (Pointer_button.MouseIsOver() == false && Mouse_state == "Marker placement") {
    Mouse_state = "Marker location";
    Pointer_button.r = 218;
    Pointer_button.g = 218;
    Pointer_button.b = 218;
  }
  if (Cancel_button.MouseIsOver()) {
    println("Action canceled");
    Mouse_state = "Free movement";
  } else if (Cancel_button.MouseIsOver() == false) {
  } else if (Remove_button.MouseIsOver() && Sel_markers.size() > 0) {  //Remove selected markers
    Rmv();
  }
  if (Sel_markers.size() > 2) {  //Combine markers into no-go red zone
    if (Combine_button.MouseIsOver()) {
      Cmb();
    }
  } else if (Location_button.MouseIsOver() && Sel_markers.size() == 1) {  //Set location marker
    Cnt();
  } else if (Destination_button.MouseIsOver() && Sel_markers.size() == 1) {  //Set destination marker
    Dst();
  } else if (Pathfinder_button.MouseIsOver() && Current_present && Destination_present) {   //Creates a straight path of vertices on a grid from current position to destination. If there are any red zones on the path, then it creates a grid with borders 3 pins away from the most N/S/W/E points of the obstacles and builds an A* path through them, avoiding red zones.
    for (int i = Line_markers.size () - 1; i>=0; i--) {
      map.getMarkerManager(0).removeMarker(Line_markers.get(i));
      Line_markers.remove(i);
    }
    Pfb(0, 0);
  }

  if (map.getFirstHitMarker(mouseX, mouseY) != null) {        //Check marker class
    println(map.getFirstHitMarker(mouseX, mouseY).getClass());
  }
  Marker hitMarker = map.getFirstHitMarker(mouseX, mouseY);
  if (hitMarker != null && hitMarker.getClass() == Redzone_marker.class) { //Only for Redzone markers
    // Select current marker or deselect it if already selected
    if (hitMarker.isSelected() == true) {
      hitMarker.setSelected(false);
      println("Marker deselected");
      for (int i = Sel_markers.size ()-1; i >= 0; i--) {
        Marker markerCheck = Sel_markers.get(i);
        if (markerCheck.getLocation() == hitMarker.getLocation()) {
          Sel_markers.remove(i);
        }
      }
    } else {
      hitMarker.setSelected(true);
      println("Marker selected");
      Sel_markers.add(hitMarker);
    }
  } else {
    // Deselect all other markers
    for (Marker marker : map.getMarkers ()) {
      marker.setSelected(false);
    }
    for (int i = Sel_markers.size ()-1; i >= 0; i--) {
      Sel_markers.remove(i);
      print("Marker deselected ");
      println(i);
    }
    println("Selection cleared");
  }
}

void Rmv() {
  for (Marker marker : map.getMarkers ()) {
    marker.setSelected(false);
  }
  for (int i = Sel_markers.size ()-1; i >= 0; i--) {
    map.getMarkerManager(0).removeMarker(Sel_markers.get(i));
    Sel_markers.remove(i);
    print("Markers removed ");
    println(i);
  }
  println("Selection cleared");
}

void Cmb() {
  SimplePolygonMarker redzoneSelected = new SimplePolygonMarker();
  for (int i = Sel_markers.size ()-1; i >= 0; i--) {
    Marker markerSel = Sel_markers.get(i);
    Location markerSelLoc = markerSel.getLocation();
    redzoneSelected.addLocation(markerSelLoc.getLat(), markerSelLoc.getLon());
    map.getMarkerManager(0).removeMarker(Sel_markers.get(i));
    Sel_markers.remove(i);
  }
  SimplePolygonMarker obstacleMarker = new SimplePolygonMarker();
  obstacleMarker.addLocations(redzoneSelected.getLocations());
  Obstacle_markers.add(obstacleMarker);
  map.addMarkers(obstacleMarker);
  obstacleMarker.setColor(color(230, 28, 40, 100));
  obstacleMarker.setStrokeColor(color(230, 28, 40, 200));
  obstacleMarker.setStrokeWeight(3);
  println("Multimarker Created");
}

void Cnt() {
  for (int i = Grid_markers.size ()-1; i >= 0; i--) {
    if (Grid_markers.get(i).getState() == "Current") {
      map.getMarkerManager(0).removeMarker(Grid_markers.get(i));
      Grid_markers.remove(i);
      println("Current position changed");
    }
  }
  for (int i = Sel_markers.size ()-1; i >= 0; i--) {
    Location cur_lock = Sel_markers.get(i).getLocation();
    float cur_lat = cur_lock.getLat();
    float cur_lon = cur_lock.getLon();
    float cur_lock_lat = round2(cur_lat, 4);
    float cur_lock_lon = round2(cur_lon, 4);
    Location grid_location = new Location(cur_lock_lat, cur_lock_lon);
    println(grid_location);
    Grid_marker Cur_lock_marker = new Grid_marker(grid_location);
    Cur_lock_marker.setState("Current");
    map.addMarker(Cur_lock_marker);
    println(Cur_lock_marker.getState());
    Grid_markers.add(Cur_lock_marker);
    Current_present = true;
  }
  for (int i = Sel_markers.size ()-1; i >= 0; i--) {
    map.getMarkerManager(0).removeMarker(Sel_markers.get(i));
    Sel_markers.remove(i);
  }
}

void Dst() {
  for (int i = Grid_markers.size ()-1; i >= 0; i--) {
    if (Grid_markers.get(i).getState() == "Destination") {
      map.getMarkerManager(0).removeMarker(Grid_markers.get(i));
      Grid_markers.remove(i);
      println("Destination changed");
    }
  }
  for (int i = Sel_markers.size ()-1; i >= 0; i--) {
    Location dest_lock = Sel_markers.get(i).getLocation();
    float dest_lat = dest_lock.getLat();
    float dest_lon = dest_lock.getLon();
    float dest_lock_lat = round2(dest_lat, 4);
    float dest_lock_lon = round2(dest_lon, 4);
    Location grid_location = new Location(dest_lock_lat, dest_lock_lon);
    println(grid_location);
    Grid_marker Dest_lock_marker = new Grid_marker(grid_location);
    Dest_lock_marker.setState("Destination");
    map.addMarker(Dest_lock_marker);
    println(Dest_lock_marker.getState());
    Grid_markers.add(Dest_lock_marker);
    Destination_present = true;
  }
  for (int i = Sel_markers.size ()-1; i >= 0; i--) {
    map.getMarkerManager(0).removeMarker(Sel_markers.get(i));
    Sel_markers.remove(i);
  }
  println(Grid_markers);
}

//Main pathfinding function
void Pfb(int iter, int obstacles_found) {
  for (int i = Grid_markers.size ()-1; i >=0; i--) {
    if (Grid_markers.get(i).getState() == "Current") {
      start = Grid_markers.get(i);
      check_m = new Grid_marker(start.getLocation());
      check_m.setState("Check");
      Grid_markers.add(check_m);
      print("Current ");
      println(check_m.getLocation());
    } else if (Grid_markers.get(i).getState() == "Destination") {
      finish = Grid_markers.get(i);
      print("Destination ");
      println(finish.getLocation());
    } else {
      map.getMarkerManager(0).removeMarker(Grid_markers.get(i));
      Grid_markers.remove(i);
    }
  }

  boolean path_found = false;
  boolean path_built = false;
  float maxLat;
  float maxLon;
  float minLat;
  float minLon;
  double convertionConstant = 0.0111;
  float step = 0.0001;
  double dist = start.getDistanceTo(finish.getLocation());

  //Straight path check

  for (int i = Path_markers.size ()-1; i>=0; i--) {
    map.getMarkerManager(0).removeMarker(check_m);
    map.getMarkerManager(0).removeMarker(Path_markers.get(i));
    Path_markers.remove(i);
  }

  Grid_marker path_marker = new Grid_marker(start.getLocation());
  Path_markers.add(path_marker);

  while (check_m.getDistanceTo (finish.getLocation ()) > convertionConstant) {
    double lat_dif = finish.getLocation().getLat() - check_m.getLocation().getLat();
    double lon_dif = finish.getLocation().getLon() - check_m.getLocation().getLon();   
    double angle_rad = Math.atan(lat_dif/lon_dif);
    if (lat_dif > 0 && lon_dif < 0) {
      angle_rad = -angle_rad;
    }
    if (lat_dif < 0 && lon_dif > 0) {
      angle_rad = -angle_rad;
    }
    double lat_step = Math.sin(angle_rad)*step;
    float fa = (float)lat_step;
    double lon_step = Math.cos(angle_rad)*step;
    float fo = (float)lon_step;
    if (lat_dif < 0) {
      fa = -fa;
    }
    if (lon_dif < 0) {
      fo = -fo;
    }
    Location new_loc = new Location(check_m.getLocation().getLat() + fa, check_m.getLocation().getLon() + fo);
    check_m.setLocation(new_loc);
    map.addMarkers(check_m);
    path_marker = new Grid_marker(check_m.getLocation());
    path_marker.setState("Path");
    Path_markers.add(path_marker);
  }

  for (int m = Path_markers.size ()-1; m>=0; m--) {
    map.addMarkers(Path_markers.get(m));
  }
  for (int oc = Obstacle_markers.size ()-1; oc >= 0; oc--) {
    for (int i = Path_markers.size ()-1; i >= 0; i--) {
      if (Obstacle_markers.get(oc).isInsideByLocation(Path_markers.get(i).getLocation()) && !(Obst_found.contains(Obstacle_markers.get(oc)))) {
        Obst_found.add(Obstacle_markers.get(oc));
        obstacles_found++;
      }
    }
  }


  map.getMarkerManager(0).removeMarker(check_m);


  if (obstacles_found > 0) {
    for (int i = Path_markers.size ()-1; i>=0; i--) {
      map.getMarkerManager(0).removeMarker(Path_markers.get(i));
      Path_markers.remove(i);
    }
    for (int k = Obst_found.size ()-1; k>=0; k--) {
      for (int l = Obst_found.get (k).getLocations().size()-1; l>=0; l--) {
        Obst_points.add(Obst_found.get(k).getLocation(l));
      }
    }
    Obst_points.add(start.getLocation());
    Obst_points.add(finish.getLocation());
    
    //finding ending points for a grid
    maxLat = Obst_points.get(0).getLat();
    minLat = maxLat;
    maxLon = Obst_points.get(0).getLon();
    minLon = maxLon;
    for  (int i = Obst_points.size ()-1; i>=0; i--) {
      if (maxLat < Obst_points.get(i).getLat()) {
        maxLat = Obst_points.get(i).getLat();
      }
      if (minLat > Obst_points.get(i).getLat()) {
        minLat = Obst_points.get(i).getLat();
      }
      if (maxLon < Obst_points.get(i).getLon()) {
        maxLon = Obst_points.get(i).getLon();
      }
      if (minLon > Obst_points.get(i).getLon()) {
        minLon = Obst_points.get(i).getLon();
      }
    }

    maxLat = round2(maxLat, 4) + 0.0005;
    minLat = round2(minLat, 4) - 0.0005;
    maxLon = round2(maxLon, 4) + 0.0005;
    minLon = round2(minLon, 4) - 0.0005;
    float grid_height = round2((maxLat - minLat)/step, 0);
    float grid_width = round2((maxLon - minLon)/step, 0);
    int grid_h = (int) grid_height;
    int grid_w = (int) grid_width;
    boolean all_scanned = false;
    println(grid_width, grid_height);

    //Creating a grid
    for (int gh = grid_h-1; gh>=0; gh--) {
      for (int gw = grid_w-1; gw>=0; gw--) {
        Location gl = new Location(maxLat - (step*gh), maxLon - (step*gw));
        Grid_marker grider = new Grid_marker(gl);
        grider.setState("Undiscovered");
        grider.setX(gw);
        grider.setY(gh);
        map.addMarkers(grider);
        if (round2(grider.getLocation().getLat(), 4) == round2(start.getLocation().getLat(), 4) && round2(grider.getLocation().getLon(), 4) == round2(start.getLocation().getLon(), 4)) {
          start.setX(grider.getX());
          start.setY(grider.getY());
          map.getMarkerManager(0).removeMarker(grider);
        } else if (round2(grider.getLocation().getLat(), 4) == round2(finish.getLocation().getLat(), 4) && round2(grider.getLocation().getLon(), 4) == round2(finish.getLocation().getLon(), 4)) {
          finish.setX(grider.getX());
          finish.setY(grider.getY());
          map.getMarkerManager(0).removeMarker(grider);
        } else {
          Grid_markers.add(grider);
        }
      }
    }

    println(Grid_markers.size());
    for (int i = Grid_markers.size ()-1; i>=0; i--) {
      for (int k = Obst_found.size ()-1; k>=0; k--) {
        if (Obst_found.get(k).isInsideByLocation(Grid_markers.get(i).getLocation())) {
          Grid_markers.get(i).setState("Blocked");
          for (int l = 7; l>=0; l--) {
            ArrayList<Grid_marker> check_block = new ArrayList<Grid_marker>();
            check_block = Grid_markers.get(i).getNeighbours();
            if (check_block.get(l).getState() != "Blocked") {
              check_block.get(l).setState("Border");
            }
          }
        }
      }
    }

    //"Distance-price" lookup start
    Queue<Grid_marker> searchQ = new LinkedList<Grid_marker>(); //Change the scanning algorithm to queue-built
    for (int i = Grid_markers.size () - 1; i>=0; i--) {
      if (Grid_markers.get(i).getState() == "Current") {
        Grid_markers.get(i).setGrid_dist(0);
        searchQ.add(Grid_markers.get(i));
      }
    }
    while (all_scanned == false || path_found == false) {
      if (searchQ.size() != 0) {
        Grid_marker searched = searchQ.element();
        searchQ.remove(searchQ.element());
        //        println(searched.getGrid_dist());
        if (searched.getState() != "Current") {
          searched.setState("Discovered");
        }
        ArrayList<Grid_marker> check_block = new ArrayList<Grid_marker>();
        check_block = searched.getNeighbours();
        for (int i = check_block.size () - 1; i>=0; i--) {
          if (check_block.get(i).getState() == "Destination") {
            path_found = true;
          } else if (check_block.get(i).getState() == "Undiscovered") {
            check_block.get(i).setState("Frontier");
            searchQ.add(check_block.get(i));
          }
        }
        for (int i = check_block.size () - 1; i>=0; i--) {
          if ((check_block.get(i).getX() == searched.getX() && (check_block.get(i).getY() == searched.getY() + 1 || check_block.get(i).getY() == searched.getY() - 1)) || (check_block.get(i).getY() == searched.getY() && (check_block.get(i).getX() == searched.getX() + 1 || check_block.get(i).getX() == searched.getX() - 1))) {
            if (check_block.get(i).getState()=="Frontier" || check_block.get(i).getState()=="Discovered") {
              if (check_block.get(i).getGrid_dist() > searched.getGrid_dist() + 1 || check_block.get(i).getGrid_dist() == 0) {
                check_block.get(i).setGrid_dist(searched.getGrid_dist());
                check_block.get(i).addGrid_dist(1);
                if (check_block.get(i).getState()=="Frontier") {
                  searchQ.add(check_block.get(i));
                }
              }
            }
          }
          if ((searched.getX() == check_block.get(i).getX() + 1 || searched.getX() == check_block.get(i).getX() - 1) && (searched.getY() == check_block.get(i).getY() + 1 || searched.getY() == check_block.get(i).getY() - 1)) {
            if (check_block.get(i).getState()=="Frontier" || check_block.get(i).getState()=="Discovered") {
              if (check_block.get(i).getGrid_dist() > searched.getGrid_dist() + root_2 || check_block.get(i).getGrid_dist() == 0) {
                check_block.get(i).setGrid_dist(searched.getGrid_dist());
                check_block.get(i).addGrid_dist(root_2);
                if (check_block.get(i).getState()=="Frontier") {
                  searchQ.add(check_block.get(i));
                }
              }
            }
          }
        }

        for (int i = check_block.size () - 1; i>=0; i--) {
          check_block.remove(check_block.get(i));
        }
      } else {
        all_scanned = true;
      }
    }


    //Looking back and building path
    //Setting an impossibly large coord price
    //Choosing the right points to consider with distance in km
    check_m = finish;
    while (path_built == false) {
      double closest_dist = 999999;
      ArrayList<Grid_marker> check_back = new ArrayList<Grid_marker>();
      ArrayList<Grid_marker> cd_list = new ArrayList<Grid_marker>();
      float min_dist = 999999;
      check_back = check_m.getNeighbours();
      for (int l2 = check_back.size () - 1; l2>=0; l2--) {
        if (check_back.get(l2).getState() == "Discovered") {
          if (check_m.getX() == check_back.get(l2).getX() && (check_m.getY() == check_back.get(l2).getY() + 1 || check_m.getY() == check_back.get(l2).getY() - 1)) {

            if (round2(check_back.get(l2).getGrid_dist(), 6) < round2(min_dist, 6)) {

              min_dist = check_back.get(l2).getGrid_dist();
            }
          } else if (check_m.getY() == check_back.get(l2).getY() && (check_m.getX() == check_back.get(l2).getX() + 1 || check_m.getX() == check_back.get(l2).getX() - 1)) {

            if (round2(check_back.get(l2).getGrid_dist(), 6) < round2(min_dist, 6)) {

              min_dist = check_back.get(l2).getGrid_dist();
            }
          } else if ((check_m.getY() == check_back.get(l2).getY() + 1 || check_m.getY() == check_back.get(l2).getY() - 1) && (check_m.getX() == check_back.get(l2).getX() + 1 || check_m.getX() == check_back.get(l2).getX() - 1)) {

            if (round2(check_back.get(l2).getGrid_dist(), 6) < round2(min_dist, 6)) {

              min_dist = check_back.get(l2).getGrid_dist();
            }
          }
        }
      }
      for (int l3 = check_back.size () -1; l3>=0; l3--) {
        if (check_back.get(l3).getGrid_dist() == min_dist) {
          cd_list.add(check_back.get(l3));
        }
        if (check_back.get(l3).getState() == "Current") {
          path_built = true;
        }
      }

      for (int l1 = cd_list.size () - 1; l1>=0; l1--) { //Closest distance in km to start
        float dist1 = round2((float)cd_list.get(l1).getDistanceTo(start.getLocation()), 6);
        if (dist1 < closest_dist) {
          closest_dist = dist1;
        }
      }

      for (int l1 = cd_list.size () - 1; l1>=0; l1--) {
        if ((round2((float)cd_list.get(l1).getDistanceTo(start.getLocation()), 6)) == round2((float)closest_dist, 6)) {
          println("Path accepted");
          check_m = cd_list.get(l1);
          check_m.setState("Path");
          Path_markers.add(check_m);
        }
      }
    }
  } else {
    println(Path_markers);
  }

  for (int i = Grid_markers.size () - 1; i>=0; i--) {
    if (Grid_markers.get(i).getState() != "Path" && Grid_markers.get(i).getState() != "Current" && Grid_markers.get(i).getState() != "Destination") {
      map.getMarkerManager(0).removeMarker(Grid_markers.get(i));
      Grid_markers.remove(i);
    }
  }
  println(Obst_found);
  println(Obstacle_markers);
  println(Path_markers);
  boolean new_cycle = false;
  for (int i = Path_markers.size () - 1; i>=0; i--) {
    for (int k = Obstacle_markers.size () - 1; k>=0; k--) {
      if (Obstacle_markers.get(k).isInsideByLocation(Path_markers.get(i).getLocation()) && !(Obst_found.contains(Obstacle_markers.get(k)))) {
        Obst_found.add(Obstacle_markers.get(k));
        new_cycle = true;
        println("@///@");
      }
    }
  }
  if (new_cycle == false) {
    ArrayList<Location> Path_locations = new ArrayList<Location>();
    Path_locations.add(start.getLocation());
    for (int i = Path_markers.size () - 1; i>=0; i--) {
      Path_locations.add(Path_markers.get(i).getLocation());
    }
    Path_locations.add(finish.getLocation());

    SimpleLinesMarker Path_line = new SimpleLinesMarker(Path_locations);
    Path_line.setColor(color(180, 255, 100, 255));
    Path_line.setStrokeWeight(2);
    Path_line.setStrokeColor(color(80, 255, 100, 255));
    map.getMarkerManager(0).addMarker(Path_line);
    Line_markers.add(Path_line);
  } 
  //Deciding whether to clear the list of red zones
  if (new_cycle == false) {
    for (int i = Obst_found.size ()-1; i>=0; i--) {
      Obst_found.remove(i);
    }
    for (int i = Path_markers.size () - 1; i>=0; i--) {
      map.getMarkerManager(0).removeMarker(Path_markers.get(i));
      Path_markers.remove(i);
    }
  } else {
    println("@@@@@@@@@@");
    iter++;
    Pfb(iter, obstacles_found);
  }
}


class Button {
  String label;
  float x;    // top left corner x position
  float y;    // top left corner y position
  float w;    // width of button
  float h;    // height of button
  int r;
  int g;
  int b;

  Button(String labelB, float xpos, float ypos, float widthB, float heightB, int red, int green, int blue) {
    label = labelB;
    x = xpos;
    y = ypos;
    w = widthB;
    h = heightB;
    r = red;
    g = green;
    b = blue;
  }

  void Draw() {
    fill(r, g, b);
    stroke(141);
    rect(x, y, w, h, 10);
    textAlign(CENTER, CENTER);
    fill(255, 255, 255);
    text(label, x + (w / 2), y + (h / 2));
  }


  boolean MouseIsOver() {
    if (mouseX > x && mouseX < (x + w) && mouseY > y && mouseY < (y + h)) {
      return true;
    }
    return false;
  }
}

class Redzone_marker extends SimplePointMarker {
  int w = 0;

  Redzone_marker(Location location) {
    super(location);
  }

  public void draw(PGraphics pg, float x, float y, int w) {
    pg.pushStyle();
    pg.noStroke();
    pg.fill(255, 20, 20, 100);
    pg.ellipse(x, y, 15, 15);
    pg.fill(255, 100);
    if (w < 10) {
      w = w++;
    }
    pg.ellipse(x, y, w, w);
    pg.popStyle();
  }
}


class Grid_marker extends SimplePointMarker {
  String state = "Undiscovered";
  ArrayList<Grid_marker> Neighbours;
  int grid_x;
  int grid_y;
  float grid_dist;

  Grid_marker(Location location) {
    super(location);
  }

  public void draw(PGraphics pg, float x, float y) {
    pg.pushStyle();
    if (this.state =="Current") {
      pg.fill(color(250, 250, 250, 250));
      pg.strokeWeight(4);
      pg.stroke(color(20, 30, 230, 250));
      pg.ellipse(x, y, 8, 8);
    } else if (this.state == "Destination") {
      pg.fill(color(250, 250, 250, 250));
      pg.strokeWeight(4);
      pg.stroke(color(20, 230, 30, 250));
      pg.ellipse(x, y, 8, 8);
    } else if (this.state == "Undiscovered") {
      pg.fill(color(230, 230, 230, 255));
      pg.noStroke();
      pg.ellipse(x, y, 2, 2);
    } else if (this.state == "Blocked") {
      pg.fill(color(230, 20, 30, 120));
      pg.noStroke();
      pg.ellipse(x, y, 3, 3);
    } else if (this.state == "Border") {
      pg.fill(color(230, 190, 30, 255));
      pg.noStroke();
      pg.ellipse(x, y, 3, 3);
    } else if (this.state == "Frontier") {
      pg.fill(color(170, 30, 250, 255));
      pg.noStroke();
      pg.ellipse(x, y, 6, 6);
    } else if (this.state == "Discovered") {
      pg.fill(color(130, 130, 130, 255));
      pg.noStroke();
      pg.ellipse(x, y, 2, 2);
      pg.fill(color(200, 200, 200, 255));
      pg.text(str(round2(this.grid_dist, 2)), this.getScreenPosition(map).x, this.getScreenPosition(map).y);
    } else if (this.state == "Path") {
      pg.fill(color(40, 250, 50, 255));
      pg.strokeWeight(1);
      pg.stroke(color(20, 230, 30, 70));
      pg.ellipse(x, y, 4, 4);
      pg.text(str(round2(this.grid_dist, 2)), this.getScreenPosition(map).x, this.getScreenPosition(map).y);
    } else {
      pg.fill(255);
      pg.ellipse(x, y, 4, 4);
      pg.fill(255);
    }
    pg.popStyle();
  }

  void setState(String state) {
    this.state = state;
  }
  void setX(int grid_x) {
    this.grid_x = grid_x;
  }
  void setY(int grid_y) {
    this.grid_y = grid_y;
  }
  void setGrid_dist(float grid_dist) {
    this.grid_dist = grid_dist;
  }
  void addGrid_dist(float dist) {
    this.grid_dist = this.grid_dist + dist;
  }
  ArrayList getNeighbours() {
    Neighbours = new ArrayList<Grid_marker>();
    for (int i = Grid_markers.size ()-1; i>=0; i--) {
      if ((Grid_markers.get(i).getX() == this.getX() && Grid_markers.get(i).getY() == this.getY() + 1) || (Grid_markers.get(i).getX() == this.getX() && Grid_markers.get(i).getY() == this.getY() - 1) || (Grid_markers.get(i).getX() == this.getX() + 1 && Grid_markers.get(i).getY() == this.getY()) || (Grid_markers.get(i).getX() == this.getX() - 1 && Grid_markers.get(i).getY() == this.getY())) {
        Neighbours.add(Grid_markers.get(i));
      }
      if ((Grid_markers.get(i).getX() == this.getX() + 1 && Grid_markers.get(i).getY() == this.getY() + 1) || (Grid_markers.get(i).getX() == this.getX() - 1 && Grid_markers.get(i).getY() == this.getY() + 1) || (Grid_markers.get(i).getX() == this.getX() + 1 && Grid_markers.get(i).getY() == this.getY() - 1) || (Grid_markers.get(i).getX() == this.getX() - 1 && Grid_markers.get(i).getY() == this.getY() - 1)) {
        Neighbours.add(Grid_markers.get(i));
      }
    }
    return(Neighbours);
  }

  private String getState() {
    return this.state;
  }
  private int getX() {
    return this.grid_x;
  }
  private int getY() {
    return this.grid_y;
  }
  private float getGrid_dist() {
    return this.grid_dist;
  }
}

