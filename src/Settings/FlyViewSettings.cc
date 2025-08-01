/****************************************************************************
 *
 * (c) 2009-2024 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "FlyViewSettings.h"

DECLARE_SETTINGGROUP(FlyView, "FlyView")
{
}

DECLARE_SETTINGSFACT(FlyViewSettings, guidedMinimumAltitude)
DECLARE_SETTINGSFACT(FlyViewSettings, guidedMaximumAltitude)
DECLARE_SETTINGSFACT(FlyViewSettings, showLogReplayStatusBar)
DECLARE_SETTINGSFACT(FlyViewSettings, showAdditionalIndicatorsCompass)
DECLARE_SETTINGSFACT(FlyViewSettings, lockNoseUpCompass)
DECLARE_SETTINGSFACT(FlyViewSettings, maxGoToLocationDistance)
DECLARE_SETTINGSFACT(FlyViewSettings, forwardFlightGoToLocationLoiterRad)
DECLARE_SETTINGSFACT(FlyViewSettings, goToLocationRequiresConfirmInGuided)
DECLARE_SETTINGSFACT(FlyViewSettings, keepMapCenteredOnVehicle)
DECLARE_SETTINGSFACT(FlyViewSettings, showSimpleCameraControl)
DECLARE_SETTINGSFACT(FlyViewSettings, showObstacleDistanceOverlay)
DECLARE_SETTINGSFACT(FlyViewSettings, updateHomePosition)
DECLARE_SETTINGSFACT(FlyViewSettings, instrumentQmlFile2)
DECLARE_SETTINGSFACT(FlyViewSettings, requestControlAllowTakeover)
DECLARE_SETTINGSFACT(FlyViewSettings, requestControlTimeout)
