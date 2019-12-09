library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity Pong_VGA is
    Port(
      clk, reset, BTNL, BTNR, BTNU, BTND: in std_logic;
      hsync, vsync: out  std_logic;
      red: out std_logic_vector(3 downto 0);
      green: out std_logic_vector(3 downto 0);
      blue: out std_logic_vector(3 downto 0)    
    );
end Pong_VGA;

architecture Pong_VGA of Pong_VGA is
   -- VGA signals
   signal pixel_x, pixel_y: std_logic_vector(9 downto 0);
   signal video_on, pixel_tick: std_logic;
   signal red_reg, red_next: std_logic_vector(3 downto 0) := (others => '0');
   signal green_reg, green_next: std_logic_vector(3 downto 0) := (others => '0');
   signal blue_reg, blue_next: std_logic_vector(3 downto 0) := (others => '0'); 
   
   -- Synchronized buttons
   signal btn_l, btn_r, btn_u, btn_d: std_logic;  
   
   -- Ball direction, position, and bounds
   signal ball_dir_x, ball_dir_y : integer := 1;
   signal ball_x, ball_y, ball_next_x, ball_next_y : integer := 0;
   signal ball_xl, ball_xr, ball_yt, ball_yb : integer := 0;
   
   -- Paddle 1's direction position, and bounds
   signal paddle_dir_x, paddle_dir_y : integer := 1;
   signal paddle_x, paddle_y, paddle_next_x, paddle_next_y : integer := 0;
   signal paddle_xl, paddle_xr, paddle_yt, paddle_yb : integer := 0;
   
   -- Paddle 2's direction position, and bounds
   signal paddle2_dir_x, paddle2_dir_y : integer := 1;
   signal paddle2_x, paddle2_y, paddle2_next_x, paddle2_next_y : integer := 0;
   signal paddle2_xl, paddle2_xr, paddle2_yt, paddle2_yb : integer := 0;
   
   signal update_pos : std_logic := '0';
   
   -- Player scores 
   signal player1_score : integer range 0 to 5:= 0; -- Player 1 is the top paddle
   signal player2_score  : integer range 0 to 5:= 0; -- Player 2 is the bottom paddle
