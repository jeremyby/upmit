/* 
 * GLOBAL VARIABLES
 */

// these should match with the bootrstrap defined widths
window.xs_screen_max = 767;
window.sm_screen_max = 991;

/* 
 * ================================================================
 * VIEWPORT
 *
 * get actual window width/height (to match with css media queries)
 */
function viewport() {
    var e = window, a = 'inner';
    if (!('innerWidth' in window )) {
        a = 'client';
        e = document.documentElement || document.body;
    }
    return { width : e[ a+'Width' ] , height : e[ a+'Height' ] };
}

/*
 * ================================================================
 * Mobile Menu Icon
 *
 * Icon which toggles (opens/closes) main menu on smaller resolutions
 */
function toggle_main_menu()
{
    // only applies for mobile window widths
    if (viewport().width <= window.xs_screen_max)
    {
        var mobile_menu_icon = $("#left-sidebar #mobile-menu-icon");
        var main_menu = $("#left-sidebar #main-menu");

        // if menu is already visible, hide it and remove active class for menu icon
        if (main_menu.is(':visible'))
        {
            main_menu.addClass("menu_closed_on_xs").removeClass("menu_opened_on_xs").slideUp("fast", function(){
                mobile_menu_icon.removeClass("active");
            });
        }

        // if menu is hidden, show it and add active class to menu icon
        else {
            main_menu.addClass("menu_opened_on_xs").removeClass("menu_closed_on_xs").slideDown("fast", function(){
                mobile_menu_icon.addClass("active");
            });            
        }
    }
    // end: only applies for mobile window widths
}

/*
 * ================================================================
 * Main Menu Visiblity on Window Resize
 *
 * Since main menu is hidden on smaller window widths, this function makes sure that it is visible when window is maximised
 */
function main_menu_visiblity_on_resize()
{
    var main_menu = $("#left-sidebar #main-menu");

    // for larger window viewports
    if (viewport().width > window.xs_screen_max)
    {
        // if menu was closed on small (mobile/xs) viewport, show it
        if (main_menu.hasClass("menu_closed_on_xs"))
        {
            main_menu.show();
        }
    }
    // end: for larger window viewports

    // for smaller window viewports (mobile/xs)
    else {
        // if menu was closed on small (mobile/xs) viewport, ensure it remains closed
        if (main_menu.hasClass("menu_closed_on_xs"))
        {
            main_menu.hide();
        } 
        // if menu was open on small (mobile/xs) viewport, ensure it remains open
        if (main_menu.hasClass("menu_opened_on_xs"))
        {
            main_menu.show();
        }       
    }
}

/*
 * ================================================================
 * Sections Content Vertical Position
 *
 * By default, main content for each section is positioned at the bottom of the page. 
 * This function checks the content-wrapper height, and if it is bigger than 80% of the window height, content-wrapper is positioned statically so that a user can scroll down the page, and content is not hidden.
 *
 * This function only applies for non-mobile viewports (when window width is larger than 768px), since on smaller screens, the layout is different
 */
function sections_content_vertical_position()
{  
    // only applies for non-mobile window widths (see comment above)
    if (viewport().width > window.xs_screen_max)
    {
        var window_height = $(window).height();
        var content_available_height = 0.8 * window_height; // the available height for the .content-wrapper when it is absolute positioned

        // for each section
        $("#main-content .section-wrapper").each(function()
        {
            var content_wrapper = $(this).find(".content-wrapper");
            var content_wrapper_height = content_wrapper.height();
            var active_section = ($(this).hasClass("active")) ? true : false; // check if this section is active (visible)

            // if content-wrapper height is larger than the height available in page (without content being hidden), set position to static (not absolute)
            if (content_wrapper_height > content_available_height)
            {
                content_wrapper.css({
                    "position":"static"
                });
            }
            // end: if content-wrapper height is larger than the height available

            // if content-wrapper height is smaller than (within) height available, set position to absolute (with bottom and right position set in the CSS)
            else
            {
                content_wrapper.css({
                    "position":"absolute"
                });
            }

            // scroll to top of active section to ensure top content of section is not hidden on page resize (doesn't apply to mobile devices)
            /*
            if (active_section == true && !jQuery.browser.mobile)
            {
                var section_vertical_offset = $(this).offset().top;
                $('html, body').stop().animate({
                    scrollTop: section_vertical_offset
                }, 500,'easeInOutCubic');                    
            } 
            */            
        });
        // end: for each section
    }
    // end: only applies for non-mobile

    // for mobile viewport
    else
    {
        // remove absolute positionining for all section's content
        $("#main-content .section-wrapper .content-wrapper").css({
            "position":"static"
        });
    }
    // end: for mobile viewport
}

/*
 * ================================================================
 * Initialise General Links Click Events
 *
 * ** Has to be called BEFORE initialise_main_menu_click_events() **
 *
 * This function handles the onclick events for all the links inside the page with class ".link-scroll"
 * When a link targets an id within the same page, scroll to that id and update active section
 */
