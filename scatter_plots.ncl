; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************

  ;dirpath = "/scratch4/NCEPDEV/ocean/noscrub/Zulema.Garraffo/hycom/GLBb0.08/expt_92.8/data/"
  dirpath = "/data1/GRIDS/"

  ;gridres = "008"
  gridres = "024"

  ;filetype="cice"
  ;cornerprefix = "u"
  ;centerprefix = "t"
  ;rfactor=180.d0/acos(-1.0d0)

  ;filetype="hycom"
  ;cornerprefix = "q"
  ;centerprefix = "p"
  ;rfactor=1.0

  filetype="kiss"
  cornerprefix = "q"
  centerprefix = "p"
  rfactor=1.0

  cornerlonname=cornerprefix+"lon"
  cornerlatname=cornerprefix+"lat"
  centerlonname=centerprefix+"lon"
  centerlatname=centerprefix+"lat"

;************************************************
; 008 grid
;************************************************

 if(gridres .eq. "008")then
  imax = 4500
  if(filetype .eq. "hycom")then
   jmax = (/3298,3298/)
  ipole = (/1126,1126/)
   ioff = 2
  end if
  if(filetype .eq. "kiss")then
   jmax = (/3297,3298/)
  ipole = (/1126,1126/)
   ioff = 2
  end if
  if(filetype .eq. "cice")then
   jmax = (/3297,3297/)
  ipole = (/1125,1125/)
   ioff = 0
  end if
 end if

;************************************************
; 024 grid
;************************************************

 if(gridres .eq. "024")then
   imax = 1500
  if(filetype .eq. "hycom")then
   jmax = (/1100,1100/)
  ipole = (/ 376, 376/)
   ioff = 2
  end if
  if(filetype .eq. "kiss")then
   jmax = (/1099,1100/)
  ipole = (/ 376, 376/)
   ioff = 2
  end if
  if(filetype .eq. "cice")then
   jmax = (/1099,1099/)
  ipole = (/ 375, 375/)
   ioff = 0
  end if
 end if

;************************************************
; load the grid file
;************************************************

  gridfile=filetype+"_grid_"+gridres+".nc"

  ; rad 2 degree conversion
  print("rfactor = "+rfactor)
  ; plot title
  plottitle=gridfile

  gf = addfile(dirpath+gridfile,"r")

  centerlat = gf->$centerlatname$(:,:)*rfactor
  centerlon = gf->$centerlonname$(:,:)*rfactor
  cornerlat = gf->$cornerlatname$(:,:)*rfactor
  cornerlon = gf->$cornerlonname$(:,:)*rfactor

;************************************************
; ESMF (31.2.5) notes that for BiPole:
;   Given that the edge is n elements long 
;   element i is connected to element n-i-1
;
; and ncl counts from 0==>-1
; so...
; ipL = i index of Pole on "Left" side
; ipR = i index of Pole on "Right" side
;************************************************

  centerjmax = jmax(0)
  cornerjmax = jmax(1)
  center_ipL = ipole(0)
  corner_ipL = ipole(1)
  corneroff  = ioff

  center_ipR=(imax - center_ipL +1)
  corner_ipR=(imax - corner_ipL + corneroff)

  print(corner_ipL+","+corner_ipR)
  print(center_ipL+","+center_ipR)

  ; ncl indexing
  center_ipL=center_ipL-1
  center_ipR=center_ipR-1
  corner_ipL=corner_ipL-1
  corner_ipR=corner_ipR-1

  print ("Center Lon,Lat on  Left "+centerlon(centerjmax-1,center_ipL)+" "+centerlat(centerjmax-1,center_ipL))
  print ("Center Lon,Lat on Right "+centerlon(centerjmax-1,center_ipR)+" "+centerlat(centerjmax-1,center_ipR))
  deltalon=centerlon(centerjmax-1,center_ipR) - centerlon(centerjmax-1,center_ipL)
  print ("Delta Lon :"+deltalon)
  print (" ")
  print ("Corner Lon,Lat on  Left "+cornerlon(cornerjmax-1,corner_ipL)+" "+cornerlat(cornerjmax-1,corner_ipL))
  print ("Corner Lon,Lat on Right "+cornerlon(cornerjmax-1,corner_ipR)+" "+cornerlat(cornerjmax-1,corner_ipR))
  deltalon=cornerlon(cornerjmax-1,corner_ipR) - cornerlon(cornerjmax-1,corner_ipL)
  print ("Delta Lon :"+deltalon)