begin
   -- instantiate VGA sync circuit
   vga_sync_unit: entity work.vga_sync
    port map(clk=>clk, reset=>reset, hsync=>hsync,
               vsync=>vsync, video_on=>video_on,
               pixel_x=>pixel_x, pixel_y=>pixel_y,
               p_tick=>pixel_tick);
               
    -- synchronize input buttons
    sync_l: entity work.synchronizer port map( clk=>clk, a=>BTNL, b=>btn_l );
    sync_r: entity work.synchronizer port map( clk=>clk, a=>BTNR, b=>btn_r );
    sync_u: entity work.synchronizer port map( clk=>clk, a=>BTNU, b=>btn_u );
    sync_d: entity work.synchronizer port map( clk=>clk, a=>BTND, b=>btn_d );
    
    -- ball position
    ball_xl <= ball_x;  
    ball_yt <= ball_y;
    ball_xr <= ball_x + 30;
    ball_yb <= ball_y + 30;
    
    -- Paddle position
    paddle_xl <= paddle_x;
    paddle_yt <= paddle_y;
    paddle_xr <= paddle_x + 100;
    paddle_yb <= paddle_y + 20;
    
    -- paddle position
    paddle2_xl <= paddle2_x;
    paddle2_yt <= paddle_y + 460;
    paddle2_xr <= paddle2_x + 100;
    paddle2_yb <= paddle2_yt + 20;
    
    -- process to generate update position signal
    process ( video_on )
        variable counter : integer := 0;
    begin
        if rising_edge(video_on) then
            counter := counter + 1;
            if counter > 120 then
                counter := 0;
                update_pos <= '1';
            else
                update_pos <= '0';
            end if;
         end if;
    end process;
    
    -- PADDLE 1 movement
    -- the paddle is only supposed to be moving horizontally, so there is no control for y movement
    process ( btn_u, btn_l, paddle_dir_x, clk, paddle_xr, paddle_xl, paddle_yt, paddle_yb)
	begin
        if rising_edge(clk) then 
		    if (paddle_xr > 639) and (paddle_dir_x = 1) then
                paddle_dir_x <= -1;
				paddle_x <= 539;
            elsif (paddle_xl < 1) and (paddle_dir_x = -1) then
                paddle_dir_x <= 1;
				paddle_x <= 0;
            elsif ( btn_l = '1' ) then 
                paddle_dir_x <= 1;
				paddle_x <= paddle_next_x;
            elsif ( btn_u = '1' ) then 
                paddle_dir_x <= -1;
				paddle_x <= paddle_next_x;
		    else -- if a button isn't pressed, dont' move
				paddle_dir_x <= paddle_dir_x;
				paddle_x <= paddle_x;
            end if;
		end if;
	end process;
	
	-- PADDLE 2 movement
    -- the paddle is only supposed to be moving horizontally, so there is no control for y movement
    process ( btn_r, btn_d, paddle2_dir_x, clk, paddle2_xr, paddle2_xl, paddle2_yt, paddle2_yb)
	begin
        if rising_edge(clk) then 
		    if (paddle2_xr > 639) and (paddle2_dir_x = 1) then
                paddle2_dir_x <= -1;
				paddle2_x <= 539;
            elsif (paddle2_xl < 1) and (paddle2_dir_x = -1) then
                paddle2_dir_x <= 1;
				paddle2_x <= 0;
            elsif ( btn_d = '1' ) then 
                paddle2_dir_x <= 1;
				paddle2_x <= paddle2_next_x;
            elsif ( btn_r = '1' ) then 
                paddle2_dir_x <= -1;
				paddle2_x <= paddle2_next_x;
		    else -- if a button isn't pressed, dont' move
				paddle2_dir_x <= paddle2_dir_x;
				paddle2_x <= paddle2_x;
            end if;
		end if;
	end process;
    
    -- control ball and collision with the edge of the screen
    -- X direction
    process (ball_dir_x, clk, ball_xr, ball_xl, ball_yt, ball_yb)
	begin
        if rising_edge(clk) then 
		    if (ball_xr > 639) and (ball_dir_x = 1) then
                ball_dir_x <= -1;
				ball_x <= 639;				
            elsif (ball_xl < 1) and (ball_dir_x = -1) then
                ball_dir_x <= 1;   
				ball_x <= 0;
		    else 
				ball_dir_x <= ball_dir_x;
				ball_x <= ball_next_x;
            end if;
		end if;
	end process;
	
	-- control ball and collision with the edge of the screen
    -- Y direction
    process (ball_dir_y, clk, ball_xr, ball_xl, ball_yt, ball_yb)
	begin
        if rising_edge(clk) then 
		    if (ball_yb > 479) and (ball_dir_y = 1) then
                ball_dir_y <= -1;
                ball_y <= 479;
            elsif (ball_yt < 1) and (ball_dir_y = -1) then
                ball_dir_y <= 1;   
                ball_y <= 0;
            elsif (ball_xl > paddle_xl) and (ball_xr < paddle_xr) and
           (ball_yt > paddle_yt) and (ball_yb < paddle_yb)  and (ball_dir_y = -1) then
               ball_dir_y <= 1;
               ball_y <= ball_next_y;
            elsif (ball_xl > paddle2_xl) and (ball_xr < paddle2_xr) and
           (ball_yt > paddle2_yt) and (ball_yb < paddle2_yb)  and (ball_dir_y = 1) then
               ball_dir_y <= -1;
               ball_y <= ball_next_y;
		    else
				ball_dir_y <= ball_dir_y;
				ball_y <= ball_next_y;
            end if;
		end if;
	end process;
	
	-- compute the next x,y position for the ball
    process ( update_pos, ball_x, ball_y )
    begin
        if rising_edge(update_pos) then 
			ball_next_x <= ball_x + ball_dir_x;
			ball_next_y <= ball_y + ball_dir_y;
		end if;
    end process;
    
    -- compute the next x,y position for the paddles
    process ( update_pos, paddle_x, paddle_y, paddle2_x, paddle2_y )
    begin
        if rising_edge(update_pos) then 
			paddle_next_x <= paddle_x + paddle_dir_x;
			paddle_next_y <= paddle_y + paddle_dir_y;
			paddle2_next_x <= paddle2_x + paddle2_dir_x;
			paddle2_next_y <= paddle2_y + paddle2_dir_y;
		end if;
    end process;
    
    -- process to generate next colors           
    process (pixel_x, pixel_y)
    begin
           if (unsigned(pixel_x) > paddle_xl) and (unsigned(pixel_x) < paddle_xr) and
           (unsigned(pixel_y) > paddle_yt) and (unsigned(pixel_y) < paddle_yb) then
               -- paddle 1 color green
               red_next <= "0000";
               green_next <= "1111";
               blue_next <= "0000"; 
           elsif (unsigned(pixel_x) > paddle2_xl) and (unsigned(pixel_x) < paddle2_xr) and
           (unsigned(pixel_y) > paddle2_yt) and (unsigned(pixel_y) < paddle2_yb) then
               -- paddle 2 color green
               red_next <= "0000";
               green_next <= "1111";
               blue_next <= "0000"; 
           elsif (unsigned(pixel_x) > ball_xl) and (unsigned(pixel_x) < ball_xr) and
           (unsigned(pixel_y) > ball_yt) and (unsigned(pixel_y) < ball_yb) then
               -- ball color blue
               red_next <= "0000";
               green_next <= "0000";
               blue_next <= "1111"; 
           else    
               -- background color black
               red_next <= "0000";
               green_next <= "0000";
               blue_next <= "0000";
           end if;   
    end process;
    
    -- generate r,g,b registers
   process ( video_on, pixel_tick, red_next, green_next, blue_next)
   begin
      if rising_edge(pixel_tick) then
          if (video_on = '1') then
            red_reg <= red_next;
            green_reg <= green_next;
            blue_reg <= blue_next;   
          else
            red_reg <= "0000";
            green_reg <= "0000";
            blue_reg <= "0000";                    
          end if;
      end if;
   end process;
   
   red <= STD_LOGIC_VECTOR(red_reg);
   green <= STD_LOGIC_VECTOR(green_reg); 
   blue <= STD_LOGIC_VECTOR(blue_reg);
    
end Pong_VGA;