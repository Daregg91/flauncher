/*
 * FLauncher — version Edgar & Margot
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

package me.efesser.flauncher;

import android.app.admin.DeviceAdminReceiver;

/**
 * Administrateur d'appareil minimal : sert uniquement au minuteur de veille
 * (DevicePolicyManager.lockNow()).
 */
public class SleepAdminReceiver extends DeviceAdminReceiver
{
}