function initialise_general_links_click_events()
{
    // in any link inside the page is clicked
    $("a.link-scroll").click(function(event)
    {
        // get target link
        var clicked_link_href = $(this).attr("href");

        // if link is not empty
        if (clicked_link_href !== undefined && clicked_link_href != "" && clicked_link_href != "#")
        {
            var first_character_of_link = clicked_link_href.substr(0,1); // will be used below

            // if link is to an ID of an element (anchor link)
            if (first_character_of_link == "#")
            {
                // if element with that ID exists inside the page
                if ($(clicked_link_href).length > 0)
                {
                    // add class to identify that scroll is "in action", so that no other scroll functions conflict
                    $("#main-content").addClass("same_page_link_in_action");

                    // scroll to section
                    var target_vertical_offset = $(clicked_link_href).offset().top;
                    $('html, body').stop().animate({
                        scrollTop: target_vertical_offset
                    }, 1500,'easeInOutCubic', function(){

                        // remove class used to identify that scroll is "in action", so that no other scroll functions conflict
                        $("#main-content").removeClass("same_page_link_in_action");

                        // set visible section to active
                        update_active_sections_on_scroll();                 
                    });                  

                    event.preventDefault();                     
                }

                // if element with that ID doesn't exist
                else {
                    return false; 
                } 
            }
            // end: if link is to an ID of an element (anchor link)

            // normal link
            else {
                // acts as a normal link
            }
            // end: normal link

        }
        // end: if link is not empty 

        // empty link
        else {
            event.preventDefault(); 
            return false;   
        } 
    });
    // end: if any link inside the page is clicked
}

/*
 * ================================================================
 * Initialise Main Menu Click Events
 *
 * ** Has to be called AFTER initialise_general_links_click_events() since it overrides the other function **
 *
 * This function handles the onclick events for the main menu item links
 */
function initialise_main_menu_click_events()
{
    // first remove any click events for menu links (which were set for all links in initialise_general_links_click_events() above)
    $("#main-menu .menu-item > a").off('click');
    $("#main-menu .menu-item > a").prop("onclick", null);

    // for each click of main menu item links
    $("#main-menu .menu-item > a").click(function(event)
    {
        var clicked_link_href = $(this).attr("href");
        var first_character_of_link = clicked_link_href.substr(0,1); // will be used below
        var clicked_link_parent_menu_item = $(this).parent(".menu-item");
        var link_menu_item_id = clicked_link_parent_menu_item.attr("id");
        
        // if menu item has "scroll" class, and links to a section id (starts with #) load scroll function
        if (clicked_link_parent_menu_item.hasClass("scroll") && first_character_of_link == "#")
        {
            var clicked_menu_item_id = (link_menu_item_id !== undefined && link_menu_item_id != "") ? link_menu_item_id : "";

            // add class to identify that scroll is "in action", so that no other scroll functions conflict
            $("#main-content").addClass("same_page_link_in_action");

            // do not change background on mobile viewports
            var change_background = (viewport().width > window.xs_screen_max) ? true : false;

            scroll_to_section(clicked_link_href, clicked_menu_item_id, change_background);

            event.preventDefault(); // stop link from default action 
        }

        // if menu item does NOT have "scroll" class, default link action will apply
        else 
        {
            // if fake link ("#") or empty, do nothing
            if (clicked_link_href === undefined || clicked_link_href == "" || clicked_link_href == "#") 
            { 
                event.preventDefault(); 
                return false; 
            }
        }

    });
}

/*
 * ================================================================
 * Scroll Up/Down to section wrapper
 *
 * This function scrolls up/down to a section, and calls function which updates section to active
 *
 * @param target_section - section id - the id of the section wrapper to which to scroll to
 * @param clicked_menu_item_id - menu item id - the id of the clicked menu item (if function called after clicking on a menu item)
 * @param change_background - true or false - (default true) if false, do not change background on scroll 
 */
function scroll_to_section(target_section_id, clicked_menu_item_id, change_background)
{
    // only works if the target_section is provided
    if (target_section_id !== undefined && target_section_id != "")
    {
        var target_section_wrapper = $("#main-content "+target_section_id+".section-wrapper");

        // if target section exists and is not already active
        if (target_section_wrapper.length != 0 && !target_section_wrapper.hasClass("active"))
        {
            // scroll to section
            var section_vertical_offset = target_section_wrapper.offset().top;
            $('html, body').stop().animate({
                scrollTop: section_vertical_offset
            }, 1500,'easeInOutCubic', function(){

                // remove class used to identify that section is "in action", so that no other scroll functions conflict
                $("#main-content").removeClass("same_page_link_in_action");                
            });  

            // set section to active
            set_section_to_active(target_section_id, clicked_menu_item_id, '', change_background);
        }
        // end: if target section exists

        else { return false; }
    }
    // end: only works if the target_section is provided

    else { return false; }
}

