pico-8 cartridge // http://www.pico-8.com
version 39
__lua__

--life cycle
function _init()
	x=1
	game_state = title_st()
end

function _update()
	game_state:update()
end

function _draw()
	cls()
	
	rect(0,0,127,127,1)
	game_state:draw()
end

-->8
--helpers
function colliding(box1,box2)
 return  box1[1] <= box2[3] and
   					 box1[2] <= box2[4] and
   					 box1[3] >= box2[1] and
   					 box1[4] >= box2[2]
end

function mk_lerper(s,e,r,t)
	return {
		s=s,
		e=e,
		r=r,
		t=t or 0,
		update=function(self)
			self.t+=self.r
			if(self.t>1) self.t=1
			if(self.t<0) self.t=0
		end,
		val=function(self)
			return(((1-self.t)*self.s)
										+(self.e*self.t)
									)
		end
	}
end

function draw_boxes(box_tbl,dc)
 c= dc or 11
	for w in all(box_tbl) do
		rect(w[1],w[2],w[3],w[4],c)
	end
end


--draw sprite box
--(sprite,x,y,width,height,
--fill color)
function draw_spr_box(s,x,y,w,h,fc)
	rectfill(x,y,x+w*8,y+h*8,fc)
	--horizontal
	for i=0,w do
		spr(s,x+i*8,y)
		spr(s,x+i*8,y+h*8)
	end
	--vertical
	for i=0,h do
		spr(s,x,y+i*8)
		spr(s,x+w*8,y+i*8)
	end
end

🅾️col=6
🅾️colt=0
function inv_text(text_tbl)
	for text_line, text in ipairs(text_tbl) do
		print(text, 11, text_line*8+77,4)
	end
	print('🅾️',110,112,🅾️col)

	🅾️colt+=1
	if(🅾️colt>20) then
		if(🅾️col==6)then 🅾️col=7
		else 🅾️col=6
		end
		🅾️colt=0
	end
end

--quantity of value included
function q_includes(tbl, val)
	q=0
	for k,v in pairs(tbl)
	do if(v==val) q+=1
	end
	return q
end

function mk_blank_st()
	return {
	 update=function(self)end,
		draw=function(self)end
	}
end
-->8
--active game state
function act_st()
	p=mk_player(20,20)
	p_am=mk_p_am()--player animation manager
	cont=mk_act_cont()
	cur_r=rooms[1]--current room
	info=mk_info_box()
	return{
		update=function()
			p:update()
			cont:update()
			hand_phys_col()
			hand_doors()
			info:update()
		end,
		draw=function()
			draw_room()
			p:draw()
			info:draw()
			cont:draw()
			--draw_boxes({p:sel_col()})
		--	for k,v in pairs(p_am:c())
		--	do print(k)
		--				print(v)
		--	end
		end
	}
end
-->8
--player
--make player(x,y)
function mk_player(x,y)
	return {
		x=x,
		y=y,
		f='⬇️',--facing
		--sprite origin x
		sox=function(self)
			return self.x-3
		end,
		all_col=function(self)
			return {
				self.x+2,
				self.y+11,
				self.x+7,
				self.y+15
			}
		end,
		sel_col=function(self)
			pushx=0
			pushy=0
			
			if(self.f=='⬅️')pushx=-3
			if(self.f=='➡️')pushx=2
			if(self.f=='⬇️')pushy=1
			if(self.f=='⬆️')pushy=-1
			
			local col = self:all_col()			
			col[1]+=pushx
			col[2]+=pushy
			col[3]+=pushx
			col[4]+=pushy
			
			return col
		end,
		side_cols=function(self)
			return {
				{--left
					self.x+2,
					self.y+13,
					self.x+3,
					self.y+12
				},
				{--top
					self.x+4,
					self.y+11,
					self.x+6,
					self.y+10
				},
				{--right
					self.x+7,
					self.y+13,
					self.x+8,
					self.y+12
				},
				{--bottom
					self.x+4,
					self.y+15,
					self.x+6,
					self.y+14
				}
			}
		end,
		update=function(self)
			p_am:update()
		end,
		draw=function(self)
			local flipx=self.f=='⬅️'
			p_am:draw(self:sox(),
													self.y,
													2,
													2,
													flipx)
		end,
	}