;************************************************
; extract out points which cross the polar seam
;  ==> +/- 1 the pole i location
;************************************************

  center_xlon = (/centerlon(:,center_ipL-1),centerlon(:,center_ipL),centerlon(:,center_ipL+1), \
                  centerlon(:,center_ipR-1),centerlon(:,center_ipR),centerlon(:,center_ipR+1)/)
  center_xlat = (/centerlat(:,center_ipL-1),centerlat(:,center_ipL),centerlat(:,center_ipL+1), \
                  centerlat(:,center_ipR-1),centerlat(:,center_ipR),centerlat(:,center_ipR+1)/)

  corner_xlon = (/cornerlon(:,corner_ipL-1),cornerlon(:,corner_ipL),cornerlon(:,corner_ipL+1), \
                  cornerlon(:,corner_ipR-1),cornerlon(:,corner_ipR),cornerlon(:,corner_ipR+1)/)
  corner_xlat = (/cornerlat(:,corner_ipL-1),cornerlat(:,corner_ipL),cornerlat(:,corner_ipL+1), \
                  cornerlat(:,corner_ipR-1),cornerlat(:,corner_ipR),cornerlat(:,corner_ipR+1)/)

  print(dimsizes(corner_xlon))
;************************************************
; extract out points which parallel the polar seam
;************************************************

  center_ylon = (/centerlon(centerjmax-2:centerjmax-1,:)/)
  center_ylat = (/centerlat(centerjmax-2:centerjmax-1,:)/)

  corner_ylon = (/cornerlon(cornerjmax-2:cornerjmax-1,:)/)
  corner_ylat = (/cornerlat(cornerjmax-2:cornerjmax-1,:)/)

  ; index rel 0
  jrows=(/cornerjmax-2,cornerjmax-1/)
  jrows=jrows+1
  print("parallel rows: "+jrows(0)+" , "+jrows(1))

  print(dimsizes(corner_ylon))

;************************************************
; define the map
;************************************************

  wkstype="X11"
  ;wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,filetype+gridres)              ; send graphics to X11 window

    map = new(4,graphic)
  plotr = new(4,graphic)
  plotb = new(4,graphic)
    dum = new(4,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  res@gsnPolar   = "NH"                  ; specify the hemisphere
  res@mpMinLatF  = 89.5                  ; minimum lat to plot
  if(imax .gt. 1500)then
   res@mpMinLatF  = 89.8                  ; minimum lat to plot
  end if

  res@gsnStringFontHeightF = 0.05
;************************************************
; add a poly line showing the polar seem along  
; great circle path from (lon1,lat1) to (lon2,lat2)
;************************************************

  lon1=74.12
  lon2=-105.88
  lat1=60
  lat2=60

; ***************************************************
; Resources for the polyline
; ***************************************************

  res@mpGreatCircleLinesOn = True
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 4.0            ; line thickness
  pres@gsLineColor      = "green"         ; color of lines
  pres@gsLineDashPattern =  1            ; dashes

; ***************************************************
; create panel
; **************************************************

  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
  resP@gsnPanelYWhiteSpacePercent = 10
  resP@gsnPanelYWhiteSpacePercent = 10

  ;resP@gsnPanelMainString=plottitle
  resP@txString=plottitle

  resP@gsnStringFontHeightF = 0.30
;************************************************
; resources for polymarkers
;************************************************

  mkres               = True
  mkres@gsMarkerIndex = 2
  mkres@gsMarkerSizeF = 0.012

;************************************************
; the scatt plot call
;************************************************

begin
function scattplot(ii,xr,yr,xb,yb)
begin
  map(ii) = gsn_csm_map_polar(wks,res)                ; Create the map plot, don't draw
  dum(ii) = gsn_add_polyline(wks,map(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)
  mkres@gsMarkerColor = "Red"
  plotr(ii) = gsn_add_polymarker(wks,map(ii),xr,yr,mkres)
  mkres@gsMarkerColor = "Blue"
  plotb(ii) = gsn_add_polymarker(wks,map(ii),xb,yb,mkres)
  return(map(ii))
end

;************************************************
;
;************************************************

  ii=0
  res@gsnLeftString = "Center ("+str_upper(centerprefix)+")"
  map(ii) = scattplot(ii,center_xlon(0:2,:),center_xlat(0:2,:),center_xlon(3:5,:),center_xlat(3:5,:))
  ;map(ii) = scattplot(ii,center_xlon(1,:),center_xlat(1,:),center_xlon(4,:),center_xlat(4,:))

  ii=1
  res@gsnLeftString = "Corner ("+str_upper(cornerprefix)+")"
  map(ii) = scattplot(ii,corner_xlon(0:2,:),corner_xlat(0:2,:),corner_xlon(3:5,:),corner_xlat(3:5,:))
  ;map(ii) = scattplot(ii,corner_xlon(1,:),corner_xlat(1,:),corner_xlon(4,:),corner_xlat(4,:))

  ii=2
  res@gsnLeftString = "Center ("+str_upper(centerprefix)+")"
  map(ii) = scattplot(ii,center_ylon(0,:),center_ylat(0,:),center_ylon(1,:),center_ylat(1,:))

  ii=3
  res@gsnLeftString = "Corner ("+str_upper(cornerprefix)+")"
  map(ii) = scattplot(ii,corner_ylon(0,:),corner_ylat(0,:),corner_ylon(1,:),corner_ylat(1,:))

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,map,(/2,2/),resP)
  frame(wks)
end