/*
 * ================================================================
 * Set Section to Active
 *
 * When a user scrolls or clicks to scroll to a section, this function is called to set that particular section to active
 *
 * - sets menu item to active
 * - sets active class to section wrapper
 * - change background image of page (if set for that particular section)
 *
 * @param target_section - section id - the id of the active section wrapper
 * @param clicked_menu_item_id - menu item id - the id of the clicked menu item (if function called after clicking on a menu item)
 * @param called_on_scroll - true or false - if set to true, this function was called when scrolling, hence background changes should be faster
 * @param change_background - true or false - (default true) if false, do not change background on scroll 
 */
function set_section_to_active(target_section_id, clicked_menu_item_id, called_on_scroll, change_background)
{
    // only works if the target_section is provided
    if (target_section_id !== undefined && target_section_id != "")
    {
        var section_wrapper = $("#main-content "+target_section_id+".section-wrapper");

        // remove current active classes
        $("#main-menu .menu-item").removeClass("active");
        $("#main-content .section-wrapper").removeClass("active");

        // ------ set menu item to active ---------
        // if clicked menu item id is provided and exists
        var clicked_menu_item_object = (clicked_menu_item_id != undefined && clicked_menu_item_id != "") ? $("#main-menu #"+clicked_menu_item_id+".menu-item") : "";
        if (clicked_menu_item_object != "" && clicked_menu_item_object.length != 0)
        {
            clicked_menu_item_object.addClass("active");
        }

        // if clicked menu item id is not provided, find menu item corresponding to the target section id
        else {
            var section_name = target_section_id.substr(1); // section ids (links) start with "#"
            $("#main-menu #menu-item-"+section_name+".menu-item").addClass("active"); // assuming menu items ids start with "menu-item-"
        }

        // ------ set section wrapper to active ---------
        section_wrapper.addClass("active");

        // Hide/Show Main Menu "TOP" icon
        toggle_top_icon_in_main_menu();

        // ------ change custom background ------
        if (change_background != false)
        {
            var section_custom_background_attr = section_wrapper.attr("data-custom-background-img");
            var section_custom_background = (section_custom_background_attr !== undefined && section_custom_background_attr != "") ? section_custom_background_attr : $("#outer-background-container").attr("data-default-background-img"); // use #outer-background-container default image if custom background not set

            // if target section wrapper has custom background set
            if (section_custom_background !== undefined && section_custom_background != "")
            {
                var transition_speed = (called_on_scroll != true) ? 1500 : 550; // crossfading speed should be faster when function called on scroll
                
                $("#outer-background-container").backstretch(section_custom_background, {fade:transition_speed});
            }
            // end: if target section wrapper has custom background set
        }
        // end: change custom background
    }
    // end: only works if the target_section is provided
}


/*
 * ================================================================
 * Get All Section Wrappers in Page
 *
 * This function returns an array of all the section wrappers in the page
 *
 */
function get_all_section_wrappers_in_page()
{
    var section_wrappers = $("#main-content").find(".section-wrapper");
    return section_wrappers;
}

/*
 * ================================================================
 * Update Active Sections on Scroll
 *
 * This function is fired when the user scrolls, and updates the active section depending on the vertical scroll position
 *
 * @param section_wrappers - all the section wrappers in a page
 * @param amount_of_pixels_as_buffer_between_sections - integer - a proportion of the website height, used to match visible sections more accurately
 */
function update_active_sections_on_scroll(section_wrappers, amount_of_pixels_as_buffer_between_sections)
{
    // first check if already loaded (to make function faster), otherwise search for all the section wrappers
    var all_section_wrappers = (section_wrappers !== undefined && section_wrappers != "") ? section_wrappers : $("#main-content").find(".section-wrapper");
    
    // see comment above
    var amount_of_pixels_as_buffer_between_sections = (amount_of_pixels_as_buffer_between_sections !== amount_of_pixels_as_buffer_between_sections && amount_of_pixels_as_buffer_between_sections != "") ? amount_of_pixels_as_buffer_between_sections : 0.25 * ($(window).height());

    var scroll_from_top = $(document).scrollTop();

    // get the visible section
    var current_scroll_section = all_section_wrappers.map(function(){
        var offset_from_top = ($(this).offset().top) - amount_of_pixels_as_buffer_between_sections;
        var section_height = $(this).height();
        var offset_from_bottom = offset_from_top + section_height;

        if (scroll_from_top > offset_from_top && scroll_from_top <= offset_from_bottom)
            return this;
    });

    // update such section to active
    if (current_scroll_section !== undefined && current_scroll_section != "")
    {
        var active_section_id = "#"+current_scroll_section.attr("id");

        
        
        // DON'T do update if visible section is already active
        if (!current_scroll_section.hasClass("active"))
        {
            set_section_to_active(active_section_id, '', true);
        }        
    }
}

