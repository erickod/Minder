/*
* Copyright (c) 2018 (https://github.com/phase1geo/Minder)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Trevor Williams <phase1geo@gmail.com>
*/

using Gtk;

public class MapInspector : Box {

  private DrawArea?                   _da        = null;
  private Granite.Widgets.ModeButton? _layouts   = null;
  private Box?                        _theme_box = null;

  public MapInspector( DrawArea da ) {

    Object( orientation:Orientation.VERTICAL, spacing:10 );

    _da = da;

    /* Create the interface */
    add_layout_ui();
    add_theme_ui();
    add_button_ui();

    /* Make sure that we have some defaults set */
    update_theme_layout();

    /* Whenever a new document is loaded, update the theme and layout within this UI */
    _da.loaded.connect( update_theme_layout );

  }

  /* Adds the layout UI (TBD - Let's do this programmatically with the DrawArea's layouts list) */
  private void add_layout_ui() {

    var icons = new Array<string>();
    _da.layouts.get_icons( ref icons );

    /* Create the modebutton to select the current layout */
    var lbl = new Label( _( "Node Layouts" ) );
    lbl.xalign = (float)0;

    /* Create the layouts mode button */
    _layouts = new Granite.Widgets.ModeButton();
    _layouts.has_tooltip = true;
    for( int i=0; i<icons.length; i++ ) {
      _layouts.append_icon( icons.index( i ), IconSize.SMALL_TOOLBAR );
    }
    _layouts.mode_changed.connect( layout_changed );
    _layouts.query_tooltip.connect( layout_show_tooltip );

    pack_start( lbl,      false, true );
    pack_start( _layouts, false, true );

  }

  /* Called whenever the user changes the current layout */
  private void layout_changed() {
    var names = new Array<string>();
    _da.layouts.get_names( ref names );
    if( _layouts.selected < names.length ) {
      _da.set_layout( names.index( _layouts.selected ) );
    }
  }

  /* Called whenever the tooltip needs to be displayed for the layout selector */
  private bool layout_show_tooltip( int x, int y, bool keyboard, Tooltip tooltip ) {
    if( keyboard ) {
      return( false );
    }
    var names = new Array<string>();
    _da.layouts.get_names( ref names );
    int button_width = (int)(_layouts.get_allocated_width() / names.length);
    if( (x / button_width) < names.length ) {
      tooltip.set_text( names.index( x / button_width ) );
      return( true );
    }
    return( false );
  }

  /* Adds the themes UI */
  private void add_theme_ui() {

    /* Create the UI */
    var lbl = new Label( _( "Themes" ) );
    lbl.xalign = (float)0;

    var sw  = new ScrolledWindow( null, null );
    var vp  = new Viewport( null, null );
    _theme_box = new Box( Orientation.VERTICAL, 20 );
    vp.set_size_request( 200, 600 );
    vp.add( _theme_box );
    sw.add( vp );

    /* Get the theme information to display */
    var names = new Array<string>();
    var icons = new Array<Gtk.Image>();

    _da.themes.names( ref names );
    _da.themes.icons( ref icons );

    /* Add the themes */
    for( int i=0; i<names.length; i++ ) {
      var ebox  = new EventBox();
      var item  = new Box( Orientation.VERTICAL, 5 );
      var label = new Label( names.index( i ) );
      item.pack_start( icons.index( i ), false, false, 5 );
      item.pack_start( label,            false, true );
      ebox.button_press_event.connect((w, e) => {
        select_theme( label.label );
        _da.set_theme( label.label );
        return( false );
      });
      ebox.add( item );
      _theme_box.pack_start( ebox, false, true );
    }

    /* Pack the panel */
    pack_start( lbl, false, true );
    pack_start( sw,  true,  true );

  }

  /* Adds the bottom button frame */
  private void add_button_ui() {

    var grid = new Grid();
    grid.column_homogeneous = true;
    grid.column_spacing     = 10;

    var balance = new Button.with_label( _( "Balance Nodes" ) );
    balance.clicked.connect(() => {
      _da.balance_nodes();
    });

    grid.attach( balance, 0, 0 );

    pack_start( grid, false, true );

  }

  /* Makes sure that only the given theme is selected in the UI */
  private void select_theme( string name ) {

    /* Deselect all themes */
    _theme_box.get_children().foreach((entry) => {
      entry.override_background_color( StateFlags.NORMAL, null );
    });

    /* Create the selection color */
    Gdk.RGBA c = {1.0, 1.0, 1.0, 1.0};
    c.parse( "Blue" );

    /* Select the specified theme */
    int index;
    var names = new Array<string>();
    _da.themes.names( ref names );
    for( index=0; index<names.length; index++ ) {
      if( names.index( index ) == name ) {
        break;
      }
    }
    _theme_box.get_children().foreach((entry) => {
      if( index == 0 ) {
        entry.override_background_color( StateFlags.NORMAL, c );
      }
      index--;
    });

  }

  private void update_theme_layout() {

    /* Make sure the current theme is selected */
    select_theme( _da.get_theme_name() );

    /* Update the current layout in the UI */
    var layout = _da.get_layout_name();
    if( layout == _( "Manual" ) ) { _layouts.selected = 0; }
    else if( layout == _( "Vertical" )   ) { _layouts.selected = 1; }
    else if( layout == _( "Horizontal" ) ) { _layouts.selected = 2; }
    else if( layout == _( "To left" )    ) { _layouts.selected = 3; }
    else if( layout == _( "To right" )   ) { _layouts.selected = 4; }
    else if( layout == _( "Upwards" )    ) { _layouts.selected = 5; }
    else if( layout == _( "Downwards" )  ) { _layouts.selected = 6; }

  }

}