end
-->8
--make active state controller
function mk_act_cont()

	function mk_move_cont()
		return {
			update=function(self)
			
			 if(btnp(🅾️)) then
			 	for item in all(cur_r.items)
			 	do if(colliding(p:sel_col(),
			 														   item.col))
			 				then	
			 					info.state=mk_ib_dia_st(item.desc)
			 					if(p.f=='⬅️' or p.f=='➡️')
									then p_am.st='exam_side'
									elseif(p.f=='⬆️')
									then p_am.st='exam_up'
									elseif(p.f=='⬇️')
									then p_am.st='exam_down'
									end
			 					return mk_dia_cont()
			 				end
			 	end
			 	
			 end
			 
			 if(btnp(❎)) then
			 	return mk_inv_cont()
			 end
			 
				if(btn(➡️)) then 
					p.x+=1
					--new facing
					nf='➡️'
					--new animation state
				 nas='running'
				elseif(btn(⬅️)) then 
					p.x-=1
					nf='⬅️'
					nas='running'
				elseif(btn(⬇️)) then 
					p.y+=1
					nf='⬇️'
					nas='running'
				elseif(btn(⬆️)) then 
					p.y-=1
					nf='⬆️'
					nas='running'
				else nas='idle'
				end
				
				if(nf~=p.f 
				or nas~=p_am.st)
				then 
					p.f=nf
					
					if(nas=='idle')
					then 
					
						if(p.f=='⬅️' or p.f=='➡️')
						then p_am.st='idle_side'
						elseif(p.f=='⬆️')
						then p_am.st='idle_up'
						elseif(p.f=='⬇️')
						then p_am.st='idle'
						else
							p_am.st='idle'
						end
					
					elseif(nas=='running')
					then
					
						if(p.f=='⬅️' or p.f=='➡️')
						then p_am.st='run_side'
						elseif(p.f=='⬆️')
						then p_am.st='run_up'
						elseif(p.f=='⬇️')
						then p_am.st='run_down'
						end
						
					end
				end
			end,
			draw=function(self)end
		}
	end
	
	--make dialogue controller
	function mk_dia_cont()	
		return {
			update=function(self)
				info_s=info.state
				if(btnp(🅾️))
				then info_s.page+=1
					if(info_s.page
						 >#info_s.d.pages)
					then	return mk_move_cont()
					end
				end
			end,
			draw=function(self)end
		}
	end
	
	--make examine controller
	function mk_exam_cont(desc)
		return {
			desc=desc,
			update=function(self)
				if(btnp(🅾️)) then end
			end
		}
	end
	
	--make inv controller
	function mk_inv_cont()
		info.state.sel=1
 	p_am:set_st('inv_search')
		return {
			timer=0,
			ending=false,
			update=function(self)
			 if(self.timer>0)
				then
					if(self.timer>=p_am:c().taf-2)
					then	return mk_move_cont()
					end
				end
				if(self.ending)
				then self.timer+=1
									return
				end
				if(btnp(🅾️))
				then
					info.state.selected=true
					info.state.opt_nav=1
				end
				
				if(btnp(❎))
				then
					if(not info.state.selected)
					then 
						info.state.sel=nil
						info.state.nav=false
						p_am:set_st('inv_away')
						self.ending=true
					else
						info.state.selected=false
					end
				end
				
				if(info.state.selected)
				then
					if(btnp(➡️)) info.state.opt_nav+=1
					if(btnp(⬅️)) info.state.opt_nav-=1
					if(btnp(⬇️)) info.state.opt_nav+=1
					if(btnp(⬆️)) info.state.opt_nav-=1
				else
					if(btnp(➡️)) info.state.sel+=1
					if(btnp(⬅️)) info.state.sel-=1
					if(btnp(⬇️)) info.state.sel+=1
					if(btnp(⬆️)) info.state.sel-=1
				end
				if(info.state.sel)
				then
					if(info.state.sel>#inv.items)
					then info.state.sel=1
					elseif(info.state.sel<1)
					then info.state.sel=#inv.items
					end
				end
			end,
			draw=function(self)
			end
		}
	end
	
	return {
		state=mk_move_cont(),
		update=function(self)
			local ns = self.state:update()
			if(ns) self.state=ns
		end,
		draw=function(self)
			self.state:draw()
		end
	}
end
-->8
--rooms
rooms={
	{
		mx=0,
		my=0,
		items={
			{
				x=30, 
				y=40,
				s=141,
				desc={
					pages={
						{
					 	lines={	
 "doctor's bane...",
	"i always knew he was a fool",
	"for pursuing that p.h.d."
							}
						}
					}
				},
				col={
					30,
					39,
					38,
					48
				}
			}
		},
		doors={
			{
				col={--collider
					132,
					24,
					132,
					48
				},
				tar={--target room
				 room=2,
				 door=1--entrance
				},
				start={
					124,
					24
				}
			},
		}
	},
	{
		mx=16,
		my=0,
		doors={
			{
				col={--collider
					-4,
					24,
					-4,
					48
				},
				tar={--target room
				 room=1,
				 door=1--entrance
				},
				start={
					0,
					24
				}
			},
		}
	}
}
-->8
--room logic

--handle room doors
function hand_doors()
	for door 
	in all(cur_r.doors)
 do
		if(colliding(p:all_col(),
															door.col))
		then 
			cur_r=rooms[door.tar.room]
			start_xy=cur_r.doors[
										door.tar.door].start
			p.x=start_xy[1]
			p.y=start_xy[2]
		end
	end
end

--draw room
function draw_room()
	map(cur_r.mx,cur_r.my)
	
	for item in all(cur_r.items)
	do spr(item.s,item.x,item.y)
	end
	
end
-->8
--info box

--make info box
function mk_info_box()
	return{
		state=mk_ib_inv_st(),
		update=function(self)
			ns = self.state:update()
			if(ns) self.state=ns
		end,
		draw=function(self)
			draw_spr_box(140,0,72,15,6,9)
			self.state:draw()
		end
	}
end

function mk_ib_inv_st()
	return {
		sel=nil,
		nav=false,--navigating
		selected=false,
		nav_ins_x=40,
		nav_ins_y=72,
		opt_nav=1,
		--pop up speed
		--for info boxes	
		pop_s=mk_lerper(0,12,.1),
									
		update=function(self)
			if(self.opt_nav>3)
			then self.opt_nav=1
			elseif(self.opt_nav<1)
			then		self.opt_nav=3
			end
			
			if(self.selected) 
			then self.pop_s.e=-12
			else self.pop_s.e=12
			end
	 	if((self.selected 
	 					and self.nav_ins_y>0)
	 	or(not self.selected 
	 				and self.nav_ins_y<72))
	 	then
	 		self.pop_s:update()
	 		--self.nav_ins_y-=2
	 		self.nav_ins_y+=flr(
	 		self.pop_s:val()
	 		)
	 	else
	 		self.pop_s.t=0
	 	end
	 	if(self.selected 
	 					and self.nav_ins_y<0)
	 	then	self.nav_ins_y=0
	 	end
	 	if(not self.selected 
	 				and self.nav_ins_y>72)
	 	then
	 		 self.nav_ins_y=72
	 		end
		end,
		draw=function(self)
			draw_spr_box(140,
																40,
																self.nav_ins_y,
																10,
																9,
																9)
			draw_spr_box(140,
																0,
																self.nav_ins_y,
																5,
																9,
																9)
			draw_spr_box(140,
																0,
																self.nav_ins_y,
																5,
																5,
																9)
			opt_c={
				5,
				5,
				5
			}
			opt_c[self.opt_nav]=7
			print('UNEQUIP',
									11,
									self.nav_ins_y+48,
									opt_c[1])
			print('EXAMINE',
									11,
									self.nav_ins_y+54,
									opt_c[2])
		 print('USE',
									11,
									self.nav_ins_y+60,
									opt_c[3])
			print('WITH',
									13,
									self.nav_ins_y+65,
									opt_c[3])
		 draw_spr_box(140,0,72,15,6,9)
			for i,item in ipairs(inv.items) do
				sy=85 --sprite y
				ty1=104 --text y line 1
				ty2=111 --text y line 2
				
				if(self.sel==i)
				then sy=86
									ty1=105
									ty2=112
				end
				
				--draw equiped indicator
				if(inv.eqp==i)
				then sy=88
									ty1=105
									ty2=112
									c=15 -- color
									
									if(inv.eqp==self.sel)
									then c = 2
									end
									rect(11+(i-1)*34,
														84,
														43+(i-1)*34,
														118,
														c)
									rectfill(20+(i-1)*34,
														80,
														34+(i-1)*34,
														86,
														9)
									print('eqp',
															22+(i-1)*34,
															82,
															c)
				elseif(i==self.sel)
				 --draw selector box
				then rect(11+(i-1)*34,
														84,
														43+(i-1)*34,
														118,
														8)
				
				end
				
				--draw item sprite
				spr(item.s,19+(i-1)*34,sy,2,2)
				
				--print item name
				if(#item.n==1)
				then	print(item.n[1],
															14+(i-1)*34,
															107,
															4)
				else print(item.n[1],
															14+(i-1)*34,
															ty1,
															4)
									print(item.n[2],
															14+(i-1)*34,
															ty2,
															4)
				end
			end
		end
	}
end

--make info box dialogue state
--(dialogue)
function mk_ib_dia_st(d)
	return {
		d=d,--dialogue object,
		fc=5,--flash color,
		t=0,--timer,
		page=1,
		update=function(self)
			self.t+=1
			if(self.t%20==0)
			then if(self.fc==5)
								then self.fc=6
								else self.fc=5
								end
			end			
			if(self.page>#d.pages)
			then  
			 return mk_ib_inv_st()
		--	 self.d={pages={lines={}}}
			 
			end
		end,
		draw=function(self)
		 page=self.d.pages[self.page]
		 if(not page) return
		 
		 s=d[page.s]--speaker
			if(not page) return
			
			if(page.s=='s1') then
				draw_spr_box(140,0,0,6,8,9)
				draw_spr_box(140,0,48,6,3,9)
				spr(s.s,20,18,2,2)
				if(#s.n==1)
				then	print(s.n[1],12,62,0)
				else print(s.n[1],12,58,0)
									print(s.n[2],12,66,0)
				end
			elseif(page.s=='s2') then
				draw_spr_box(140,72,0,6,8,9)
				draw_spr_box(140,72,48,6,3,9)
				spr(s.s,92,18,2,2)
				--for line, name line in all
				--speaker.name
				if(#s.n==1)
				then	print(s.n[1],84,58,0)
				else print(s.n[1],84,58,0)
									print(s.n[2],84,66,0)
				end
			end
			for l,t 
			in ipairs(page.lines)
			do print(t,12,l*8+80,4)
			end
			print('🅾️',110,112,self.fc)
			
			end
	}
end

d1={
	s1={--speaker 1
		s=13,--sprite
		n={'erasmo'}--name
	},
	s2={--speaker 2
		s=142,
		n={
			'1982',
			'tv guide'
		},
	},
	pages={
	 {
			s='s1',
			lines={
				'ancient tome, i summon you'
			}
		},
		{
			s='s2',
			lines={
				'what is your dark bidding,',
				'my master?'
			}
		},
		{
			s='s1',
			lines={
				'i require knowledge of',
				'past futures'
			}
		},
		{
			s='s1',
			lines={
				'what was the hour of',
			 "smiling day's triumph",
			 "over earth and shark?"
			}
		},
		{
			s='s1',
			lines={
				'will lord fonzee prevail?',
				'will his days be...',
				'ever-smiling?'
			}
		},
		{
			s='s2',
			lines={
				'forbidden knowledge will',
				'know light upon the hour',
				'8:30pm central mountain'
			}
		},
		{
			s='s2',
			lines={
				'when the twin moons of',
				'aberash the mind reaper',
				'sow chaos under shadow'
			}
		},
	}
}
-->8
--inventory
inv={
	eqp=1,
	items={
		{
			s=142,
			n={'1982 tv','guide'}
		},
		{
			s=142,
			n={'1983 tv','guide'}
		},
		{
			s=142,
			n={'1984 tv','guide'}
		}
	}
}
-->8
--
-->8
--handle physical collisions
function hand_phys_col()
	side_cols={}
	walls=near_walls()
	for wall in all(walls) do
		for i,col 
		in ipairs(p:side_cols())
		do		
			if(colliding(col,wall))
			then side_cols[i]=true
			end
		end
	end
	
	items = cur_r.items
	for item
	in all(items) 
	do
		for i,col 
		in ipairs(p:side_cols()) 
		do		
			if(colliding(col,item.col))
			then side_cols[i]=true
			end
		end
	end
		
	if(side_cols[1])p.x+=1
	if(side_cols[2])p.y+=1
	if(side_cols[3])p.x-=1
	if(side_cols[4])p.y-=1
			
end

function near_walls()
	p_mx=flr((p:sox()-1)/8) --mapx
	p_my=flr((p.y+15)/8) --mapx
	
	walls={}
	for x=-2,2 do
		for y=-2,2 do
			if(
				not(
								p_mx+x+cur_r.mx
								>cur_r.mx+15 
					or p_my+y+cur_r.my>15 
					or p_mx+x+cur_r.mx
								<cur_r.mx
					or p_my+y+cur_r.my
								<cur_r.my
							)
				 )
			then
				--tile sprite
				ts=mget(p_mx+x+cur_r.mx,
												p_my+y+cur_r.my)
				if(fget(ts,0))
				then add(walls,{
					(p_mx+x)*8,
					(p_my+y)*8-1,
					(p_mx+x)*8+8,
					(p_my+y)*8+8
				})
				end
			end
		end
	end
			
	return walls
end
-->8
--player animations
p_exam_down_a={{afs=13,hf=1}}
p_exam_up_a={{afs=107,hf=1}}
p_exam_side_a={{afs=204,hf=1}}

p_inv_grab_a = {
	{
		afs=192,
		hf=3
	},
	{
		afs=194,
		hf=3
	},
	{
		afs=196,
		hf=3
	},
	{
		afs=198,
		hf=3
	},
	{
		afs=224,
		hf=3
	}
}

p_inv_dig_a = {
	{
		afs=226,
		hf=10
	},
	{
		afs=160,
		hf=10
	}
}

p_idle_a = {
	{
		--animation frame sprite
		afs = 9,
		--hold frames
		hf = 10
	},
	{
		--animation frame sprite
		afs = 11,
		--hold frames 
		hf = 12
	},
	{
		afs = 9, 
		hf = 10,
		flipx=true
	},
	{
		afs = 11, 
		hf = 12,
		flipx=true
	}
}

p_idle_up_a = {
	{
		afs = 73, 
		hf = 10
	},
	{
		afs = 75, 
		hf = 12
	},
	{
		afs = 73, 
		hf = 10,
		flipx=true
	},
	{
		afs = 75, 
		hf = 12,
		flipx=true
	}
}

p_run_down_a = {
	{
		afs = 13, 
		hf = 6
	},
	{
		afs = 41, 
		hf = 5
	},
	{
		afs = 43, 
		hf = 5
	},
	{
		afs = 13, 
		hf = 6,
		flipx=true
	},
	{
		afs = 41, 
		hf = 5,
		flipx=true
	},
	{
		afs = 43, 
		hf = 5,
		flipx=true
	}
}

p_run_up_a = {
	{
		afs = 77, 
		hf = 5
	},
	{
		afs = 105, 
		hf = 5
	},
	{
		afs = 107, 
		hf = 5
	},
	{
		afs = 77, 
		hf = 5,
		flipx=true
	},
	{
		afs = 105, 
		hf = 5,
		flipx=true
	},
	{
		afs = 107, 
		hf = 5,
		flipx=true
	}
}

p_idle_side_a = {
	{
		afs = 200, 
		hf = 10
	},
	{
		afs = 202, 
		hf = 12
	},
	{
		afs = 204, 
		hf = 11,
	},
	{
		afs = 202, 
		hf = 12
	}
}


p_run_side_a = {
	{
		afs = 228, 
		hf = 6
	},
	{
		afs = 230, 
		hf = 5
	},
	{
		afs = 232, 
		hf = 5
	},
	{
		afs = 234, 
		hf = 6,
	},
	{
		afs = 236, 
		hf = 5,
	},
	{
		afs = 238, 
		hf = 5,
	}
}

--make player animation manager
function mk_p_am()
	p_exam_up_ar=mk_ar()
	p_exam_up_ar:load_a(p_exam_up_a)
	
	p_exam_down_ar=mk_ar()
	p_exam_down_ar:load_a(p_exam_down_a)
	
	p_exam_side_ar=mk_ar()
	p_exam_side_ar:load_a(p_exam_side_a)

	p_inv_grab_ar=mk_ar()
	p_inv_grab_ar:load_a(p_inv_grab_a)
	
	p_inv_dig_ar=mk_ar()
	p_inv_dig_ar:load_a(p_inv_dig_a)

	p_inv_search_c_ar=mk_c_ar({
		p_inv_grab_ar,
		p_inv_dig_ar
	})
	
	p_inv_grab_r_ar=mk_ar()
	p_inv_grab_r_ar:load_a(
		p_inv_grab_a,
		true
	)
	
	p_idle_up_ar=mk_ar()
	p_idle_up_ar:load_a(p_idle_up_a)
	
	p_run_down_ar=mk_ar()
	p_run_down_ar:load_a(p_run_down_a)
	
	p_run_up_ar=mk_ar()
	p_run_up_ar:load_a(p_run_up_a)
	
	p_idle_side_ar=mk_ar()
	p_idle_side_ar:load_a(p_idle_side_a)
	
	p_run_side_ar=mk_ar()
	p_run_side_ar:load_a(p_run_side_a)
	
	p_idle_ar=mk_ar()
	p_idle_ar:load_a(p_idle_a)
	
	p_inv_away_c_ar=mk_c_ar({
		p_inv_grab_r_ar,
		p_idle_ar
	})

	return mk_ani_mgr(
	 {
			idle = p_idle_ar,
			idle_side=p_idle_side_ar,
			idle_up=p_idle_up_ar,
			run_down=p_run_down_ar,
			run_side=p_run_side_ar,
			run_up=p_run_up_ar,
			exam_down=p_exam_down_ar,
			exam_up=p_exam_up_ar,
			exam_side=p_exam_side_ar,
			inv_search=p_inv_search_c_ar,
			inv_away=p_inv_grab_r_ar
		}
	)
end


-->8
-- animation manager

-- state_animations is a table that represents connections between states and the animations that play
-- during those states
-- { state_name_string: animation_object}

--make animation manager
--(state_animation_table)
function mk_ani_mgr(st_ani_tbl)
	ani_mgr = {--animation manager
		st = "idle", -- state
		st_ani = st_ani_tbl,
		c=function(self)--current animation
			return self.st_ani[self.st]
		end,
		set_st=function(self,new_st)
			self.st=new_st
			self:c():reset_a()
		end,
		update=function(self)
			self:c():update()
		end,
		draw=function(self,
																pixelx, 
																pixely, 
																w, 
																h, 
																flipx)
																
			self:c():draw(pixelx,
																pixely,
																w, 
																h, 
																flipx)
		end
		}
	
	return ani_mgr
	end
	-->8
	--animator
	-- an animation object is:
	-- -- animation_frame_sprite = the sprite id for that frame of animation
	-- -- hold_frames = the number of frames to display this animation frame for before showing the next one
	
	--make animator
	function mk_ar()
	return{
		af=1,--animation frame
		fc=1,--frame count
		la={},--loaded animation
		taf=0,--total animation frames
		sfa=0,--switch frame at
		--load animation
		--(new animation, reverse)
		load_a=function(self,na,r)
			pa={}
			if(r) then
				for i,af in ipairs(na)
				do pa[#na+1-i]=af
				end
			else
				pa=na
			end
			self.la=pa
			self:init_a()
		end,
		--initialize animation
		init_a=function(self)
			self:reset_a()
			self.taf=self:caf()
		end,
		--calculate animation frames
		caf=function(self)
			--total animation frames
			local tfa=0
			--animation frame
			for af in all(self.la) do
				tfa += af.hf--hold frames
			end
			return tfa
		end,
		--calculate next frame switch
		cnfs=function(self)
			local fsa=0 --frame switch at
			for i=1, self.af 
			do fsa+=self.la[self.af].hf
			end
			return fsa
		end,
		--reset animator
		reset_a=function(self)
			self.af=1
			self.fc=1
			self.sfa=self:cnfs()
		end,
		update=function(self)
			if(self.fc>=self.sfa)
			then 
				self.af+=1
				if(self.af>#self.la)
				then self:reset_a()
				else self.sfa=self:cnfs()
			end
			end
			self.fc+=1
		end,
		draw=function(self,
																pixelx,
																pixely,
																w,
																h,
																oflipx)
			local w=w or 1
		local h=h or 1
		--current frame sprite
		cfs = self.la[self.af].afs
		flipx = self.la[self.af].flipx
				if(oflipx) flipx = not flipx       
		spr(cfs, 
						pixelx, 
						pixely, 
						w, 
						h, 
						flipx)
		end
	}
end

--make chain animator
function mk_c_ar(ar_tbl)
	return {
		cur=1,
		on_lf=false, --on last frame
		chain=ar_tbl,
		reset_a=function(self)
			self.cur=1
		end,
		update=function(self)
			cur_a = self.chain[self.cur]
			cur_a:update()
			if(cur_a.af==#cur_a.la)
			then self.on_lf=true
			end
			if(cur_a.fc==2
			and self.on_lf
			and self.cur<#self.chain)
			then self.cur+=1
								self.on_lf=false
			end
		end,
		draw=function(self,
																pixelx,
																pixely,
																w,
																h,
																oflipx)
			self.chain[self.cur]:draw(
																									pixelx,
																									pixely,
																									w,
																									h,
																									oflipx)
		end
	}
end
-->8
--title state

function title_st()
	--music(0)
	ball=mk_ball(34,25,2)
	--ripple effect
	rip=mk_rip(66,97,50,20)
	return {
		update=function()
			rip:update()
			ball:update()
			if(btnp(❎))
			then game_state=act_st()
			end
		end,
		
		draw=function()
			print('summoner 🐱',43,15,12)
			print('❎ to start',40,112,9)
			rip:draw()
			ball:draw()
		end
	}
end


-->8
--make ball(x,y,distance)
function mk_ball(x,y,d)
	return {
		x=x,
		y=y,
		oy=y,
		d=d+y,
		s=1, --sprite
		sw=8, --sprite width
		sh=8, --sprite height
		spd=.2, --speed
		mxspd=.2, --max speed,
		a=mk_lerper(-.015,--accelerator
														.015,
														.05,
														1),
		reverse=false,
		
		draw=function(self)
			spr(self.s,
							self.x,
							self.y,
							self.sw,
							self.sh)
		end,
		
		update=function(self)
			self.a:update()
			self.spd+=self.a:val()
			if(abs(self.spd)>self.mxspd)
			then 
				self.spd=(
						self.spd/abs(self.spd)
					*self.mxspd
				)
			end
			self.y+=self.spd
			
			if((
							abs(self.oy-self.y) 
			 	>	abs(self.oy-self.d)
						)
						and not self.reverse
					)
			then	self.a.r*=-1
								self.reverse=true
			elseif(abs(self.oy-self.y) 
			 				 <abs(self.oy-self.d))
			then self.reverse=false
			end
		end
	}
end
-->8
--make magic circl(x,y,l,w)
function mk_mgk_circ(x,y,w,h)
		return {
			x=x,
			y=y,
			wl=mk_lerper(0,w,.015,0),
			hl=mk_lerper(0,h,.015,0),
			c=6,
			
			draw=function(self)
				oval(self.x-self.wl:val()/2,
									self.y-self.hl:val()/2,
									self.x+self.wl:val()/2,
									self.y+self.hl:val()/2,
									self.c)
			end,
			
			update=function(self)
				self.wl:update()
				self.hl:update()
			end
		}
end
-->8
--make ripple effect(x,y,
--(x,y,width,height)
function mk_rip(x,y,w,h)
	return {
		x=x,
		y=y,
		w=w,
		h=h,
		t=0,
		mgk_circs={},
		
		update = function(self)
			if(self.t%30==0)
			then add(
				self.mgk_circs,
				mk_mgk_circ(
					self.x,
					self.y,
					self.w,
				 self.h
				)
			)
			end
			
			self.t+=1
			
			for circle in 
			all(self.mgk_circs)
			do circle:update()
				if(circle.wl.t==1)
				then del(self.mgk_circs,
													circle)
				elseif(circle.wl.t>.8)
				then circle.c=5
				elseif(circle.wl.t>.6)
				then circle.c=13
				end
			end 
		end,
		
		draw=function(self)
			for circle in
			all(self.mgk_circs)
			do circle:draw()
			end
		end
	}
end
	
__gfx__
00000000000000000000000000000000002222222222220000000000000000000000000000000001000000000000000000000000000000000000000000000000
00000000000000000000000000000022222222222222222222000000000000000000000000000011100000000000000100000000000000001000000000000000
0070070000000000000000000002222222211111111112222222200000000000000000000000001a100000000000001110000000000000011100000000000000
00077000000000000000000002222221111111111111111112222220000000000000000000000111110000000000001a1000000000000001a100000000000000
00077000000000000000000222221111111111111111111111112222200000000000000000000111a10000000000011111000000000000111110000000000000
007007000000000000000022221111111111111111111111111111222200000000000000000011111110000000000111a1000000000000111a10000000000000
00000000000000000000022211111111111111111111111111111111222000000000000000000464640000000000111111100000000001111111000000000000
00000000000000000002222111111111111111111111111111111111122220000000000000000444440000000000046464000000000000464640000000000000
00000000000000000022221111111111111111111111111111111111112222000000000000000744470000000000044444000000000000444440000000000000
00000000000000000222111111111111111111111111111111111111111122200000000000001777771000000000174447100000000001744470000000000000
000000000000000022211111111111111111111cccccccccc1111111111112220000000000001777671000000000177777100000000001777770000000000000
0000000000000002221111111111111111111cccccccccccccc11111111111222000000000001167711000000000177767100000000041777670000000000000
00000000000000022111111111111111111111cc11111111ccccc111111111122000000000001117111000000000116771100000000011167714000000000000
000000000000002221111111111111111111111111111cccccccccc1111111122200000000001111141000000000411711400000000011117111000000000000
00000000000002221111111111111111111111111111cccccccccccc111111112220000000001411111000000000111111100000000011111111000000000000
000000000000222111111111111111111111111111c1111cccccccccc11111111222000000011111111100000001111111110000000111111111100000000000
000000000000221111111111111111111111111111111111111ccccccc1111111122000000000000000000000000000100000000000000000000000000000000
00000000000222111111111111111111111111111111111111111ccc7cc111111122200000000000000000000000001110000000000000000000000000000000
000000000002211111111111111111111111111111111111111111cc7cc111111112200000000000010000000000001a10000000000000000000000000000000
0000000000222111111111111111111111111111111111111111111cc7cc11111112220000000000111000000000011111000000000000000000000000000000
0000000000221111111111111111111111111111111111111111111ccccc111111112200000000001a10000000000111a1000000000000000000000000000000
00000000002211111111111111111111111111111111111111111111ccccc1111111220000000001111100000000111111100000000000000000000000000000
00000000022211111111111111111111111111111111111111111111ccccc111111122200000000111a100000000046464000000000000000000000000000000
00000000022111111111111111111111111111111111111111111111cccccc111111122000000011111110000000044444040000000000000000000000000000
00000000022111111111111111111111111111111111111111111111cccccc111111122000000004646400000000174447110000000000000000000000000000
00000000022111111111111111111111111111111111111111111111cccccc111111122000000004444400000000177777110000000000000000000000000000
00000000222111111111111111111111111111111111111111111111cccccc111111122200000017444700000000177767100000000000000000000000000000
000000002211111111111111111111111111111111111111111111111ccccc111111112200000017777700000000116771100000000000000000000000000000
000000002211111111111111111111111111111111111111111111111ccccc111111112200000117776700000000111711100000000000000000000000000000
000000002211111111111111111111111111111111111111111111111ccccc111111112200000111677140000001111111100000000000000000000000000000
000000002211111111111111111111111111111111111111111111111ccccc111111112200001111171111000000911111110000000000000000000000000000
0000000022111111111111111111111111111111111111111111111111cccc111111112200001111111111000000001111110000000000000000000000000000
00000000221111111111111111111111111111111111111111111ccc1ccccc111111112200000001000000000000000000000000000000000000000000000000
00000000221111111111111111111111111111111111111111111ccc1ccccc111111112200000011100000000000000100000000000000001000000000000000
00000000221111111111111111111111111111111111111111111ccc1cccc11111111122000000a1100000000000001110000000000000011100000000000000
0000000022111111111111111111111111111111111111111111ccc1ccccc111111111220000011111000000000000a1100000000000000a1100000000000000
000000002211111111111111111111111111111111111111111ccc11cccc11111111112200000a11a10000000000011111000000000000111110000000000000
00000000222111111111111111111111111111111111111111ccc11ccccc111111111222000011111110000000000a11a1000000000000a11a10000000000000
00000000022111111111111111111111111111111111111111cc11ccccc111111111122000000444440000000000111111100000000001111111000000000000
00000000022111111111111111111111111111111111111111111cccccc111111111122000000444440000000000044444000000000000444440000000000000
000000000221111111111111111111111111111111111111111ccccccc1111111111122000000111110000000000011111000000000000444440000000000000
000000000222111111111111111111111111111111111111ccccccccc11111111111222000001111111000000000111111100000000001111110000000000000
0000000000221111111111111111111111111111111111111ccccccc111111111111220000001111111000000000111111100000000001111110000000000000
00000000002211111111111111111111111111111111111111ccccc1111111111111220000001111111000000000111111100000000011111110000000000000
00000000002221111111111111111111111111111c1111111cccc111111111111112220000001111111000000000111111100000000011111111000000000000
00000000000221111111111111111111111111111111111111c11111111111111112200000001111111000000000111111100000000011111111000000000000
00000000000222111111111111111111111111111111111111111111111111111122200000001111111000000000111111100000000011111111000000000000
000000000000221111111111111111111111111111111c1111111111111111111122000000011111111100000001111111110000000111111111100000000000
00000000000022211111111111111111111111111c11111111111111111111111222000000000000000000000000000100000000000000000000000000000000
000000000000022211111111111111111c1111111111111111111111111111112220000000000000000000000000001110000000000000000000000000000000
0000000000000022211111111111111111111111111111111111111111111112220000000000000001000000000000a110000000000000000000000000000000
00000000000000022111111111111111111111111111111111111111111111122000000000000000111000000000011111000000000000000000000000000000
00000000000000022211111111111111111111111111111111111111111111222000000000000000a110000000000a11a1000000000000000000000000000000
00000000000000002221111111111111111111111111111111111111111112220000000000000001111100000000111111100000000000000000000000000000
0000000000000000022211111111111111111111111111111111111111112220000000000000000a11a100000000044444000000000000000000000000000000
00000000000000000022221111111111111111111111111111111111112222000000000000000011111110000000044444040000000000000000000000000000
00000000000000000002222111111111111111111111111111111111122220000000000000000001111100000000111111110000000000000000000000000000
00000000000000000000022211111111111111111111111111111111222000000000000000000001111100000000111111110000000000000000000000000000
00000000000000000000002222111111111111111111111111111122220000000000000000000011111100000000111111100000000000000000000000000000
00000000000000000000000222221111111111111111111111112222200000000000000000000011111100000000111111100000000000000000000000000000
00000000000000000000000002222221111111111111111112222220000000000000000000000041111100000000111111100000000000000000000000000000
00000000000000000000000000022222222111111111122222222000000000000000000000000111111110000001111111100000000000000000000000000000
00000000000000000000000000000022222222222222222222000000000000000000000000001111111111000000111111110000000000000000000000000000
00000000000000000000000000000000002222222222220000000000000000000000000000001111111111000000001111110000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000933333333333333365555556444444440000b0005111111111111111
0000000000000000000000000000000000000000000000000000000000000000000000009333e333333333335655556549999994000400005111188888881111
00000000000000000000000000000000000000000000000000000000000000000000000093333e33333333335566665549944994008888005118888888888811
0000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeee00000000000000000000933e3333333333335565565549499494088888805188777878887881
00000000000000000000eeeeeeee000000000000000000000000eeeeeeee00000000000093e333e3333333335565565549499494088888805188878887878881
0000000000000000eeee0000000000000000000000000000000000000000eeee00000000933e3e33333333335566665549944994088888805188878888788881
0000000000000eee000000000000000000000000000000000000000000000000eee00000933333333333e3335655556549999994008888005118888888888811
00000000000ee000000000000000000000000000000000000000000000000000000ee00093333333333e3e336555555644444444000880005111188888881111
000000000ee000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000ee093333333333333332222222200000000000000005111111111111111
00000000e0000000000eeeeeee00000000000000000000000000000eeeeeee000000000e9333333333e333332dddddd2000000000000000051177777111fff11
00000000e000000000e00000000000000eeeeeeeeeeeeeee00000000000000e00000000e9333e3e3333e3e332dddddd200000000000000005177707771fffff1
00000000e0000000000eeeeeee00000000000000000000000000000eeeeeee000000000e933e333e333333e32dddddd200000000000000005177707771fffff1
000000000ee000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000ee09333e333333333332dddddd200000000000000005177777771fffff1
00000000000ee000000000000000000000000000000000000000000000000000000ee0009333333e333333332dddddd2000000000000000051177077111fff11
0000000000000eee000000000000000000000000000000000000000000000000eee00000933333e3333333332dddddd20000000000000000511177711111f111
0000000000000000eeee0000000000000000000000000000000000000000eeee000000009999999999999999222222220000000000000000511111111111f111
00000000000000000000eeeeeeee000000000000000000000000eeeeeeee00000000000099999999999999999999999999999999000004000000000000000000
0000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeee000000000000000000009333e333333333393333e3333333333300004040bb00000000000000
00000000010000000000000000000000000000000000000000000000000000000000000093333e333333333933333e3333333333000000040000000000000000
000000001110000000000000000000000000000000000000000000000000000000000000933e333333333339333e333333333333000000888800000000000000
000000001a1000000000000000000000000000000000000000000000000000000000000093e333e33333333933e333e333333333000088888888000000000000
000000011111000000000000000000000000000000000000000000000000000000000000933e3e3333333339333e3e3333333333000888888888880000000000
0000000111a1000000000000000000000000000000000000000000000000000000000000933333333333e339333333333333e333008888888888888000000000
00000011111110000000000000000000000000000000000000000000000000000000000093333333333e3e3933333333333e3e33008888888888888000000000
00000004646400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008888888888888000000000
00000001144400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000888888888888000000000
00000019119700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000888888888888000000000
00000099999100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000888888888880000000000
00000999999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088888888800000000000
00009999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008888888800000000000
00000999999910000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000888888000000000000
00001199999111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000010000000000000010000000000000000000000000000009991000000000000001000000000000000000000000000000000100000000000001000000000
00000111000000000000111000000000000000000000000000099911100000000000011100000000000000010000000000000001110000000000011100000000
000001a10000000000001a10000000000000000000000000009999a1a0000000000001a100000000000000111000000000000001a1000000000001a100000000
000011111000000000011111000000000000010000000000099991111100000000001111100000000000001a1000000000000011111000000000111110000000
0000111a10000000000111a10000000000001110000000000999911a1a00000000001a111000000000000111110000000000001a1110000000001a1110000000
000111111100000000111111100000000000a1100000000000991111111000000001111111000000000001a11100000000000111111100000001111111000000
00004646400000000000644400000000000111110000000000099644400000000000044460000000000011111110000000000004446000000000044460000000
00004444400000000000444700000000000a11a10000000000009446400000000000074440000000000000444600000000000007444000000000074440000000
00007444700000000000777110000000001111111000000000049444700000000000117770000000000001744400000000000011777000000000117770000000
00017777710000000007777110000000000044440000000000014777700000000000117777000000000001177700000000000011777700000000117777000000
00017776710000000007611111000000000011110000000000017776710000000000011167000000000001177770000000000001116700000000011111140000
00011677110000000006714411000000000111111000000000076771110000000000011176000000000000111670000000000001117600000000011111100000
00011171110000000007111441000000000111111000000000777711110000000000011117000000000000111760000000000001111170000000011111000000
00011111410000000000011111000000000011111100000000011111110000000000011110000000000000141170000000000011114100000000011110000000
00014111110000000000111111100000000011111100000000001111111000000000111141000000000001111110000000000011111100000000111111000000
00111111111000000001111111110000000111111110000000000111111000000001111111100000000011111111000000000111111110000001111111100000
00000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000100000000
00000000100000000000000010000000000000000000000000000000000000000000000111000000000000010000000000000000000000000000001110000000
000000011100000000000001110000000000000000000000000000000000000000000001a1000000000000111000000000000000000000000000001a10000000
00000001a100000000000001a100000000000000a000000000000000000000000000001111100000000000111000000000000000000000000000011111000000
00000011111000000000001111100000000000011100000000000000000000000000001a111000000000001a100000000000001110000000000001a111000000
000009991a100000000000111a1000000000001a1110000000000000100000000000011111110000000001111100000000000011110000000000111111100400
0000999991110000000001111111000000000011111000000000000a110000000000000444600400000001a11100000000000111a10000000000004446001100
000999999940000000000046464000000000011111110000000000111110000000000007444110000000111111100000000001a1110000000000007444111100
00099999994000000000004444400000000000144460000000000111111100000000001177710000000001744600000000001111111000000000011771111000
00099999999000000000011444700000000000117770000000000014446000000000001177770000000001177700000000000117770000000000011111110000
00009999999000000000011997700000000000117777000000000011777000000000040111167000000001177770000000000117777000000000401111160000
00009999999000000000099999710000000000011167000000000011777700000000000111176000000000117670000000000011767000000000000111107000
00001999999100000000999999910000000000041176000000000041116700000000000011110700000000411760000000000011176000000000000111100000
00001119999400000000999999910000000000001111000000000001111600000000000011111100000000111770000000000111147000000000000111110000
00001111114100000000099999110000000000111111000000000011111100000000000111111900000001111170000000000111117000000000011111119000
00011111111110000000119991111000000001111111100000000111111100000000001111000000000011111111000000001111111100000000111111100000
__label__
65555556655555566555555665555556655555566555555665555556655555566555555665555556655555566555555665555556655555566555555665555556
56555565565555655655556556555565565555655655556556555565565555655655556556555565565555655655556556555565565555655655556556555565
55666655556666555566665555666655556666555566665555666655556666555566665555666655556666555566665555666655556666555566665555666655
55655655556556555565565555655655556556555565565555655655556556555565565555655655556556555565565555655655556556555565565555655655
55655655556556555565565555655655556556555565565555655655556556555565565555655655556556555565565555655655556556555565565555655655
55666655556666555566665555666655556666555566665555666655556666555566665555666655556666555566665555666655556666555566665555666655
56555565565555655655556556555565565555655655556556555565565555655655556556555565565555655655556556555565565555655655556556555565
65555556655555566555555665555556655555566555555665555556655555566555555665555556655555566555555665555556655555566555555665555556
65555556222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222265555556
565555652dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd256555565
556666552dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd255666655
556556552dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd255655655
556556552dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd255655655
556666552dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd255666655
565555652dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd256555565
65555556222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222265555556
65555556222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222265555556
565555652dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd256555565
556666552dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd255666655
556556552dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd255655655
556556552dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd255655655
556666552dddddd22dddddd221ddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd255666655
565555652dddddd22dddddd2111dddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd256555565
6555555622222222222222221a122222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222265555556
65555556222222222222222111112222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
565555652dddddd22dddddd1a111ddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd2
556666552dddddd22ddddd1111111dd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd2
556556552dddddd22dddddd46464ddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd2
556556552dddddd22dddddd44444ddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd2
556666552dddddd22ddddd1744471dd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd2
565555652dddddd22ddddd1777771dd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd2
65555556222222222222221767771222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
65555556222222222222221177611222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
565555652dddddd22ddddd4117114dd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd2
556666552dddddd22ddddd1111111dd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd2
556556552dddddd22dddd111111111d22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd2
556556552dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd2
556666552dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd2
565555652dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd2
65555556222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
65555556222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
565555652dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd2
556666552dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd2
556556552dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd2
556556552dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd2
556666552dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd2
565555652dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd2
65555556222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
65555556222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222265555556
565555652dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd256555565
556666552dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd255666655
556556552dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd255655655
556556552dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd255655655
556666552dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd255666655
565555652dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd256555565
65555556222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222265555556
65555556222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222265555556
565555652dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd256555565
556666552dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd255666655
556556552dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd255655655
556556552dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd255655655
556666552dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd255666655
565555652dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd22dddddd256555565
65555556222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222265555556
65555556655555566555555665555556655555566555555665555556655555566555555665555556655555566555555665555556655555566555555665555556
56555565565555655655556556555565565555655655556556555565565555655655556556555565565555655655556556555565565555655655556556555565
55666655556666555566665555666655556666555566665555666655556666555566665555666655556666555566665555666655556666555566665555666655
55655655556556555565565555655655556556555565565555655655556556555565565555655655556556555565565555655655556556555565565555655655
55655655556556555565565555655655556556555565565555655655556556555565565555655655556556555565565555655655556556555565565555655655
55666655556666555566665555666655556666555566665555666655556666555566665555666655556666555566665555666655556666555566665555666655
56555565565555655655556556555565565555655655556556555565565555655655556556555565565555655655556556555565565555655655556556555565
65555556655555566555555665555556655555566555555665555556655555566555555665555556655555566555555665555556655555566555555665555556
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8a898b8b8b8b8b8b8b8b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8b9b9b9b9b9b9b9b9b9b9b9b9b9b9b8b8b999a999a999a999a999a999a999a8b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8b9b9b9b9b9b9b9b9b9b9b9b9b9b9b8b8b898a898a898a898a898a898a898a89000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9a999a999a999a999a999a999a999a99000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b8a898a898a898a898a898a898a898a8b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9a999a999a999a999a999a999a999a8b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8b9b9b9b9b9b9b9b9b9b9b9b9b9b9b8b8b898a898a898a898a898a898a898a8b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8b9b9b9b9b9b9b9b9b9b9b9b9b9b9b8b8b999a999a999a999a999a999a999a8b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b999a8b8b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000010050170501a0501d0501f050210502205023050240502505026050270502805029050000002a0502a0502b05000000000000000000000000000000000000000000000000000000000000000000