/*
 * ================================================================
 * Hide/Show Main Menu "TOP" icon
 *
 * This function hides the top "^" icon in the main menu when the user is at the top of the page, and shows it when the user scrolls down.
 */
function toggle_top_icon_in_main_menu()
{
    var intro_menu_item = $("#main-menu #menu-item-intro");
    if (intro_menu_item.hasClass("active"))
    {
        intro_menu_item.css({"opacity":0}).addClass("main-menu-top-icon-active")
    }
    else {
        intro_menu_item.css({"opacity":0.7}).removeClass("main-menu-top-icon-active")
    }
}


/*
 * ================================================================
 * Preload All Sections Background Images
 *
 * This function preloads all the background images set for all section wrappers in the page
 *
 */
function preload_section_backgrounds()
{
    var section_wrappers = get_all_section_wrappers_in_page();

    // if there are sections
    if (section_wrappers.length > 0)
    {
        // for each section wrapper
        section_wrappers.each(function(){
            // if a custom background image is set, load it
            var section_custom_background = $(this).attr("data-custom-background-img");
            if (section_custom_background !== undefined && section_custom_background != "")
            {
                var img = new Image();
                img.src = section_custom_background;
                
                // alert(img.src)
            }
        });
    }

}

/*
 * ================================================================
 * Grid Items Clearfix
 *
 * This function adds clearfixes after the grid items to fix issues with different grid items heights
 *
 */
function add_clear_items_to_fix_grid_items_different_heights_issue() {
    // if there are grid items
    if ($("#main-content .grid .grid-item").length > 0)
    {
        var list_grid = $("#main-content .grid");

        // 2 columns
        if (list_grid.hasClass("clearfix-for-2cols"))
        {

            // add clearfixes after every 2 items (for 2 cols grid)
            list_grid.find(".grid-item:nth-of-type(2n+2)").after('<article class="clearfix"></article>');
            return false;
        }

        // 3 columns
        else if (list_grid.hasClass("clearfix-for-3cols"))
        {

            // add clearfixes after every 2 items (for 2 cols grid)
            list_grid.find(".grid-item:nth-of-type(3n+3)").after('<article class="clearfix"></article>');
            return false;
        }     

    }
    // end: if there are grid items   
}

/*
 * ================================================================
 * Effect Fade Out Inactive Grid Items
 *
 * On hover of a grid item, the other grid items are faded out.
 * It is applied to .project-grid containers with class ".effect-fade-inactive"
 *
 */
function effect_fade_out_inactive_grid_items() {
    // if there are project-grid sections with effect activated
    if ($("#main-content .projects-grid.effect-fade-inactive").length > 0)
    {
        // for each projects grid with effect
        $("#main-content .projects-grid.effect-fade-inactive").each(function(){
            var this_project_grid = $(this);

            // on hover of each grid-item content
            this_project_grid.find(".grid-item .item-content").hover(function(){
            // on mouse over
                var this_item_content = $(this);

                this_item_content.css({"opacity":1}); // fade in this item

                this_project_grid.find(".grid-item .item-content").not(this_item_content).css({"opacity":0.3}); // fade out other items

            }, function(){
            // on mouse out
                var this_item_content = $(this);

                this_item_content.css({"opacity":0.3}); // fade out this              

            });
            // end: on hover of each grid-item content            

            // ensure that on mouse out of grid, all its items are not faded
            this_project_grid.hover(function(){}, function(){
                setTimeout(function() {
                    this_project_grid.find(".grid-item .item-content").css({"opacity":1});
                }, 200);
            });

        });
        // end: for each projects grid with effect
    }
    // end: if there are project-grid sections with effect activated  
}

/*
 * ================================================================
 * Set height of parent content wrappers
 *
 * This function looks for any elements (in main content) with .max-height set as class, looks for the parent .content-wrapper and sets its percentage height to fill the page
 * - if a data-height-percent attribute is set to the element with .max-height class, that defined percantage height is used
 */
function set_height_of_parent_content_wrappers()
{
    var elements_with_max_height_class = $("#main-content .max-height");

    // for each element
    elements_with_max_height_class.each(function()
    {
        var parent_content_wrapper = $(this).parents(".content-wrapper");

        // if parent .content-wrapper is found
        if (parent_content_wrapper.length > 0)
        {
            parent_content_wrapper.parents(".section-wrapper").addClass("modified-height");

            // if data-height-percent attribute is set for the element with class ".max-height", then use that defined percentage height
            var defined_height_percentage = $(this).attr("data-height-percent");
            if (defined_height_percentage !== undefined && defined_height_percentage != "" && !isNaN(defined_height_percentage))
            {
                parent_content_wrapper.css({ "height":defined_height_percentage+"%" });
            }

            // else, if no defined percentage height is set, set a default 80% height to the content-wrapper
            else 
            {
                parent_content_wrapper.css({ "height":"80%" });
            }
        }
        // end: if parent .content-wrapper is found
    });
    // end: for each element
}

