function vid=camTest

% Connect to a camera
vid = videoinput('gentl', 1, 'Mono8');
src = getselectedsource(vid);

vid.FramesPerTrigger = Inf;

src.AcquisitionFrameRateEnable = 'True';
src.AcquisitionFrameRate = 40;



figTagName='wavSenseGUI';
f=findobj('tag',figTagName);
if isempty(f)
	fig=figure;
	fig.Tag=figTagName;
else
	fig=f;
end

clf(fig)
ax=axes(fig);
rPos = vid.ROIPosition;
hImage = image(zeros(rPos(3),rPos(4),3),'Parent',ax)
preview(vid,hImage)
axis equal
