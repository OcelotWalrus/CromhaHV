#region Copyright & License Information
/*
 * Copyright 2019-2024 The OpenHV Developers (see CREDITS)
 * This file is part of OpenHV, which is free software. It is made
 * available to you under the terms of the GNU General Public License
 * as published by the Free Software Foundation, either version 3 of
 * the License, or (at your option) any later version. For more
 * information, see COPYING.
 */
#endregion

using OpenRA.Mods.Common;
using OpenRA.Mods.Common.Activities;
using OpenRA.Mods.Common.Effects;
using OpenRA.Mods.Common.Traits;
using OpenRA.Mods.HV.Traits;
using OpenRA.Primitives;
using OpenRA.Traits;

namespace OpenRA.Mods.HV.Activities
{
	sealed class TransportResources : Enter
	{
		readonly int payload;
		readonly int[] multipliers;
		readonly string resourceType;
		readonly PlayerResources playerResources;
		readonly Actor spawner;

		public TransportResources(Actor self, Target target, int payload, int[] multipliers, string resourceType, Actor spawner)
			: base(self, target, Color.Yellow)
		{
			this.payload = payload;
			this.multipliers = multipliers;
			this.resourceType = resourceType;
			this.spawner = spawner;

			playerResources = self.Owner.PlayerActor.Trait<PlayerResources>();
		}

		protected override bool TryStartEnter(Actor self, Actor targetActor)
		{
			if (self.Owner != targetActor.Owner)
			{
				Cancel(self);
				return false;
			}

			return true;
		}

		protected override void OnEnterComplete(Actor self, Actor targetActor)
		{
			if (!string.IsNullOrEmpty(resourceType))
			{
				var targetOwner = targetActor.Owner;
				var resources = targetOwner.PlayerActor.Trait<PlayerResources>();

				var initialAmount = resources.Resources;
				if (!playerResources.Info.ResourceValues.TryGetValue(resourceType, out var resourceValue))
					return;

				var value = Util.ApplyPercentageModifiers(resourceValue * payload, multipliers);
				resources.GiveCash(value);

				foreach (var notify in self.World.ActorsWithTrait<INotifyResourceAccepted>())
				{
					if (notify.Actor.Owner != self.Owner)
						continue;

					notify.Trait.OnResourceAccepted(notify.Actor, self, resourceType, payload, value);
				}

				if (self.Owner.IsAlliedWith(self.World.RenderPlayer) && value > 0)
					self.World.AddFrameEndTask(w => w.Add(new FloatingText(targetActor.CenterPosition, targetOwner.Color, FloatingText.FormatCashTick(value), 30)));

				foreach (var notify in targetActor.TraitsImplementing<INotifyResourceTransport>())
					notify.Delivered(spawner, targetActor);
			}

			self.Dispose();
		}
	}
}