/*
 * ================================================================
 * Set equal height to all carousel slides on small displays
 *
 * In order to avoid adjusting height on slide change on small displays, find the largest height among all slides in the carousel, and set all slides' height to that particular height
 *
 */
function set_equal_height_to_all_carousel_slides_on_small_displays()
{
    var carousels = $("#main-content .carousel");

    // for each carousel
    carousels.each(function()
    {
        var visible_set_percentage_height = ( $(this).attr("data-height-percent") !== undefined && $(this).attr("data-height-percent") != "" &&  !isNaN($(this).attr("data-height-percent")) ) ? $(this).attr("data-height-percent") : 80; // the carousel height (percentage) in proportion of the screen height (default is 80)
        var visible_set_height = (visible_set_percentage_height / 100) * viewport().height;

        var carousel_slides = $(this).find(".item .carousel-text-content");
        $(this).find(".item:not(.active)").css({ "opacity":"0", "position":"absolute", "display":"block" }); // temporary fix to get the hidden slides' height
        carousel_slides.css({ "height":"auto" }); // reset previously set height before getting actual height

        var all_slides_height = [];
        // for each slide, get their height and store them in an array
        carousel_slides.each(function()
        {
            all_slides_height.push($(this).height());
        });
        var largest_slide_height = Math.max.apply(Math, all_slides_height) + 40; // get largest height among all slides (add 40px to make sure no content is hidden)

        $(this).find(".item:not(.active)").attr("style",""); // reset the temporary fix to get the hidden slides' height

        // if on small displays or small heights (slide height larger than visible height)
        if (viewport().width <= window.xs_screen_max || largest_slide_height >= visible_set_height)
        {
            $(this).parents(".section-wrapper").addClass("modified-height");
            carousel_slides.height(largest_slide_height); // apply the largest height to all slides
        }
        // end: if on small displays

        // on larger displays
        else 
        {
            $(this).parents(".section-wrapper").removeClass("modified-height");
            $(this).removeClass("slides-height-modified").find(".item .carousel-text-content").css({ "height":"100%" });
        }

    });
    // end: for each carousel
}



/*
 * ================================================================
 * Go To Top Icon Visibility
 *
 * - icon is hidden at the top of the page, shown when scrolling further down
 */
function go_to_top_visibility()
{
    var go_to_top_icon = $("#go-to-top");

    // if icon exists
    if (go_to_top_icon.length > 0)
    {
        var scroll_from_top = $(document).scrollTop();
        
        // if at the top section of the page, hide icon
        if (scroll_from_top < viewport().height)
        {
            go_to_top_icon.removeClass("active");
        }

        // if further down the page, show icon
        else
        {
            go_to_top_icon.addClass("active");
        }
    }
}

/*
 * ================================================================
 * Scroll to Top of the Page
 *
 * - scrolls to top of the page (#outer-container)
 */
function scroll_to_top()
{
    $('html, body').stop().animate({
        scrollTop: 0
    }, 1500,'easeInOutCubic', function(){
        $("#go-to-top").removeClass("active"); // deactive scroll to top icin     
    });
}

/*
 * ================================================================
 * Load Images
 *
 * - <img> elements with a particular class and "data-img-src" attribute are loaded
 *
 * @param images_objects_selector_class - the selector class of the <img> objects which will be loaded
 * @param remove_selector_class_after_image_loaded - if set to true, the selector class used to load images will be removed after the image is loaded (for css purposes)
 * @param vertical_layout_positioning_check - if set to true, fire sections_content_vertical_position() function correct vertical positioning of sections
 */
function load_images(images_objects_selector_class, remove_selector_class_after_image_loaded, vertical_layout_positioning_check)
{
    // if images exist
    var images_objects = $("."+images_objects_selector_class);
    if (images_objects.length > 0)
    {
        // prepare image sources
        var images = new Array();
        images_objects.each(function()
        {
            var image_src = $(this).attr("data-img-src");
            if (image_src !== undefined && image_src != "")
            {
                var image_object_data = new Array();
                image_object_data["img_object"] = $(this); // image as an object (to use after load)
                image_object_data["img_src"] = image_src;
                images.push(image_object_data); // add to images array
            }
        });

        // load images
        var new_image_object = new Image();
        var count_images_to_load = images.length;
        for(i=0; i<count_images_to_load; i++) 
        {
            new_image_object.src = images[i]["img_src"];
            images[i]["img_object"].attr("src", images[i]["img_src"]);

            // if enabled, remove selector class after the image is loaded
            if (remove_selector_class_after_image_loaded == true)
            {
                images[i]["img_object"].removeClass(images_objects_selector_class);
            }

            // if enabled, correct vertical positioning of sections (after last image) (only when not viewing on mobile viewport)
            if (vertical_layout_positioning_check == true && i == count_images_to_load-1 && (!jQuery.browser.mobile || viewport().width > window.xs_screen_max))
            {
                sections_content_vertical_position();
            }
        }
        // end: load images
    }
    // end: if images exist
}

