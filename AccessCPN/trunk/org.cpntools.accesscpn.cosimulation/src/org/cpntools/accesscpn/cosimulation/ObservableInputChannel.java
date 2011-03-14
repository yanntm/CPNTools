package org.cpntools.accesscpn.cosimulation;

import java.util.Collection;
import java.util.Observable;
import java.util.Observer;

import org.cpntools.accesscpn.cosimulation.impl.PipeChannel;
import org.cpntools.accesscpn.engine.highlevel.instance.cpnvalues.CPNValue;

/**
 * 
 * @author mwesterg
 * 
 */
public class ObservableInputChannel extends Observable implements InputChannel, Runnable {
	private final InputChannel channel;
	private final PipeChannel pipe;

	public ObservableInputChannel(final InputChannel channel) {
		this.channel = channel;
		pipe = new PipeChannel();
		new Thread(this).start();
	}

	@Override
	public void addObserver(final Observer o) {
		synchronized (pipe) {
			final Collection<CPNValue> offers = getOffers();
			for (final CPNValue v : offers) {
				o.update(this, v);
			}
			super.addObserver(o);
		}
	}

	@Override
	public void close() {
		pipe.close();
		setChanged();
		notifyObservers();
	}

	@Override
	public Collection<CPNValue> getOffers() {
		return pipe.getOffers();
	}

	@Override
	public boolean isClosed() {
		return pipe.isClosed();
	}

	public boolean isReally(final InputChannel channel) {
		if (this.channel == channel) return true;
		if (this.channel != null && this.channel instanceof ObservableInputChannel)
			return ((ObservableInputChannel) this.channel).isReally(channel);
		return false;
	}

	@Override
	public void run() {
		while (!isClosed()) {
			final Collection<CPNValue> offer = channel.waitForOffer();
			if (offer.isEmpty()) {
				close();
			}
			synchronized (pipe) {
				pipe.offer(offer);
				setChanged();
				notifyObservers(offer);
			}
		}
	}

	@Override
	public Collection<CPNValue> waitForOffer() {
		return pipe.waitForOffer();
	}

}