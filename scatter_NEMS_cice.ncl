; ***********************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************

  ;dirpath = "/scratch4/NCEPDEV/ocean/noscrub/Zulema.Garraffo/hycom/GLBb0.08/expt_92.8/data/"
  dirpath = "/data1/GRIDS/"

  ;gridres = "008"
  gridres = "024"
  ;gridres = "050"

  filetype="cice"
  cornerprefix = "u"
  rfactor=180.d0/acos(-1.0d0)

  cornerlonname=cornerprefix+"lon"
  cornerlatname=cornerprefix+"lat"

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
  gridfile="grid_cice_NEMS_mx24.nc"
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
; 050 grid
;************************************************

 if(gridres .eq. "050")then
  gridfile="grid_cice_NEMS_mx5.nc"
  imax = 720
  if(filetype .eq. "cice")then
   jmax = (/ 410, 410/)
  ipole = (/ 180, 540/)
   ioff = 0
  end if
 end if

;************************************************
; load the grid file
;************************************************

  ; rad 2 degree conversion
  print("rfactor = "+rfactor)
  ; plot title
  plottitle=gridfile

  gf = addfile(dirpath+gridfile,"r")

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

  cornerjmax = jmax(1)
  corner_ipL = ipole(1)
  corneroff  = ioff

  corner_ipL = ipole(1)
  corneroff  = ioff

  corner_ipR=(imax - corner_ipL + corneroff)

  print(corner_ipL+","+corner_ipR)

  ; ncl indexing
  corner_ipL=corner_ipL-1
  corner_ipR=corner_ipR-1

  print ("Corner Lon,Lat on  Left "+cornerlon(cornerjmax-1,corner_ipL)+" "+cornerlat(cornerjmax-1,corner_ipL))
  print ("Corner Lon,Lat on Right "+cornerlon(cornerjmax-1,corner_ipR)+" "+cornerlat(cornerjmax-1,corner_ipR))
  deltalon=cornerlon(cornerjmax-1,corner_ipR) - cornerlon(cornerjmax-1,corner_ipL)
  print ("Delta Lon :"+deltalon)

;************************************************
; extract out points which cross the polar seam
;  ==> +/- 1 the pole i location
;************************************************

  corner_xlon = (/cornerlon(:,corner_ipL-1),cornerlon(:,corner_ipL),cornerlon(:,corner_ipL+1), \
                  cornerlon(:,corner_ipR-1),cornerlon(:,corner_ipR),cornerlon(:,corner_ipR+1)/)
  corner_xlat = (/cornerlat(:,corner_ipL-1),cornerlat(:,corner_ipL),cornerlat(:,corner_ipL+1), \
                  cornerlat(:,corner_ipR-1),cornerlat(:,corner_ipR),cornerlat(:,corner_ipR+1)/)

  print(dimsizes(corner_xlon))
;************************************************
; extract out points which parallel the polar seam
;************************************************

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

    map = new(2,graphic)
  plotr = new(2,graphic)
  plotb = new(2,graphic)
    dum = new(2,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  res@gsnPolar   = "NH"                  ; specify the hemisphere
  res@mpMinLatF  = 89.5                  ; minimum lat to plot
  if(imax .gt. 1500)then
   res@mpMinLatF  = 89.8                  ; minimum lat to plot
  end if
  if(imax .le. 720)then
   res@mpMinLatF  = 89.0                  ; minimum lat to plot
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
  res@gsnLeftString = "Corner ("+str_upper(cornerprefix)+")"
  map(ii) = scattplot(ii,corner_xlon(0:2,:),corner_xlat(0:2,:),corner_xlon(3:5,:),corner_xlat(3:5,:))

  ii=1
  res@gsnLeftString = "Corner ("+str_upper(cornerprefix)+")"
  map(ii) = scattplot(ii,corner_ylon(0,:),corner_ylat(0,:),corner_ylon(1,:),corner_ylat(1,:))

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,map,(/1,2/),resP)
  frame(wks)
end