/*
 * ================================================================
 * Form validation and submit actions
 *
 * @param form_object - objects -  if set, validate and submit this form only. Otherwise search for all forms with class .validate-form
 */
function validate_and_submit_forms(form_object)
{
    var forms = (form_object !== undefined && form_object.length > 0) ? form_object : $("form.validate-form");

    // for each form 
    forms.each(function(){

        var this_form = $(this);

        // -------------- onChange of each form field with validation enabled (with class .validate) --------------
        this_form.find(".validate-field").each(function()
        {
            $(this).change(function()
            {
                // first empty any error containers
                $(this).siblings(".alert").fadeOut("fast", function(){ $(this).remove(); });

                // value is not empty, validate it
                if ($(this).val().trim() != "")
                {
                    var validation_message = validate_fields(this_form, $(this));
                    if (validation_message.length > 0)
                    {
                        // if there are errors (not successfull)
                        if (validation_message[0]["message"] !== undefined && validation_message[0]["message"] != "" && validation_message[0]["message"] != "success")
                        {
                            // create error field
                            var error_field_html = '<div class="alert">'+validation_message[0]["message"]+'</div>';
                            $(this).after(error_field_html);
                            $(this).siblings(".alert").fadeIn("fast");
                        }
                        // end: if there are errors
                    }
                }
                // end: if value is not empty
            });
        });
        // -------------- end: onChange of each form field --------------

        // -------------- on Submit of form --------------
        this_form.submit(function(event)
        {
            event.preventDefault(); // stop default action (will be handled via AJAX below)

            // show form loader
            $(this).find(".form-loader").fadeIn("fast");

            var form_action = $(this).attr("action");
            // if action is not set (URL to mail.php), stop form action
            if (form_action === undefined && form_action == "") return false;

            // clear all errors
            $(this).find(".alert").fadeOut("fast", function(){ $(this).remove(); });
            $(this).find(".form-general-error-container").fadeOut("fast", function(){ $(this).empty(); });

            var errors_found = false;

            // for each field with validation enabled (with class .validate)
            $(this).find(".validate-field").each(function()
            {
                var validation_message = validate_fields(this_form, $(this));
                if (validation_message.length > 0)
                {
                    // if there are errors (not successfull)
                    if (validation_message[0]["message"] !== undefined && validation_message[0]["message"] != "" && validation_message[0]["message"] != "success")
                    {
                        // create error field
                        var error_field_html = '<div class="alert">'+validation_message[0]["message"]+'</div>';
                        $(this).after(error_field_html);
                        $(this).siblings(".alert").fadeIn("fast");

                        errors_found = true;
                    }
                    // end: if there are errors
                }               
            });
            // end: for each field

            // if errors were found, stop form from being submitted
            if (errors_found == true) 
            {
                // hide loader
                $(this).find(".form-loader").fadeOut("fast");
                return false;
            }

            // submit form
            $.ajax({
                type: 'POST',
                url: form_action,
                data: $(this).serialize(),
                dataType: 'html',
                success: function (data) 
                {
                    // if form submission was processed (successfully or not)

                    // hide loader
                    this_form.find(".form-loader").fadeOut("fast");

                    var submission_successful = (data == "Form submitted successfully.") ? true : false;

                    // prepare message to show after form processed
                    var message_field_html = '<div class="alert ';
                    message_field_html += (submission_successful == true) ? 'success' : 'error';
                    message_field_html += '">'+data+'</div>';
                    // show message
                    this_form.find(".form-general-error-container").html(message_field_html).fadeIn("fast", function(){
                        // if submission was successful, hide message after some time
                        $(this).delay(10000).fadeOut("fast", function(){ $(this).remove(); });
                    });

                    // if form submitted successfully, empty fields
                    if (submission_successful == true) this_form.find(".form-control").val("");
                },
                error: function (data) 
                {
                    // if form submission wasn't processed

                    // hide loader
                    this_form.find(".form-loader").fadeOut("fast");

                    // show error message
                    var error_field_html = '<div class="alert">An error occured. Please try again later.</div>';
                    this_form.find(".form-general-error-container").html(error_field_html).fadeIn("fast");

                }
            }); 
            // end: submit form           
        });
        // -------------- end: on Submit of form --------------

    })
    // end: for each form
}

/*
 * ================================================================
 * Form validation - separate fields
 *
 * @param form_object - object - required - the form in which the fields relate to
 * @param single_field - object - if set, the function will validate only that particular field. Otherwise the function will validate all the fields with class .validate
 */
 function validate_fields(form_object, single_field)
 {
    // if form exists
    if (form_object !== undefined && form_object.length > 0)
    {
        var form_fields_to_validate = (single_field !== undefined && single_field.length > 0) ? single_field : form_object.find(".validate"); // if single field is set, the function will validate only that particular field. Otherwise the function will validate all the fields with class .validate

        var validation_messages = new Array();

        // for each field to validate
        form_fields_to_validate.each(function()
        {
            var validation_type = $(this).attr("data-validation-type");
            var field_required = $(this).hasClass("required");
            var field_value = $(this).val().trim();

            var single_field_error_details = new Array(); // will contain this field and its error
            single_field_error_details["field_object"] = $(this);
            
            single_field_error_details["message"] = "success"; // default is success. If the above tests fail, replace message with error

            // if field is required and value is empty
            if (field_required == true && (field_value == "" || field_value === null || field_value === undefined)) single_field_error_details["message"] = "This field is required";

            // string validation
            if (validation_type == "string" && (field_value != "" && field_value !== null && field_value !== undefined))
            {
                if (field_value.match(/^[a-z0-9 .\-]+$/i) == null) single_field_error_details["message"] = "Invalid characters found.";
            }

            // email validation
            else if (validation_type == "email" && (field_value != "" && field_value !== null && field_value !== undefined))
            {
                if (field_value.match(/^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/) == null) single_field_error_details["message"] = "Please enter a valid email address.";
            }

            // phone validation
            else if (validation_type == "phone" && (field_value != "" && field_value !== null && field_value !== undefined))
            {
                if (field_value.match(/^\(?\+?[\d\(\-\s\)]+$/) == null) single_field_error_details["message"] = "Invalid characters found.";
            }

            validation_messages.push(single_field_error_details); // if none of the above fail, return validation successfull

        });
        // end: for each field to validate

        return validation_messages;
    }
    // end: if form exists
 }

 /*
 * ================================================================
 * Fixed Background image dimensions on mobile
 *
 * in order to avoid stretching issues when scrolling on mobile devices, set background image to a fixed size (depending on window height)
 */
 function fixed_bg_image_dimensions_on_mobile()
 {
    var desktop_background_container = $("#outer-background-container");

    // if desktop bg container exists
    if (desktop_background_container.length > 0)
    {
        var default_background_image = desktop_background_container.attr("data-default-background-img");

        // if default bg image is set
        if (default_background_image !== undefined && default_background_image != "")
        {

            // if on mobile device
            if (!jQuery.browser.mobile)
            {
                // get the mobile window dimensions plus extra 10% (to make sure that the background fills all the screen)
                var window_height_plus_extra = viewport().height + (0.1 * viewport().height);
                var window_width_plus_extra = viewport().width + (0.1 * viewport().width);

                var new_image_object = new Image();
                new_image_object.src = default_background_image;

                // set background to body
                $("body").css({
                    "background-image":"url("+default_background_image+")",
                    "background-position":"top center",
                    "background-repeat":"no-repeat",
                    "background-attachment":"fixed",
                    "background-size":"auto "+window_height_plus_extra+"px, cover",
                });

                // hide other set backgrounds
                desktop_background_container.css({ "opacity": "0" });
            }

            // if NOT on mobile device
            else {
                // remove image bg to body
                $("body").css({
                    "background-image":"",
                    "background-position":"",
                    "background-repeat":"",
                    "background-size":"",
                    "background-attachment":"",
                    "background":"#000"
                });

                // show other set backgrounds
                desktop_background_container.css({ "opacity": "1" });
            }

        }
        // end: if default bg image is set
    }
    // end: if desktop bg container exists
 }

/*
 * ================================================================
 * IE9: Contact Form Fields Placeholders
 *
 * Since IE9 or less browsers do not support "placeholders" for form input fields, set replace "placeholder" value inside the field value.
 */
 function contact_form_IE9_placeholder_fix()
 {
    var forms = $("form");

    // for each form 
    forms.each(function()
    {
        var this_form = $(this); 

        // for each input field
        $(this).find(".form-control").each(function()
        {
            var field_placeholder = $(this).attr("placeholder");
            // if a placeholder is set
            if (field_placeholder !== undefined && field_placeholder != "")
            {
                // set default value to input field
                $(this).val(field_placeholder);

                // set an onfocus event to clear input field
                $(this).focus(function() {
                    if ($(this).val() == field_placeholder) $(this).val("");
                });

                // set an onblur event to insert placeholder if field is empty
                $(this).blur(function() {
                    if ($(this).val() == "") $(this).val(field_placeholder);
                });
            }
        });
        // end: for each input field
    });   
 }
 
 
 
 
 
 
 /* 
* ===============================================================
* ON DOCUMENT READY
* ===============================================================
*/
function initialise_document_ready_functions()
{
   // useful variables (used in other functions)
   var section_wrappers = get_all_section_wrappers_in_page(); // get all the section wrappers in the page
   var amount_of_pixels_as_buffer_between_sections = 0.25 * ($(window).height()); // used in update_active_sections_on_scroll();

   // set visible section to active
   update_active_sections_on_scroll(section_wrappers, amount_of_pixels_as_buffer_between_sections);

   // Sections Content Vertical Position
   sections_content_vertical_position();

   // Initialise General Links Click Events
   initialise_general_links_click_events();
   
   // Initialise Main Menu Links Click Events
   initialise_main_menu_click_events();

   // initialise hover effect - fade out inactive project grid items
   effect_fade_out_inactive_grid_items(); 

   // modify heights of .content-wrapper parents of elements with .max-height class set
   set_height_of_parent_content_wrappers();

   // initialise carousel
   $('#features-carousel').carousel({
     interval: 10000
   });

   // initialise form validation and submit functions 
   validate_and_submit_forms();

   // ------ Owl Carousel ------
   // Initialise Owl Carousels with common class .popup-image-gallery when popup is opened
   // - you can use the same functions below if you want to add a new Owl Carousel with different parameters (in this case call the carousel's unique ID instead)
   // - documentation for Owl Carousel: http://www.owlgraphic.com/owlcarousel/#how-to
   $('#common-modal').on('shown.bs.modal', function()
   {
   if ($('#common-modal .popup-image-gallery').length > 0)
   {
     // custom parameters for carousel (see Owl Carousel documentation for more info)
     $("#common-modal .popup-image-gallery").owlCarousel({
       autoPlay : 5000,
       stopOnHover : true,
       navigation: false,
       paginationSpeed : 1000,
       goToFirstSpeed : 2000,
       singleItem : true,
       lazyLoad : true,
       autoHeight : true,
       transitionStyle: "fade",
       afterLazyLoad : function() {
         position_modal_at_centre(); // position popup at the centre of the page 
       }
     }); 
   }
   });

   // Destroy Owl Carousel when modal/popup is closed (it will be re-initialised again when popup is re-opened)
   $("#common-modal").on('hide.bs.modal', function()
   {
   if ($('#common-modal .popup-image-gallery').length > 0)
   {
     var carousel_initialised_data = $('#common-modal .popup-image-gallery').data('owlCarousel');
     carousel_initialised_data.destroy();
   }
   });
   // ------ END: Owl Carousel ------    
   
   
 
  $(window).unbind('resize').unbind('scroll');
    
    
   /* 
    * ----------------------------------------------------------
    * ON WINDOW RESIZE
    * ----------------------------------------------------------
    */
   $(window).resize(function()
   { 

       // update variables already set in document.ready above
       amount_of_pixels_as_buffer_between_sections = 0.25 * ($(window).height()); // used in update_active_sections_on_scroll();

       // Sections Content Vertical Position
       if (!jQuery.browser.mobile) sections_content_vertical_position();

       // Main Menu Visiblity on Window Resize
       main_menu_visiblity_on_resize();

       // Set equal height to all carousel slides on small displays
       set_equal_height_to_all_carousel_slides_on_small_displays();

   });
   // end: on window resize

   /* 
    * ----------------------------------------------------------
    * ON WINDOW SCROLL
    * ----------------------------------------------------------
    */
    
  
  
   $(window).scroll(function()
   { 
      // alert('scroll fire');
       // Update Active Sections on Scroll (do not use function when menu link was clicked - as this already has a link to the scroll function) -- (do not fire function on mobile viewports)
       if (!$("#main-content").hasClass("same_page_link_in_action") && !jQuery.browser.mobile )
       {
           update_active_sections_on_scroll(section_wrappers, amount_of_pixels_as_buffer_between_sections);
       }

       // update scroll to top icon visibility
       go_to_top_visibility();

   });
   // end: on window scroll

}
// end: initialise_document_ready_functions()

$(document).ready(function()
{
  if ($('body.homer').length) {
   initialise_document_ready_functions();
   initialise_window_load_functions();
  }
});

/* 
* ===============================================================
* ON WINDOW LOAD (after all elements were loaded)
* ===============================================================
*/

function initialise_window_load_functions()
{
   // update variables already set in document.ready above
   amount_of_pixels_as_buffer_between_sections = 0.25 * ($(window).height()); // used in update_active_sections_on_scroll();

   // Set equal height to all carousel slides on small displays
   set_equal_height_to_all_carousel_slides_on_small_displays();

   // Sections Content Vertical Position (when not viewing on a mobile)
   if (!jQuery.browser.mobile || viewport().width > window.xs_screen_max) sections_content_vertical_position();

   // preload all section background images after all elements were loaded (when not viewing on a mobile)
   if (!jQuery.browser.mobile || viewport().width > window.xs_screen_max) preload_section_backgrounds();

   // Grid Items Clearfix
   if (!jQuery.browser.mobile || viewport().width > window.xs_screen_max) add_clear_items_to_fix_grid_items_different_heights_issue();

   // Load images after other elements are loaded
   load_images("lazy", true, true);
}
// end: initialise_window_load_functions()

$(window).load(function()
{ 
  
});